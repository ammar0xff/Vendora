"""
GET /reports/ledger
Returns all drawer transactions + sales + customer payments for a date range.
Used for دفتر الأستاذ.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, date
from app.db.base import get_db
from app.dependencies import require_role
from app.models.shift import DrawerTransaction, Shift, DrawerTxType
from app.models.sale import Sale, SaleItem, SaleStatus
from app.models.party import Customer
from app.models.warehouse import Warehouse
import uuid

router = APIRouter(prefix="/reports/ledger", tags=["ledger"])


@router.get("")
async def ledger(
    from_date: str,
    to_date: str,
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin", "cashier", "manager", "accountant")),
):
    start = datetime.fromisoformat(from_date)
    end   = datetime.fromisoformat(to_date).replace(hour=23, minute=59, second=59)

    entries = []

    # 1. Sales
    sales_q = select(Sale, Customer.name.label("cname"), Warehouse.name.label("wh_name")).outerjoin(Customer, Sale.customer_id == Customer.id).outerjoin(Warehouse, Sale.warehouse_id == Warehouse.id)\
        .where(Sale.created_at.between(start, end), Sale.status == SaleStatus.confirmed)
    if warehouse_id:
        sales_q = sales_q.where(Sale.warehouse_id == uuid.UUID(warehouse_id))
    for sale, cname, wh_name in (await db.execute(sales_q)).all():
        items = (await db.execute(select(SaleItem).where(SaleItem.sale_id == sale.id))).scalars().all()
        total = sum(float(i.qty) * float(i.unit_price) - float(i.discount) for i in items)
        entries.append({"type": "sale", "ref": sale.invoice_number, "party": cname or "عميل عادي",
                        "warehouse": wh_name or "",
                        "debit": 0, "credit": total, "date": sale.created_at.isoformat(), "note": sale.notes or ""})

    # 2. Returns
    ret_q = select(Sale, Customer.name.label("cname"), Warehouse.name.label("wh_name")).outerjoin(Customer, Sale.customer_id == Customer.id).outerjoin(Warehouse, Sale.warehouse_id == Warehouse.id)\
        .where(Sale.created_at.between(start, end), Sale.status == SaleStatus.returned)
    if warehouse_id:
        ret_q = ret_q.where(Sale.warehouse_id == uuid.UUID(warehouse_id))
    for sale, cname, wh_name in (await db.execute(ret_q)).all():
        items = (await db.execute(select(SaleItem).where(SaleItem.sale_id == sale.id))).scalars().all()
        total = sum(float(i.qty) * float(i.unit_price) for i in items)
        entries.append({"type": "return", "ref": sale.invoice_number, "party": cname or "عميل عادي",
                        "warehouse": wh_name or "",
                        "debit": total, "credit": 0, "date": sale.created_at.isoformat(), "note": sale.notes or ""})

    # 3. Drawer transactions (expenses, deposits, withdrawals)
    tx_q = select(DrawerTransaction, Shift.warehouse_id, Warehouse.name.label("wh_name"))\
        .join(Shift, DrawerTransaction.shift_id == Shift.id)\
        .join(Warehouse, Shift.warehouse_id == Warehouse.id)\
        .where(DrawerTransaction.created_at.between(start, end),
               DrawerTransaction.type.in_([DrawerTxType.expense, DrawerTxType.deposit, DrawerTxType.withdrawal]))
    if warehouse_id:
        tx_q = tx_q.where(Shift.warehouse_id == uuid.UUID(warehouse_id))
    for tx, wh_id, wh_name in (await db.execute(tx_q)).all():
        is_debit = tx.type in (DrawerTxType.expense, DrawerTxType.withdrawal)
        entries.append({"type": tx.type, "ref": str(tx.id)[:8], "party": "",
                        "warehouse": wh_name or "",
                        "debit": float(tx.amount) if is_debit else 0,
                        "credit": float(tx.amount) if not is_debit else 0,
                        "date": tx.created_at.isoformat(), "note": tx.note or ""})

    entries.sort(key=lambda x: x["date"])

    # Running balance
    balance = 0.0
    for e in entries:
        balance += e["credit"] - e["debit"]
        e["balance"] = round(balance, 2)

    total_credit = sum(e["credit"] for e in entries)
    total_debit  = sum(e["debit"]  for e in entries)

    return {
        "entries": entries,
        "summary": {"total_credit": total_credit, "total_debit": total_debit, "net": total_credit - total_debit},
        "from_date": from_date, "to_date": to_date,
    }
