import uuid
from decimal import Decimal
import logging
from datetime import datetime, timezone
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
        .where(Shift.warehouse_id == data.warehouse_id,
               Shift.cashier_id == cashier_id,
               Shift.status == ShiftStatus.open)
        .with_for_update()
    )
    existing = result.scalar_one_or_none()
    if existing:
        raise BusinessError("لديك وردية مفتوحة بالفعل في هذا الفرع")
    shift = Shift(cashier_id=cashier_id, initial_amount=data.initial_amount,
                  warehouse_id=data.warehouse_id, supervisor_id=getattr(data, 'supervisor_id', None))
    db.add(shift)
    await db.commit()
    await db.refresh(shift)
    return shift


async def close_shift(db: AsyncSession, shift_id: uuid.UUID, data, closed_by: uuid.UUID) -> Shift:
    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
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
    shift.closed_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(shift)
    return shift


async def compute_summary(db: AsyncSession, shift_id: uuid.UUID) -> dict:
    result = await db.execute(select(Shift).where(Shift.id == shift_id))
    shift = result.scalar_one_or_none()
    if not shift:
        raise NotFoundError("Shift not found")
    # Aggregate totals by transaction type
    rows = await db.execute(
        select(DrawerTransaction.type, func.sum(DrawerTransaction.amount).label("total"))
        .where(DrawerTransaction.shift_id == shift_id)
        .group_by(DrawerTransaction.type)
    )
    # Normalize keys to the underlying value (robust to enum or string being returned)
    def _key_of(t):
        # If SQLAlchemy returns an Enum object, use its .value; if it's already a string, use it.
        try:
            return t.value  # Enum with .value (also works for str-subclass enums)
        except Exception:
            return str(t)

    totals = {_key_of(row.type): row.total for row in rows}
    sales      = totals.get(DrawerTxType.sale.value,       Decimal("0")) or Decimal("0")
    returns    = totals.get(DrawerTxType.return_.value,    Decimal("0")) or Decimal("0")
    expenses   = totals.get(DrawerTxType.expense.value,    Decimal("0")) or Decimal("0")
    deposits   = totals.get(DrawerTxType.deposit.value,    Decimal("0")) or Decimal("0")
    withdrawals= totals.get(DrawerTxType.withdrawal.value, Decimal("0")) or Decimal("0")
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

    # Wallet sales total
    wallet_sales = sum(float(p["total"]) for p in payment_breakdown if p["method"] != "cash")

    # Wallet deposits/expenses breakdown
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

    # --- Defensive cash computation & debug logging ---
    # Fetch raw drawer transaction rows to compute cash-only sums (some wallets/sales mix can confuse grouped totals)
    raw_res = await db.execute(
        select(DrawerTransaction.type, DrawerTransaction.amount, DrawerTransaction.payment_method)
        .where(DrawerTransaction.shift_id == shift_id)
    )
    raw_rows = raw_res.fetchall()
    # cash if payment_method is null/"cash" (tolerant to None)
    cash_sums: dict[str, Decimal] = {}
    for r in raw_rows:
        t = _key_of(r.type)
        amt = Decimal(r.amount or 0)
        pm = (r.payment_method or 'cash')
        if pm == 'wallet':
            # skip wallet transactions for cash sums
            continue
        cash_sums[t] = cash_sums.get(t, Decimal('0')) + amt

    # Compute cash_in_drawer explicitly from cash-only transactions
    cash_in_drawer = (shift.initial_amount
                      + cash_sums.get(DrawerTxType.sale.value, Decimal('0'))
                      + cash_sums.get(DrawerTxType.deposit.value, Decimal('0'))
                      - cash_sums.get(DrawerTxType.return_.value, Decimal('0'))
                      - cash_sums.get(DrawerTxType.expense.value, Decimal('0'))
                      - cash_sums.get(DrawerTxType.withdrawal.value, Decimal('0')))

    logger = logging.getLogger(__name__)
    try:
        logger.debug("shift_summary debug shift=%s totals=%s cash_sums=%s payment_breakdown=%s wallet_tx_breakdown=%s",
                     str(shift_id), {k: float(v) for k, v in totals.items()}, {k: float(v) for k, v in cash_sums.items()},
                     payment_breakdown, wallet_tx_breakdown)
    except Exception:
        # Don't let logging break the summary calculation
        logger.debug("shift_summary computed for %s", str(shift_id))

    return {
        "shift_id": shift_id,
        "initial_amount": shift.initial_amount,
        "sales_total": sales,
        "returns_total": returns,
        "expenses_total": expenses,
        "deposits_total": deposits,
        "withdrawals_total": withdrawals,
        "expected_balance": expected,
        # cash_in_drawer: explicit cash-only computation to avoid mixing wallet txns
        "cash_in_drawer": cash_in_drawer,
        "wallet_total": wallet_sales,
        "closing_balance": shift.closing_balance,
        "variance": variance,
        "transaction_count": tx_count.scalar_one(),
        "payment_breakdown": payment_breakdown,
        "wallet_tx_breakdown": wallet_tx_breakdown,
    }


async def transfer_drawer(db: AsyncSession, shift_id: uuid.UUID, to_user_id: uuid.UUID, amount: Decimal, from_user_id: uuid.UUID, notes: str = None) -> Shift:
    result = await db.execute(select(Shift).where(Shift.id == shift_id).with_for_update())
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
    shift.closed_at = datetime.now(timezone.utc)
    shift.notes = f"تسليم عهدة إلى {to_user_id}. {notes or ''}"

    new_shift = Shift(cashier_id=to_user_id, initial_amount=amount,
                      warehouse_id=shift.warehouse_id, supervisor_id=shift.supervisor_id,
                      notes=f"استلام عهدة من {from_user_id}")
    db.add(new_shift)

    # Auto-grant warehouse access to the receiving user
    if shift.warehouse_id:
        from app.models.user import user_warehouses
        existing = await db.execute(
            select(user_warehouses.c.warehouse_id).where(
                user_warehouses.c.user_id == to_user_id,
                user_warehouses.c.warehouse_id == shift.warehouse_id,
            )
        )
        if not existing.scalar_one_or_none():
            await db.execute(
                user_warehouses.insert().values(user_id=to_user_id, warehouse_id=shift.warehouse_id)
            )

    from app.models.archive import ArchivedDocument, DocType
    doc_number = f"HND-{datetime.now(timezone.utc).strftime('%m%d%H%M%S')}"
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

    # Update wallet balance if payment via wallet
    wallet_id = getattr(data, 'wallet_id', None)
    if wallet_id and getattr(data, 'payment_method', 'cash') == 'wallet':
        from app.services.wallet_service import record_wallet_tx
        from decimal import Decimal as D
        if data.type == DrawerTxType.deposit:
            await record_wallet_tx(db, wallet_id, D(str(data.amount)), "deposit",
                                   None, data.note, created_by)
        elif data.type in (DrawerTxType.expense, DrawerTxType.withdrawal):
            await record_wallet_tx(db, wallet_id, -D(str(data.amount)), "expense",
                                   None, data.note, created_by)
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
