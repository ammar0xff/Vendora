import uuid
from decimal import Decimal
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.shift import Shift, ShiftStatus, DrawerTransaction, DrawerTxType
from app.core.exceptions import BusinessError, NotFoundError
from app.core.exceptions import ForbiddenError


def _assert_owner(shift: Shift, user_id: uuid.UUID):
    """Only the cashier who currently holds the drawer can operate on it."""
    if shift.cashier_id and shift.cashier_id != user_id:
        raise ForbiddenError("الدرج مسجل باسم موظف آخر — لا يمكنك الوصول إليه")


async def open_shift(db: AsyncSession, cashier_id: uuid.UUID, data) -> Shift:
    result = await db.execute(
        select(Shift)
        .where(Shift.warehouse_id == data.warehouse_id, Shift.status == ShiftStatus.open)
        .order_by(Shift.started_at.desc())
    )
    existing = result.scalars().all()
    for old in existing[1:]:
        old.status = ShiftStatus.closed; old.closed_at = datetime.utcnow()
    if existing:
        raise BusinessError("يوجد وردية مفتوحة بالفعل في هذا الفرع")
    shift = Shift(cashier_id=cashier_id, initial_amount=data.initial_amount,
                  warehouse_id=data.warehouse_id, supervisor_id=getattr(data, 'supervisor_id', None))
    db.add(shift)
    await db.commit()
    await db.refresh(shift)
    return shift


async def close_shift(db: AsyncSession, shift_id: uuid.UUID, data, closed_by: uuid.UUID) -> Shift:
    result = await db.execute(select(Shift).where(Shift.id == shift_id))
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("Shift not found")
    if shift.status != ShiftStatus.open:
        raise BusinessError("Shift is already closed")
    _assert_owner(shift, closed_by)
    shift.status = ShiftStatus.closed
    shift.closing_balance = data.closing_balance
    shift.next_day_drawer = data.next_day_drawer
    shift.notes = data.notes
    shift.closed_by = closed_by
    shift.closed_at = datetime.utcnow()
    await db.commit()
    await db.refresh(shift)
    return shift


async def compute_summary(db: AsyncSession, shift_id: uuid.UUID) -> dict:
    result = await db.execute(select(Shift).where(Shift.id == shift_id))
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("Shift not found")
    rows = await db.execute(
        select(DrawerTransaction.type, func.sum(DrawerTransaction.amount).label("total"))
        .where(DrawerTransaction.shift_id == shift_id)
        .group_by(DrawerTransaction.type)
    )
    totals = {row.type: row.total for row in rows}
    sales      = totals.get(DrawerTxType.sale,       Decimal("0")) or Decimal("0")
    returns    = totals.get(DrawerTxType.return_,     Decimal("0")) or Decimal("0")
    expenses   = totals.get(DrawerTxType.expense,     Decimal("0")) or Decimal("0")
    deposits   = totals.get(DrawerTxType.deposit,     Decimal("0")) or Decimal("0")
    withdrawals= totals.get(DrawerTxType.withdrawal,  Decimal("0")) or Decimal("0")
    expected = shift.initial_amount + sales + deposits - returns - expenses - withdrawals
    variance = (shift.closing_balance - expected) if shift.closing_balance is not None else None
    tx_count = await db.execute(select(func.count()).where(DrawerTransaction.shift_id == shift_id))

    # Payment method breakdown
    from sqlalchemy import text as sqlt
    pay_rows = await db.execute(sqlt("""
        SELECT COALESCE(s.payment_method, 'cash') as method,
               pw.name as wallet_name, pw.type as wallet_type,
               COUNT(s.id) as count,
               COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) - COALESCE(MAX(s.discount_amount),0) as total
        FROM sales s
        LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
        LEFT JOIN sale_items si ON si.sale_id = s.id
        WHERE s.shift_id = :sid AND s.status = 'confirmed'
        GROUP BY s.payment_method, pw.name, pw.type
    """), {"sid": shift_id})
    payment_breakdown = [dict(r._mapping) for r in pay_rows.fetchall()]

    # Cash-only total (what's actually in the drawer — excludes wallets)
    cash_sales = sum(float(p["total"]) for p in payment_breakdown if p["method"] == "cash")
    wallet_sales = sum(float(p["total"]) for p in payment_breakdown if p["method"] != "cash")

    return {
        "shift_id": shift_id,
        "initial_amount": shift.initial_amount,
        "sales_total": sales,
        "returns_total": returns,
        "expenses_total": expenses,
        "deposits_total": deposits,
        "withdrawals_total": withdrawals,
        "expected_balance": expected,
        "cash_in_drawer": float(shift.initial_amount) + cash_sales + float(deposits) - float(returns) - float(expenses) - float(withdrawals),
        "wallet_total": wallet_sales,
        "closing_balance": shift.closing_balance,
        "variance": variance,
        "transaction_count": tx_count.scalar_one(),
        "payment_breakdown": payment_breakdown,
    }


async def transfer_drawer(db: AsyncSession, shift_id: uuid.UUID, to_user_id: uuid.UUID, amount: Decimal, from_user_id: uuid.UUID, notes: str = None) -> Shift:
    result = await db.execute(select(Shift).where(Shift.id == shift_id))
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("Shift not found")
    if shift.status != ShiftStatus.open:
        raise BusinessError("Shift is not open")
    _assert_owner(shift, from_user_id)

    shift.status = ShiftStatus.closed
    shift.closing_balance = amount
    shift.next_day_drawer = amount
    shift.closed_by = from_user_id
    shift.closed_at = datetime.utcnow()
    shift.notes = f"تسليم عهدة إلى {to_user_id}. {notes or ''}"

    new_shift = Shift(cashier_id=to_user_id, initial_amount=amount,
                      warehouse_id=shift.warehouse_id, supervisor_id=shift.supervisor_id,
                      notes=f"استلام عهدة من {from_user_id}")
    db.add(new_shift)
    from app.models.archive import ArchivedDocument, DocType
    doc_number = f"HND-{datetime.utcnow().strftime('%m%d%H%M%S')}"
    from sqlalchemy import select as sa_select
    from app.models.user import User
    from_user_row = (await db.execute(sa_select(User.full_name).where(User.id == from_user_id))).scalar()
    to_user_row   = (await db.execute(sa_select(User.full_name).where(User.id == to_user_id))).scalar()
    db.add(ArchivedDocument(doc_number=doc_number, doc_type=DocType.shift_handover,
                            amount=amount, ref_id=shift.id, created_by=from_user_id,
                            metadata_={"from_user": str(from_user_id), "to_user": str(to_user_id),
                                       "from_user_name": from_user_row or str(from_user_id),
                                       "to_user_name": to_user_row or str(to_user_id),
                                       "amount": float(amount), "notes": notes or ""}))
    await db.commit()
    await db.refresh(new_shift)
    return new_shift


async def add_transaction(db: AsyncSession, shift_id: uuid.UUID, data, created_by: uuid.UUID) -> DrawerTransaction:
    result = await db.execute(select(Shift).where(Shift.id == shift_id, Shift.status == ShiftStatus.open))
    shift = result.scalar_one_or_none()
    if not shift:
        raise BusinessError("No open shift found")
    _assert_owner(shift, created_by)
    dt = DrawerTransaction(shift_id=shift_id, type=data.type, amount=data.amount, note=data.note,
                           category_id=getattr(data, 'category_id', None),
                           payment_method=getattr(data, 'payment_method', 'cash') or 'cash',
                           wallet_id=getattr(data, 'wallet_id', None),
                           created_by=created_by)
    db.add(dt)
    # If this is a customer debt payment, record it and reduce customer balance
    if getattr(data, 'customer_id', None) and data.type == DrawerTxType.deposit:
        from app.models.customer_payment import CustomerPayment
        from sqlalchemy import text as sqlt
        db.add(CustomerPayment(customer_id=data.customer_id, amount=data.amount,
                               note=data.note, created_by=created_by))
        # Reduce customer balance
        await db.execute(sqlt(
            "UPDATE customers SET balance = GREATEST(0, COALESCE(balance,0) - :amt) WHERE id = :cid"
        ), {"amt": float(data.amount), "cid": data.customer_id})
    await db.commit()
    await db.refresh(dt)
    return dt
