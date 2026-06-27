from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text as sqlt
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm, require_open_period, verify_warehouse_access
from app.models.user import User
from app.core.exceptions import NotFoundError
from app.schemas.expense import ExpenseVendorCreate, ExpenseVendorUpdate, ExpenseCreate, ExpenseUpdate, ExpenseApprove
import uuid

router = APIRouter(tags=["expenses"])


# ── Expense Vendors ────────────────────────────────────────────────────────

@router.get("/expense-vendors")
async def list_vendors(search: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    where = "WHERE (v.name ILIKE :s OR v.phone ILIKE :s)" if search else ""
    rows = await db.execute(sqlt(f"""
        SELECT v.*, (SELECT COUNT(*) FROM expenses e WHERE e.vendor_id = v.id) as expense_count
        FROM expense_vendors v {where}
        ORDER BY v.name
    """), {"s": f"%{search}%" } if search else {})
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("/expense-vendors", status_code=201)
async def create_vendor(data: ExpenseVendorCreate, db: AsyncSession = Depends(get_db),
                        current_user=Depends(require_perm("finance"))):
    r = await db.execute(sqlt("""
        INSERT INTO expense_vendors (name, phone, address, tax_id, notes, created_by)
        VALUES (:name, :phone, :address, :tax_id, :notes, :by)
        RETURNING *
    """), {"name": data.name, "phone": data.phone, "address": data.address,
            "tax_id": data.tax_id, "notes": data.notes, "by": current_user.id})
    await db.commit()
    return dict(r.mappings().first())


@router.put("/expense-vendors/{vid}")
async def update_vendor(vid: uuid.UUID, data: ExpenseVendorUpdate, db: AsyncSession = Depends(get_db),
                        _=Depends(require_perm("finance"))):
    ALLOWED_VENDOR_FIELDS = {"name", "phone", "address", "tax_id", "notes"}
    updates = {k: v for k, v in data.model_dump(exclude_unset=True).items() if k in ALLOWED_VENDOR_FIELDS}
    if not updates:
        raise NotFoundError()
    sets = ", ".join(f"{k} = :{k}" for k in updates)
    r = await db.execute(sqlt(f"UPDATE expense_vendors SET {sets} WHERE id = :id RETURNING *"),
                         {**updates, "id": vid})
    await db.commit()
    row = r.mappings().first()
    if not row:
        raise NotFoundError()
    return dict(row)


# ── Expenses ───────────────────────────────────────────────────────────────

@router.get("/expenses")
async def list_expenses(
    search: str | None = None,
    vendor_id: str | None = None,
    category_id: str | None = None,
    warehouse_id: str | None = None,
    status: str | None = None,
    date_from: str | None = None,
    date_to: str | None = None,
    recurring: bool | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    params: dict = {}
    where_parts = ["1=1"]
    if search:
        where_parts.append("(e.description ILIKE :s OR v.name ILIKE :s)")
        params["s"] = f"%{search}%"
    if vendor_id:
        where_parts.append("e.vendor_id = :vid")
        params["vid"] = vendor_id
    if category_id:
        where_parts.append("e.category_id = :cid")
        params["cid"] = category_id
    if warehouse_id:
        where_parts.append("e.warehouse_id = :wid")
        params["wid"] = warehouse_id
    if status:
        where_parts.append("e.status = :st")
        params["st"] = status
    if date_from:
        where_parts.append("e.date >= :df")
        params["df"] = date_from
    if date_to:
        where_parts.append("e.date <= :dt")
        params["dt"] = date_to
    if recurring is not None:
        where_parts.append("e.is_recurring = :rec")
        params["rec"] = recurring
    where = " AND ".join(where_parts)
    offset = (page - 1) * page_size
    count = await db.execute(sqlt(f"SELECT COUNT(*) FROM expenses e LEFT JOIN expense_vendors v ON v.id = e.vendor_id WHERE {where}"), params)
    total = count.scalar()
    rows = await db.execute(sqlt(f"""
        SELECT e.*, v.name as vendor_name, fc.name as category_name, w.name as warehouse_name,
            u.full_name as created_by_name
        FROM expenses e
        LEFT JOIN expense_vendors v ON v.id = e.vendor_id
        LEFT JOIN financial_categories fc ON fc.id = e.category_id
        LEFT JOIN warehouses w ON w.id = e.warehouse_id
        LEFT JOIN users u ON u.id = e.created_by
        WHERE {where}
        ORDER BY e.date DESC, e.created_at DESC
        LIMIT :lim OFFSET :off
    """), {**params, "lim": page_size, "off": offset})
    return {"data": [dict(r._mapping) for r in rows.fetchall()], "total": total, "page": page, "page_size": page_size}


@router.post("/expenses", status_code=201)
async def create_expense(data: ExpenseCreate, db: AsyncSession = Depends(get_db),
                         current_user=Depends(require_perm("finance")), _=Depends(require_open_period)):
    r = await db.execute(sqlt("""
        INSERT INTO expenses (vendor_id, category_id, warehouse_id, amount, description, date,
            payment_method, wallet_id, safe_id, is_recurring, recurring_interval, recurring_end_date,
            notes, created_by, status)
        VALUES (:vendor_id, :category_id, :warehouse_id, :amount, :description,
            COALESCE(:date, CURRENT_DATE), :payment_method, :wallet_id, :safe_id,
            :is_recurring, :recurring_interval, :recurring_end_date, :notes, :by, 'draft')
        RETURNING *
    """), {
        "vendor_id": data.vendor_id, "category_id": data.category_id,
        "warehouse_id": data.warehouse_id, "amount": data.amount,
        "description": data.description, "date": data.date,
        "payment_method": data.payment_method, "wallet_id": data.wallet_id,
        "safe_id": data.safe_id, "is_recurring": data.is_recurring,
        "recurring_interval": data.recurring_interval,
        "recurring_end_date": data.recurring_end_date,
        "notes": data.notes, "by": current_user.id,
    })
    await db.commit()
    return dict(r.mappings().first())


@router.put("/expenses/{eid}")
async def update_expense(eid: uuid.UUID, data: ExpenseUpdate, db: AsyncSession = Depends(get_db),
                         _=Depends(require_perm("finance"))):
    existing = await db.execute(sqlt("SELECT * FROM expenses WHERE id = :id"), {"id": eid})
    if not existing.mappings().first():
        raise NotFoundError()
    from app.schemas.expense import ExpenseUpdate as _ExpenseUpdate
    ALLOWED_EXPENSE_FIELDS = set(_ExpenseUpdate.model_fields.keys())
    updates = {k: v for k, v in data.model_dump(exclude_unset=True).items() if k in ALLOWED_EXPENSE_FIELDS}
    if not updates:
        raise NotFoundError()
    sets = ", ".join(f"{k} = :{k}" for k in updates)
    r = await db.execute(sqlt(f"UPDATE expenses SET {sets} WHERE id = :id RETURNING *"),
                         {**updates, "id": eid})
    await db.commit()
    return dict(r.mappings().first())


@router.post("/expenses/{eid}/approve")
async def approve_expense(eid: uuid.UUID, data: ExpenseApprove, db: AsyncSession = Depends(get_db),
                          current_user=Depends(require_perm("finance"))):
    status = "approved" if data.approved else "rejected"
    r = await db.execute(sqlt("""
        UPDATE expenses SET status = :st, approved_by = :by, approved_at = now(), notes = COALESCE(:notes, notes)
        WHERE id = :id RETURNING *
    """), {"st": status, "by": current_user.id, "notes": data.notes, "id": eid})
    await db.commit()
    row = r.mappings().first()
    if not row:
        raise NotFoundError()
    return dict(row)


@router.delete("/expenses/{eid}", status_code=204)
async def delete_expense(eid: uuid.UUID, db: AsyncSession = Depends(get_db),
                         _=Depends(require_perm("finance"))):
    r = await db.execute(sqlt("DELETE FROM expenses WHERE id = :id"), {"id": eid})
    await db.commit()
    if r.rowcount == 0:
        raise NotFoundError()


# ── Expense Summary ────────────────────────────────────────────────────────

@router.get("/expenses/summary")
async def expense_summary(
    date_from: str | None = None,
    date_to: str | None = None,
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    params: dict = {}
    where_parts = ["e.status = 'approved'"]
    if date_from:
        where_parts.append("e.date >= :df")
        params["df"] = date_from
    if date_to:
        where_parts.append("e.date <= :dt")
        params["dt"] = date_to
    if warehouse_id:
        where_parts.append("e.warehouse_id = :wid")
        params["wid"] = warehouse_id
    where = " AND ".join(where_parts)
    r = await db.execute(sqlt(f"""
        SELECT
            COALESCE(SUM(e.amount), 0) as total,
            COUNT(*) as count,
            COUNT(*) FILTER (WHERE e.is_recurring) as recurring_count,
            COALESCE(SUM(e.amount) FILTER (WHERE e.is_recurring), 0) as recurring_total
        FROM expenses e WHERE {where}
    """), params)
    summary = dict(r.mappings().first())

    cats = await db.execute(sqlt(f"""
        SELECT fc.name, fc.color, SUM(e.amount) as total, COUNT(*) as count
        FROM expenses e JOIN financial_categories fc ON fc.id = e.category_id
        WHERE {where}
        GROUP BY fc.name, fc.color ORDER BY total DESC
    """), params)
    summary["by_category"] = [dict(r._mapping) for r in cats.fetchall()]
    return summary
