"""
GET /reports/ledger
Returns all sale items + returns + expenses for a date range.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from datetime import datetime
from app.db.base import get_db
from app.dependencies import require_role
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
    params: dict = {"start": start, "end": end}
    if warehouse_id:
        params["wh_id"] = uuid.UUID(warehouse_id)

    # Sale items
    items_rows = await db.execute(text("""
        SELECT
            si.id,
            si.sale_id,
            p.name as product_name,
            p.unit,
            si.qty,
            si.unit_price,
            (si.qty * si.unit_price - si.discount) as line_total,
            COALESCE(s.payment_method, 'cash') as payment_method,
            pw.name as wallet_name,
            s.invoice_number,
            s.created_at,
            c.name as customer_name,
            'sale' as entry_type
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        LEFT JOIN customers c ON c.id = s.customer_id
        LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
        WHERE s.status = 'confirmed'
          AND s.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        ORDER BY s.created_at, si.id
    """), params)

    sale_items = []
    for r in items_rows.fetchall():
        d = dict(r._mapping)
        pm = d["wallet_name"] or ("نقدي" if d["payment_method"] == "cash" else d["payment_method"])
        sale_items.append({
            "item_id": str(d["id"]),
            "sale_id": str(d["sale_id"]) if "sale_id" in d else None,
            "product_name": d["product_name"],
            "unit": d["unit"],
            "qty": float(d["qty"]),
            "unit_price": float(d["unit_price"]),
            "total": float(d["line_total"]),
            "payment_method": pm,
            "invoice_number": d["invoice_number"],
            "customer": d["customer_name"] or "عميل عادي",
            "date": d["created_at"].isoformat(),
            "entry_type": "sale",
        })

    # Returns
    ret_rows = await db.execute(text("""
        SELECT
            si.id,
            si.sale_id,
            p.name as product_name,
            p.unit,
            si.qty,
            si.unit_price,
            (si.qty * si.unit_price) as line_total,
            s.invoice_number,
            s.created_at,
            c.name as customer_name
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        LEFT JOIN customers c ON c.id = s.customer_id
        WHERE s.status = 'returned'
          AND s.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        ORDER BY s.created_at
    """), params)

    returns = []
    for r in ret_rows.fetchall():
        d = dict(r._mapping)
        returns.append({
            "item_id": str(d["id"]),
            "sale_id": str(d["sale_id"]) if "sale_id" in d else None,
            "product_name": d["product_name"],
            "unit": d["unit"],
            "qty": float(d["qty"]),
            "unit_price": float(d["unit_price"]),
            "total": float(d["line_total"]),
            "invoice_number": d["invoice_number"],
            "customer": d["customer_name"] or "عميل عادي",
            "date": d["created_at"].isoformat(),
            "entry_type": "return",
        })

    # Expenses / deposits / withdrawals
    tx_rows = await db.execute(text("""
        SELECT dt.id, dt.type, dt.amount, dt.note, dt.created_at,
               pw.name as wallet_name, dt.payment_method
        FROM drawer_transactions dt
        JOIN shifts sh ON sh.id = dt.shift_id
        LEFT JOIN payment_wallets pw ON pw.id = dt.wallet_id
        WHERE dt.type IN ('expense','deposit','withdrawal')
          AND dt.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR sh.warehouse_id = :wh_id)
        ORDER BY dt.created_at
    """), params)

    TX_AR = {"expense": "خوارج", "deposit": "دواخل", "withdrawal": "سحب"}
    expenses = []
    for r in tx_rows.fetchall():
        d = dict(r._mapping)
        pm = d["wallet_name"] or ("نقدي" if (d["payment_method"] or "cash") == "cash" else d["payment_method"])
        expenses.append({
            "tx_id": str(d["id"]),
            "type_ar": TX_AR.get(d["type"], d["type"]),
            "note": d["note"] or "",
            "amount": float(d["amount"]),
            "payment_method": pm,
            "date": d["created_at"].isoformat(),
            "entry_type": d["type"],
        })

    total_sales   = sum(i["total"] for i in sale_items)
    total_returns = sum(i["total"] for i in returns)
    total_expenses= sum(e["amount"] for e in expenses if e["entry_type"] in ("expense","withdrawal"))
    total_deposits= sum(e["amount"] for e in expenses if e["entry_type"] == "deposit")

    return {
        "sale_items": sale_items,
        "returns": returns,
        "expenses": expenses,
        "summary": {
            "total_sales": total_sales,
            "total_returns": total_returns,
            "total_expenses": total_expenses,
            "total_deposits": total_deposits,
            "net": total_sales - total_returns + total_deposits - total_expenses,
        },
        "from_date": from_date,
        "to_date": to_date,
    }
