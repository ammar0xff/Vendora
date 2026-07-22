import uuid
import json
from decimal import Decimal
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, text as sqlt
from app.models.shift import Shift, ShiftStatus, DrawerTransaction, DrawerTxType
from app.core.exceptions import BusinessError, NotFoundError, ForbiddenError


async def _find_employee_by_user_id(db: AsyncSession, user_id: uuid.UUID):
    """Find hr_employees record by matching user_id FK column."""
    result = await db.execute(
        sqlt("SELECT e.id FROM hr_employees e WHERE e.user_id = :uid AND e.is_active = TRUE LIMIT 1"),
        {"uid": user_id}
    )
    emp = result.scalar_one_or_none()
    if emp:
        return emp
    # Fallback: match emp_code = user UUID (legacy data)
    result = await db.execute(
        sqlt("SELECT e.id FROM hr_employees e WHERE e.emp_code = :uid_text AND e.is_active = TRUE LIMIT 1"),
        {"uid_text": str(user_id)}
    )
    return result.scalar_one_or_none()


async def _record_payroll_variance(db: AsyncSession, shift_id, difference, current_user_id, actor=None):
    """Record shift variance as payroll advance/deduction."""
    if difference == 0:
        return
    note = f"فرق عجز/زيادة الدرج — وردية {shift_id}"
    record_type = "خصم" if difference < 0 else "مكافأة"
    shift = await db.get(Shift, shift_id)
    if not shift or not shift.cashier_id:
        return
    emp_id = await _find_employee_by_user_id(db, shift.cashier_id)
    if emp_id:
        await db.execute(sqlt("""
            INSERT INTO hr_advances (id, employee_id, amount, note, record_type, date, created_by)
            VALUES (gen_random_uuid(), :eid, :amt, :note, :rtype, NOW(), :uid)
        """), {"eid": emp_id, "amt": abs(float(difference)), "note": note, "rtype": record_type, "uid": str(actor or current_user_id)})


async def open_shift(db: AsyncSession, cashier_id: uuid.UUID, warehouse_id: uuid.UUID, initial_amount: Decimal, supervisor_id: uuid.UUID | None = None) -> Shift:
    """Open a new shift. Enforces one-open-shift-per-(cashier, warehouse)."""
    if initial_amount < 0:
        raise BusinessError("مبلغ العهدة لا يمكن أن يكون سالباً")
    # Advisory lock serializes concurrent opens for same cashier+warehouse
    lock_key = hash((str(cashier_id), str(warehouse_id))) & 0x7FFFFFFF
    await db.execute(sqlt("SELECT pg_advisory_xact_lock(:k)"), {"k": lock_key})

    existing = await db.execute(
        select(Shift).where(
            Shift.warehouse_id == warehouse_id,
            Shift.cashier_id == cashier_id,
            Shift.status == ShiftStatus.open
        )
    )
    if existing.scalar_one_or_none():
        raise BusinessError("لديك وردية مفتوحة بالفعل في هذا الفرع")

    shift = Shift(
        cashier_id=cashier_id,
        warehouse_id=warehouse_id,
        supervisor_id=supervisor_id,
        initial_amount=initial_amount,
    )
    db.add(shift)
    await db.commit()
    await db.refresh(shift)
    return shift


async def close_shift(db: AsyncSession, shift_id: uuid.UUID, closing_balance: Decimal, next_day_drawer: Decimal | None, notes: str | None, closed_by: uuid.UUID) -> dict:
    """Close a shift: compute summary, store expected_balance + difference."""
    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("الوردية غير موجودة")
    if shift.status != ShiftStatus.open:
        raise BusinessError("الوردية مغلقة بالفعل")
    if shift.cashier_id and shift.cashier_id != closed_by:
        raise ForbiddenError("الدرج مسجل باسم موظف آخر — لا يمكنك إغلاقه")

    summary = await compute_summary(db, shift_id)
    expected = summary["expected_balance"]
    difference = closing_balance - expected

    shift.status = ShiftStatus.closed
    shift.closing_balance = closing_balance
    shift.expected_balance = expected
    shift.difference = difference
    shift.next_day_drawer = next_day_drawer if next_day_drawer is not None else closing_balance
    shift.notes = notes
    shift.closed_by = closed_by
    shift.closed_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(shift)

    return {
        **{c.name: getattr(shift, c.name) for c in shift.__table__.columns},
        "variance": float(difference),
        "expected_balance": float(expected),
    }


async def close_shift_with_manager(db: AsyncSession, shift_id: uuid.UUID, data, current_user_id: uuid.UUID) -> dict:
    """Close shift with manager override. Verifies manager credentials first."""
    from app.core.security import verify_password
    from app.models.user import User

    mgr = await db.get(User, data.manager_id)
    if not mgr or not mgr.is_manager:
        raise BusinessError("المدير غير موجود أو ليس لديه صلاحية المدير")
    if not verify_password(data.manager_password, mgr.password_hash):
        raise ForbiddenError("كلمة مرور المدير غير صحيحة")

    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("الوردية غير موجودة")
    if shift.status != ShiftStatus.open:
        raise BusinessError("الوردية مغلقة بالفعل")

    summary = await compute_summary(db, shift_id)
    expected = summary["expected_balance"]
    closing = data.closing_balance
    difference = closing - expected

    deposit_amount = closing - (data.next_day_drawer if data.next_day_drawer is not None else closing)

    shift.status = ShiftStatus.closed
    shift.closing_balance = closing
    shift.expected_balance = expected
    shift.difference = difference
    shift.next_day_drawer = data.next_day_drawer if data.next_day_drawer is not None else closing
    shift.notes = data.notes
    shift.closed_by = current_user_id
    shift.deposit_received_by = data.manager_id
    shift.deposit_amount = deposit_amount
    shift.closed_at = datetime.now(timezone.utc)

    # Apply variance to payroll as deduction/bonus
    await _record_payroll_variance(db, shift_id, difference, current_user_id, current_user_id)

    await db.commit()
    await db.refresh(shift)

    return {
        **{c.name: getattr(shift, c.name) for c in shift.__table__.columns},
        "variance": float(difference),
        "expected_balance": float(expected),
    }


async def compute_summary(db: AsyncSession, shift_id: uuid.UUID) -> dict:
    """Compute full financial summary for a shift.

    expected_balance = cash-only balance in the physical drawer.
    Wallet transactions are tracked separately and do NOT affect the drawer.
    """
    shift = await db.get(Shift, shift_id)
    if not shift:
        raise NotFoundError("Shift not found")

    tx_count = await db.execute(select(func.count()).where(DrawerTransaction.shift_id == shift_id))

    # Aggregate ALL drawer transactions by type (for display totals)
    rows = await db.execute(
        select(DrawerTransaction.type, func.sum(DrawerTransaction.amount).label("total"))
        .where(DrawerTransaction.shift_id == shift_id)
        .group_by(DrawerTransaction.type)
    )
    totals: dict[str, Decimal] = {}
    for row in rows:
        key = row.type.value if hasattr(row.type, 'value') else str(row.type)
        totals[key] = Decimal(str(row.total or 0))

    sales            = totals.get("sale", Decimal("0"))
    returns          = totals.get("return", Decimal("0"))
    expenses         = totals.get("expense", Decimal("0"))
    deposits         = totals.get("deposit", Decimal("0"))
    withdrawals      = totals.get("withdrawal", Decimal("0"))
    revenue_delivery = totals.get("revenue_delivery", Decimal("0"))

    # Payment method breakdown (from sales linked to this shift)
    pay_rows = await db.execute(sqlt("""
        SELECT method, wallet_name, wallet_type,
               COUNT(*) as count,
               COALESCE(SUM(sale_total - COALESCE(invoice_discount,0)), 0) as total
        FROM (
            SELECT s.payment_method as method, pw.name as wallet_name, pw.type as wallet_type,
                   s.id, s.discount_amount as invoice_discount,
                   SUM(si.qty * si.unit_price - si.discount) as sale_total
            FROM sales s
            LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
            LEFT JOIN sale_items si ON si.sale_id = s.id
            WHERE s.shift_id = :sid AND s.status = 'confirmed'
            GROUP BY s.id, s.payment_method, pw.name, pw.type, s.discount_amount
        ) sub
        GROUP BY method, wallet_name, wallet_type
    """), {"sid": shift_id})
    payment_breakdown = [dict(r._mapping) for r in pay_rows.fetchall()]

    wallet_sales = sum(float(p["total"]) for p in payment_breakdown if p["method"] != "cash")

    # Wallet deposits/expenses from drawer transactions
    wallet_tx_rows = await db.execute(sqlt("""
        SELECT dt.payment_method, pw.name as wallet_name, pw.type as wallet_type,
               dt.type as tx_type, SUM(dt.amount) as total
        FROM drawer_transactions dt
        LEFT JOIN payment_wallets pw ON pw.id = dt.wallet_id
        WHERE dt.shift_id = :sid AND dt.payment_method = 'wallet'
        AND dt.type IN ('deposit','expense','withdrawal')
        GROUP BY dt.payment_method, pw.name, pw.type, dt.type
    """), {"sid": shift_id})
    wallet_tx_breakdown = [dict(r._mapping) for r in wallet_tx_rows.fetchall()]

    # ── Cash-only expected balance ─────────────────────────────────────────
    # Only transactions with payment_method != 'wallet' affect the physical drawer.
    raw = await db.execute(
        select(DrawerTransaction.type, DrawerTransaction.amount, DrawerTransaction.payment_method)
        .where(DrawerTransaction.shift_id == shift_id)
    )
    cash_sums: dict[str, Decimal] = {}
    for r in raw.fetchall():
        t = r.type.value if hasattr(r.type, 'value') else str(r.type)
        amt = Decimal(str(r.amount or 0))
        pm = r.payment_method or "cash"
        if pm == "wallet":
            continue  # wallet transactions don't touch the physical drawer
        cash_sums[t] = cash_sums.get(t, Decimal("0")) + amt

    cash_sales            = cash_sums.get("sale", Decimal("0"))
    cash_returns          = cash_sums.get("return", Decimal("0"))
    cash_expenses         = cash_sums.get("expense", Decimal("0"))
    cash_deposits         = cash_sums.get("deposit", Decimal("0"))
    cash_withdrawals      = cash_sums.get("withdrawal", Decimal("0"))
    cash_revenue_delivery = cash_sums.get("revenue_delivery", Decimal("0"))

    # This is the ONLY expected_balance used everywhere (cash drawer only)
    expected = (
        shift.initial_amount
        + cash_sales + cash_deposits
        - cash_returns - cash_expenses - cash_withdrawals - cash_revenue_delivery
    )
    cash_in_drawer = expected
    variance = (shift.closing_balance - expected) if shift.closing_balance is not None else None

    return {
        "shift_id": shift_id,
        "initial_amount": shift.initial_amount,
        "sales_total": sales,
        "returns_total": returns,
        "expenses_total": expenses,
        "deposits_total": deposits,
        "withdrawals_total": withdrawals,
        "revenue_delivery_total": revenue_delivery,
        "expected_balance": expected,
        "cash_in_drawer": cash_in_drawer,
        "wallet_total": wallet_sales,
        "closing_balance": shift.closing_balance,
        "variance": variance,
        "transaction_count": tx_count.scalar_one(),
        "payment_breakdown": payment_breakdown,
        "wallet_tx_breakdown": wallet_tx_breakdown,
    }


async def transfer_drawer(db: AsyncSession, shift_id: uuid.UUID, to_user_id: uuid.UUID, amount: Decimal, from_user_id: uuid.UUID | None, notes: str | None = None, closed_by: uuid.UUID | None = None) -> Shift:
    """Hand over drawer to another user: close current shift + open new one."""
    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("Shift not found")
    if shift.status != ShiftStatus.open:
        raise BusinessError("الوردية غير مفتوحة")
    # None = admin/privileged bypass; otherwise enforce ownership
    if from_user_id is not None and shift.cashier_id and shift.cashier_id != from_user_id:
        raise ForbiddenError("الدرج مسجل باسم موظف آخر")

    actor = closed_by or from_user_id or shift.cashier_id
    shift.status = ShiftStatus.closed
    shift.closing_balance = amount
    shift.next_day_drawer = amount
    shift.closed_by = actor
    shift.closed_at = datetime.now(timezone.utc)
    shift.notes = f"تسليم عهدة إلى {to_user_id}. {notes or ''}"
    # Compute and store expected_balance for audit trail
    summary = await compute_summary(db, shift_id)
    expected = summary["expected_balance"]
    shift.expected_balance = expected
    shift.difference = amount - expected

    # Apply variance to payroll as deduction/bonus (same as close_shift_with_manager)
    difference = amount - expected
    await _record_payroll_variance(db, shift_id, difference, actor, actor)

    # Prevent duplicate open shifts for the receiver
    existing = await db.execute(
        select(Shift).where(
            Shift.warehouse_id == shift.warehouse_id,
            Shift.cashier_id == to_user_id,
            Shift.status == ShiftStatus.open
        ).with_for_update()
    )
    if existing.scalar_one_or_none():
        raise BusinessError("المستلم لديه وردية مفتوحة بالفعل في هذا الفرع — يرجى إغلاقها أولاً")

    new_shift = Shift(
        cashier_id=to_user_id,
        initial_amount=amount,
        warehouse_id=shift.warehouse_id,
        supervisor_id=shift.supervisor_id,
        notes=f"استلام عهدة من {from_user_id}",
    )
    db.add(new_shift)

    # Archive handover document
    from app.models.archive import ArchivedDocument, DocType
    from app.models.user import User
    from_user = (await db.execute(select(User.full_name).where(User.id == from_user_id))).scalar()
    to_user = (await db.execute(select(User.full_name).where(User.id == to_user_id))).scalar()
    doc_number = f"HND-{datetime.now(timezone.utc).strftime('%m%d%H%M%S')}-{uuid.uuid4().hex[:4]}"
    db.add(ArchivedDocument(
        doc_number=doc_number,
        doc_type=DocType.shift_handover,
        amount=amount,
        ref_id=shift.id,
        created_by=from_user_id,
        metadata_={
            "from_user": str(from_user_id) if from_user_id else "",
            "to_user": str(to_user_id) if to_user_id else "",
            "from_user_name": from_user or str(from_user_id),
            "to_user_name": to_user or str(to_user_id),
            "amount": float(amount),
            "notes": notes or "",
        }
    ))

    await db.commit()
    await db.refresh(new_shift)
    return new_shift


async def add_transaction(db: AsyncSession, shift_id: uuid.UUID, tx_type: DrawerTxType, amount: Decimal, created_by: uuid.UUID, note: str | None = None, category_id: uuid.UUID | None = None, payment_method: str = "cash", wallet_id: uuid.UUID | None = None, customer_id: uuid.UUID | None = None) -> DrawerTransaction:
    """Add a drawer transaction to an open shift."""
    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
    shift = result.scalar_one_or_none()
    if not shift or shift.status != ShiftStatus.open:
        raise BusinessError("لا توجد وردية مفتوحة")
    if shift.cashier_id and shift.cashier_id != created_by:
        raise ForbiddenError("الدرج مسجل باسم موظف آخر")

    dt = DrawerTransaction(
        shift_id=shift_id,
        type=tx_type,
        amount=amount,
        note=note,
        category_id=category_id,
        payment_method=payment_method or "cash",
        wallet_id=wallet_id,
        created_by=created_by,
    )
    db.add(dt)

    # Update wallet balance if wallet payment
    if wallet_id and payment_method == "wallet":
        from app.services.wallet_service import record_wallet_tx
        if tx_type == DrawerTxType.deposit:
            await record_wallet_tx(db, wallet_id, amount, "deposit", None, note, created_by)
        elif tx_type in (DrawerTxType.expense, DrawerTxType.withdrawal):
            await record_wallet_tx(db, wallet_id, -amount, "expense", None, note, created_by)

    # Customer debt payment
    if customer_id and tx_type == DrawerTxType.deposit:
        from app.models.customer_payment import CustomerPayment
        db.add(CustomerPayment(
            customer_id=customer_id,
            amount=amount,
            note=note,
            created_by=created_by,
        ))
        await db.execute(sqlt(
            "UPDATE customers SET balance = GREATEST(0, COALESCE(balance,0) - :amt) WHERE id = :cid",
        ), {"amt": float(amount), "cid": customer_id})

    await db.commit()
    await db.refresh(dt)
    return dt


async def revenue_delivery(db: AsyncSession, shift_id: uuid.UUID, data, current_user: "User") -> dict:
    """Mid-shift revenue delivery to safe — requires manager authorization."""
    from app.core.security import verify_password
    from app.models.user import User

    mgr = await db.get(User, data.manager_id)
    if not mgr or not mgr.is_manager:
        raise BusinessError("المدير غير موجود أو ليس لديه صلاحية المدير")
    if not verify_password(data.manager_password, mgr.password_hash):
        raise ForbiddenError("كلمة مرور المدير غير صحيحة")

    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("الوردية غير موجودة")
    if shift.status != ShiftStatus.open:
        raise BusinessError("الوردية مغلقة بالفعل")

    # Drawer transaction (withdrawal from drawer to safe)
    dt = DrawerTransaction(
        shift_id=shift_id,
        type=DrawerTxType.revenue_delivery,
        amount=data.amount,
        note=f"تسليم إيرادات إلى الخزنة. {data.notes or ''}",
        created_by=current_user.id,
    )
    db.add(dt)

    # Credit the safe
    safe_name = (await db.execute(sqlt("SELECT name FROM safes WHERE id=:id"), {"id": data.safe_id})).scalar() or ""
    await db.execute(sqlt("UPDATE safes SET balance = balance + :amt WHERE id = :id"),
                     {"amt": float(data.amount), "id": data.safe_id})
    new_balance = (await db.execute(sqlt("SELECT balance FROM safes WHERE id=:id"), {"id": data.safe_id})).scalar()
    await db.execute(sqlt("""
        INSERT INTO safe_transactions (id, safe_id, tx_type, amount, balance_after, note, created_by)
        VALUES (gen_random_uuid(), :sid, 'deposit', :amt, :bal, :note, :uid)
    """), {"sid": data.safe_id, "amt": float(data.amount), "bal": new_balance,
           "note": f"إيرادات من وردية — {data.notes or ''}", "uid": current_user.id})

    # Warehouse name for archive
    wh_name = ""
    if shift.warehouse_id:
        wh_name = (await db.execute(sqlt("SELECT name FROM warehouses WHERE id=:id"), {"id": shift.warehouse_id})).scalar() or ""

    # Archive
    seq = (await db.execute(sqlt("SELECT nextval('invoice_seq')"))).scalar()
    doc_number = f"DEP-{seq:06d}"
    await db.execute(sqlt("""
        INSERT INTO archived_documents (id, doc_number, doc_type, amount, created_by, metadata)
        VALUES (gen_random_uuid(), :doc, 'safe_deposit', :amt, :uid, cast(:meta as jsonb))
    """), {
        "doc": doc_number, "amt": float(data.amount), "uid": current_user.id,
        "meta": json.dumps({
            "safe_name": safe_name,
            "warehouse": wh_name,
            "received_by": mgr.full_name,
            "deposited_by": current_user.full_name,
            "notes": data.notes or "",
            "type": "revenue_delivery",
        })
    })

    await db.commit()
    return {
        "doc_number": doc_number,
        "amount": float(data.amount),
        "safe": safe_name,
        "received_by": mgr.full_name,
    }


async def delete_drawer_transaction(db: AsyncSession, tx_id: uuid.UUID, current_user_id: uuid.UUID) -> None:
    """Delete a drawer transaction (manager only). Reverses wallet if needed."""
    result = await db.execute(sqlt("""
        SELECT dt.*, sh.status as shift_status
        FROM drawer_transactions dt
        JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.id = :id
    """), {"id": tx_id})
    row = result.fetchone()
    if not row:
        raise NotFoundError("العملية غير موجودة")
    tx = dict(row._mapping)
    if tx["shift_status"] == "closed":
        raise BusinessError("لا يمكن حذف معاملة من وردية مغلقة")

    # Reverse wallet balance if wallet payment
    if tx.get("wallet_id") and tx.get("payment_method") == "wallet":
        from app.services.wallet_service import record_wallet_tx
        amt = Decimal(str(tx["amount"]))
        if tx["type"] == "deposit":
            await record_wallet_tx(db, tx["wallet_id"], -amt, "deposit_reversed", tx_id, "حذف دواخل", current_user_id)
        elif tx["type"] in ("expense", "withdrawal"):
            await record_wallet_tx(db, tx["wallet_id"], amt, "expense_reversed", tx_id, "حذف خوارج", current_user_id)

    await db.execute(sqlt("DELETE FROM drawer_transactions WHERE id=:id"), {"id": tx_id})
    await db.commit()
