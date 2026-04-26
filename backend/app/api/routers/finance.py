"""Financial categories + permissions + shift close with manager"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user, require_role, require_perm
from app.models.user import User
from app.core.security import verify_password
from app.services.shift_service import compute_summary
from fastapi import HTTPException
import uuid

router = APIRouter(tags=["finance"])


# ── Financial Categories ───────────────────────────────────────────────────
@router.get("/financial-categories")
async def list_categories(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text("SELECT * FROM financial_categories ORDER BY type, name"))
    cols = r.keys()
    return [dict(zip(cols, row)) for row in r.fetchall()]


@router.post("/financial-categories")
async def create_category(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("users"))):
    r = await db.execute(text("""
        INSERT INTO financial_categories (name, type, color) VALUES (:name, :type, :color) RETURNING *
    """), {'name': data['name'], 'type': data.get('type','expense'), 'color': data.get('color','#64748b')})
    await db.commit()
    return dict(zip(r.keys(), r.fetchone()))


@router.put("/financial-categories/{cat_id}")
async def update_category(cat_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("users"))):
    await db.execute(text("UPDATE financial_categories SET name=:name, color=:color WHERE id=:id"),
                     {'id': cat_id, 'name': data['name'], 'color': data.get('color','#64748b')})
    await db.commit()
    return {"detail": "updated"}


@router.delete("/financial-categories/{cat_id}", status_code=204)
async def delete_category(cat_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("users"))):
    try:
        await db.execute(text("DELETE FROM financial_categories WHERE id=:id"), {'id': cat_id})
        await db.commit()
    except Exception:
        await db.rollback()
        # Has linked transactions — null out the category_id first then delete
        await db.execute(text("UPDATE drawer_transactions SET category_id=NULL WHERE category_id=:id"), {'id': cat_id})
        await db.execute(text("DELETE FROM financial_categories WHERE id=:id"), {'id': cat_id})
        await db.commit()


# ── User Permissions ───────────────────────────────────────────────────────
@router.get("/permissions/{user_id}")
async def get_permissions(user_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("users"))):
    r = await db.execute(text("SELECT permissions, is_manager FROM users WHERE id=:id"), {'id': user_id})
    row = r.fetchone()
    if not row: raise HTTPException(404)
    return {"permissions": row[0] or [], "is_manager": bool(row[1])}


@router.put("/permissions/{user_id}")
async def update_permissions(user_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("users"))):
    import json as _json
    await db.execute(
        text("UPDATE users SET permissions=cast(:p as jsonb), is_manager=:m WHERE id=:id"),
        {'id': user_id, 'p': _json.dumps(data.get('permissions', [])), 'm': data.get('is_manager', False)}
    )
    await db.commit()
    return {"detail": "updated"}


# ── Shift close with manager verification ─────────────────────────────────
@router.post("/shifts/{shift_id}/close-with-manager")
async def close_with_manager(shift_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db),
                              current_user: User = Depends(get_current_user)):
    """Close shift and record deposit received by a manager (requires manager password)."""
    from app.services.shift_service import close_shift
    from app.schemas.shift import ShiftClose
    from sqlalchemy import select
    from app.models.user import User as UserModel

    # Verify manager credentials
    manager_id = data.get('manager_id')
    manager_password = data.get('manager_password')
    
    mgr = (await db.execute(select(UserModel).where(UserModel.id == uuid.UUID(manager_id)))).scalar_one_or_none()
    if not mgr or not mgr.is_manager:
        raise HTTPException(403, "المستخدم المحدد ليس مديراً")
    if not verify_password(manager_password, mgr.password_hash):
        raise HTTPException(401, "كلمة مرور المدير غير صحيحة")

    # Close the shift
    close_data = ShiftClose(
        closing_balance=data['closing_balance'],
        next_day_drawer=data.get('next_day_drawer', 0),
        notes=data.get('notes')
    )
    shift = await close_shift(db, shift_id, close_data, current_user.id)
    
    # Record deposit + variance
    deposit = float(data['closing_balance']) - float(data.get('next_day_drawer', 0))
    # Get expected balance from summary to compute variance
    summary_data = await compute_summary(db, shift_id)
    variance = float(data['closing_balance']) - float(summary_data['expected_balance'])

    await db.execute(text("UPDATE shifts SET deposit_received_by=:mgr, deposit_amount=:dep WHERE id=:id"),
                     {'mgr': uuid.UUID(manager_id), 'dep': deposit, 'id': shift_id})

    # Apply variance to cashier's payroll if linked to an hr_employee
    if shift.cashier_id and variance != 0:
        from datetime import datetime as _dt
        month = _dt.utcnow().strftime('%Y-%m')
        await db.execute(text("""
            UPDATE hr_payroll SET
                drawer_variance = drawer_variance + :var,
                net_salary = GREATEST(0, net_salary + :var)
            WHERE employee_id = (SELECT id FROM hr_employees WHERE user_id=:uid LIMIT 1)
            AND month=:month
        """), {'var': variance, 'uid': shift.cashier_id, 'month': month})

    await db.commit()
    return {"status": "closed", "deposit_amount": deposit, "received_by": mgr.full_name,
            "variance": round(variance, 2), "variance_note": "عجز" if variance < 0 else "زيادة" if variance > 0 else "مطابق"}


# ── Financial Ledger by Category ──────────────────────────────────────────
@router.get("/financial-ledger")
async def financial_ledger(
    from_date: str, to_date: str,
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    """
    Returns all drawer transactions grouped by financial category.
    Shows total per category + individual entries — like customer accounts but for expenses/income.
    """
    from datetime import datetime as _dt
    start = _dt.fromisoformat(from_date)
    end   = _dt.fromisoformat(to_date).replace(hour=23, minute=59, second=59)

    q = """
        SELECT dt.id, dt.type, dt.amount, dt.note, dt.created_at,
               fc.name as category_name, fc.type as category_type, fc.color,
               s.warehouse_id, w.name as warehouse_name,
               u.full_name as cashier_name
        FROM drawer_transactions dt
        JOIN shifts s ON dt.shift_id = s.id
        LEFT JOIN financial_categories fc ON dt.category_id = fc.id
        LEFT JOIN warehouses w ON s.warehouse_id = w.id
        LEFT JOIN users u ON dt.created_by = u.id
        WHERE dt.created_at BETWEEN :start AND :end
        AND dt.type IN ('expense', 'deposit', 'withdrawal')
    """
    params = {'start': start, 'end': end}
    if warehouse_id:
        q += " AND s.warehouse_id = :wid"
        params['wid'] = uuid.UUID(warehouse_id)
    q += " ORDER BY dt.created_at DESC"

    rows = (await db.execute(text(q), params)).fetchall()
    cols = ['id','type','amount','note','created_at','category_name','category_type','color','warehouse_id','warehouse_name','cashier_name']
    entries = [dict(zip(cols, r)) for r in rows]

    # Group by category
    from collections import defaultdict
    by_category: dict = defaultdict(lambda: {'total': 0.0, 'count': 0, 'entries': []})
    uncategorized = {'total': 0.0, 'count': 0, 'entries': []}

    for e in entries:
        e['amount'] = float(e['amount'])
        e['created_at'] = e['created_at'].isoformat() if e['created_at'] else None
        e['warehouse_id'] = str(e['warehouse_id']) if e['warehouse_id'] else None
        cat = e['category_name'] or 'غير مصنف'
        if e['category_name']:
            by_category[cat]['total'] += e['amount']
            by_category[cat]['count'] += 1
            by_category[cat]['color'] = e['color']
            by_category[cat]['type'] = e['category_type']
            by_category[cat]['entries'].append(e)
        else:
            uncategorized['total'] += e['amount']
            uncategorized['count'] += 1
            uncategorized['entries'].append(e)

    categories_out = [
        {'name': k, 'total': v['total'], 'count': v['count'],
         'color': v.get('color','#64748b'), 'type': v.get('type','expense'), 'entries': v['entries']}
        for k, v in sorted(by_category.items(), key=lambda x: -x[1]['total'])
    ]
    if uncategorized['count']:
        categories_out.append({'name': 'غير مصنف', 'total': uncategorized['total'],
                                'count': uncategorized['count'], 'color': '#94a3b8',
                                'type': 'expense', 'entries': uncategorized['entries']})

    total_expense = sum(e['amount'] for e in entries if e['type'] in ('expense','withdrawal'))
    total_income  = sum(e['amount'] for e in entries if e['type'] == 'deposit')

    return {
        'from_date': from_date, 'to_date': to_date,
        'total_expense': total_expense, 'total_income': total_income,
        'net': total_income - total_expense,
        'categories': categories_out,
    }


# ── Audit Log ─────────────────────────────────────────────────────────────────
@router.get("/audit-log")
async def get_audit_log(
    entity_type: str | None = None,
    entity_id: str | None = None,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin", "manager"))
):
    conditions = ["1=1"]
    params: dict = {"limit": limit}
    if entity_type:
        conditions.append("entity_type = :etype")
        params["etype"] = entity_type
    if entity_id:
        conditions.append("entity_id = :eid")
        params["eid"] = entity_id
    rows = await db.execute(text(f"""
        SELECT al.*, u.full_name as user_display
        FROM audit_log al
        LEFT JOIN users u ON u.id = al.user_id
        WHERE {' AND '.join(conditions)}
        ORDER BY al.created_at DESC LIMIT :limit
    """), params)
    return [dict(r._mapping) for r in rows.fetchall()]
