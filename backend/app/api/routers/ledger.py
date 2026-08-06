"""
GET /reports/ledger
Returns all sale items + returns + expenses for a date range.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from datetime import datetime
from decimal import Decimal
from app.db.base import get_db
from app.dependencies import get_current_user, verify_warehouse_access
from app.models.user import User
import uuid

router = APIRouter(prefix="/reports/ledger", tags=["ledger"])


def wh_clause(alias: str, warehouse_id: str | None) -> tuple[str, dict]:
    if warehouse_id:
        return f"AND {alias}.warehouse_id = :wh_id", {"wh_id": warehouse_id}
    return "", {}


BASE_SELECT = """
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
      {wh}
    ORDER BY s.created_at, si.id
"""

BASE_RETURN = """
    SELECT
        si.id,
        si.sale_id,
        p.name as product_name,
        p.unit,
        si.qty,
        si.unit_price,
        (si.qty * si.unit_price - si.discount) as line_total,
        s.invoice_number,
        s.created_at,
        c.name as customer_name
    FROM sale_items si
    JOIN sales s ON s.id = si.sale_id
    JOIN products p ON p.id = si.product_id
    LEFT JOIN customers c ON c.id = s.customer_id
    WHERE s.status = 'returned'
      AND s.created_at BETWEEN :start AND :end
      {wh}
    ORDER BY s.created_at
"""

BASE_TX = """
    SELECT dt.id, dt.type, dt.amount, dt.note, dt.created_at,
           pw.name as wallet_name, dt.payment_method
    FROM drawer_transactions dt
    JOIN shifts sh ON sh.id = dt.shift_id
    LEFT JOIN payment_wallets pw ON pw.id = dt.wallet_id
    WHERE dt.type IN ('expense','deposit','withdrawal','revenue_delivery')
      AND dt.created_at BETWEEN :start AND :end
      {wh}
    ORDER BY dt.created_at
"""


@router.get("")
async def ledger(
    from_date: str,
    to_date: str,
    warehouse_id: str | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(100, ge=1, le=500),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    start = datetime.fromisoformat(from_date)
    end   = datetime.fromisoformat(to_date).replace(hour=23, minute=59, second=59)
    params: dict = {"start": start, "end": end}
    offset = (page - 1) * page_size

    wh_s, wh_p = wh_clause("s", warehouse_id)
    params.update(wh_p)

    # Count: sale items
    count_sale_sql = text("""
        SELECT COUNT(*) FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        WHERE s.status = 'confirmed'
          AND s.created_at BETWEEN :start AND :end
          {wh}
    """.format(wh=wh_s))
    total_sale_items = (await db.execute(count_sale_sql, params)).scalar()

    sale_sql = text(BASE_SELECT.format(wh=wh_s) + " OFFSET :offset LIMIT :limit")
    items_rows = await db.execute(sale_sql, {**params, "offset": offset, "limit": page_size})

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
    wh_r, wh_rp = wh_clause("s", warehouse_id)

    count_return_sql = text("""
        SELECT COUNT(*) FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        WHERE s.status = 'returned'
          AND s.created_at BETWEEN :start AND :end
          {wh}
    """.format(wh=wh_r))
    total_returns_count = (await db.execute(count_return_sql, {**params, **wh_rp})).scalar()

    ret_sql = text(BASE_RETURN.format(wh=wh_r) + " OFFSET :offset LIMIT :limit")
    ret_rows = await db.execute(ret_sql, {**params, **wh_rp, "offset": offset, "limit": page_size})

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
    wh_t, wh_tp = wh_clause("sh", warehouse_id)

    count_tx_sql = text("""
        SELECT COUNT(*) FROM drawer_transactions dt
        JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type IN ('expense','deposit','withdrawal','revenue_delivery')
          AND dt.created_at BETWEEN :start AND :end
          {wh}
    """.format(wh=wh_t))
    total_tx_count = (await db.execute(count_tx_sql, {**params, **wh_tp})).scalar()

    tx_sql = text(BASE_TX.format(wh=wh_t) + " OFFSET :offset LIMIT :limit")
    tx_rows = await db.execute(tx_sql, {**params, **wh_tp, "offset": offset, "limit": page_size})

    TX_AR = {"expense": "خوارج", "deposit": "دواخل", "withdrawal": "سحب", "revenue_delivery": "توريد إيرادات"}
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
    total_revenue_delivery = sum(e["amount"] for e in expenses if e["entry_type"] == "revenue_delivery")

    # Cash-only totals from drawer_transactions (excluding wallet)
    cash_expenses = sum(e["amount"] for e in expenses if e["entry_type"] in ("expense","withdrawal") and e["payment_method"] == "نقدي")
    cash_deposits = sum(e["amount"] for e in expenses if e["entry_type"] == "deposit" and e["payment_method"] == "نقدي")
    cash_revenue_delivery = sum(e["amount"] for e in expenses if e["entry_type"] == "revenue_delivery" and e["payment_method"] == "نقدي")

    # Cash drawer sale/return totals from drawer_transactions (matches physical drawer)
    cash_drawer_sql = text(f"""
        SELECT type, SUM(amount) as total
        FROM drawer_transactions dt
        JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type IN ('sale','return_')
          AND (dt.payment_method IS NULL OR dt.payment_method = '' OR dt.payment_method = 'cash')
          AND dt.created_at BETWEEN :start AND :end
          {{wh}}
        GROUP BY dt.type
    """.format(wh=wh_t))
    cash_drawer_rows = await db.execute(cash_drawer_sql, {**params, **wh_tp})
    cash_drawer_sales = 0
    cash_drawer_returns = 0
    for r in cash_drawer_rows.fetchall():
        if r.type == 'sale':
            cash_drawer_sales = float(r.total or 0)
        if r.type == 'return_':
            cash_drawer_returns = float(r.total or 0)

    sale_pages = (total_sale_items + page_size - 1) // page_size
    return_pages = (total_returns_count + page_size - 1) // page_size
    tx_pages = (total_tx_count + page_size - 1) // page_size

    # Payment breakdown (cash / wallet / credit) from sale-level data
    cls_wh, cls_whp = wh_clause("s", warehouse_id)
    cls_rows = await db.execute(text(f"""
        SELECT s.id, s.payment_method, s.wallet_id, s.is_credit,
               COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) as item_total,
               COUNT(sp.id) > 0 as has_payments,
               COALESCE(SUM(sp.amount) FILTER (WHERE sp.method = 'cash'), 0) as cash_pmt,
               COALESCE(SUM(sp.amount) FILTER (WHERE sp.wallet_id IS NOT NULL), 0) as wallet_pmt,
               COALESCE(SUM(sp.amount) FILTER (WHERE sp.method = 'credit'), 0) as credit_pmt
        FROM sales s
        JOIN sale_items si ON si.sale_id = s.id
        LEFT JOIN sale_payments sp ON sp.sale_id = s.id
        WHERE s.status = 'confirmed'
          AND s.created_at BETWEEN :start AND :end
          {{wh}}
        GROUP BY s.id
    """.format(wh=cls_wh)), {**params, **cls_whp})
    cash_sales = 0.0
    wallet_sales = 0.0
    credit_sales = 0.0
    for r in cls_rows.fetchall():
        item_total = float(r.item_total)
        if r.has_payments:
            cash_sales += float(r.cash_pmt)
            wallet_sales += float(r.wallet_pmt)
            credit_sales += float(r.credit_pmt)
        elif r.wallet_id:
            wallet_sales += item_total
        elif r.is_credit or r.payment_method == 'credit':
            credit_sales += item_total
        else:
            cash_sales += item_total


    # Opening balance: always use next_day_drawer from the last shift closed BEFORE the period start.
    opening = Decimal("0")
    if warehouse_id:
        shift_row = await db.execute(text("""
            SELECT COALESCE(next_day_drawer, closing_balance, 0) as opening_amt
            FROM shifts
            WHERE warehouse_id = :wh_id
              AND status = 'closed'
              AND closed_at < :start
            ORDER BY closed_at DESC
            LIMIT 1
        """), {"wh_id": warehouse_id, "start": start})
        s = shift_row.fetchone()
        if s:
            opening = Decimal(str(s.opening_amt))
        else:
            shift_row2 = await db.execute(text("""
                SELECT initial_amount
                FROM shifts
                WHERE warehouse_id = :wh_id
                  AND started_at BETWEEN :start AND :end
                ORDER BY started_at ASC
                LIMIT 1
            """), {"wh_id": warehouse_id, "start": start, "end": end})
            s2 = shift_row2.fetchone()
            if s2:
                opening = Decimal(str(s2.initial_amount))
    net_sales = total_sales - total_returns - total_expenses - total_revenue_delivery
    net = total_sales - total_returns + total_deposits - total_expenses - total_revenue_delivery

    # Cash-only closing (matches physical drawer from drawer_transactions)
    cash_closing = float(opening) + cash_drawer_sales - cash_drawer_returns + cash_deposits - cash_expenses - cash_revenue_delivery

    return {
        "sale_items": sale_items,
        "returns": returns,
        "expenses": expenses,
        "summary": {
            "opening_balance": float(opening),
            "total_sales": total_sales,
            "cash_sales": cash_sales,
            "wallet_sales": wallet_sales,
            "credit_sales": credit_sales,
            "total_returns": total_returns,
            "total_expenses": total_expenses,
            "total_deposits": total_deposits,
            "total_revenue_delivery": total_revenue_delivery,
            "net": net_sales,
            "net_with_deposits": net,
            "closing": float(opening) + net,
            "cash_closing": cash_closing,
        },
        "pagination": {
            "sales": {"total": total_sale_items, "page": page, "size": page_size, "pages": sale_pages},
            "returns": {"total": total_returns_count, "page": page, "size": page_size, "pages": return_pages},
            "expenses": {"total": total_tx_count, "page": page, "size": page_size, "pages": tx_pages},
        },
        "from_date": from_date,
        "to_date": to_date,
    }
