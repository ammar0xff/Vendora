"""Admin overview endpoint — company-wide financial summary."""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import require_role

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/overview")
async def company_overview(
    from_date: str = Query(default=None),
    to_date: str = Query(default=None),
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin", "manager"))
):
    from datetime import date as _date
    today = _date.today().isoformat()
    fd = from_date or today
    td = to_date or today
    # Convert to date objects for asyncpg
    fd_date = _date.fromisoformat(fd)
    td_date = _date.fromisoformat(td)

    # 1. Sales + profit per branch
    branches = await db.execute(text("""
        SELECT w.id, w.name, w.warehouse_type,
            COUNT(DISTINCT s.id) as invoice_count,
            COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) - COALESCE(MAX(s.discount_amount),0) as revenue,
            COALESCE(SUM(si.qty * si.unit_price - si.discount) - SUM(si.qty * si.unit_cost), 0) as gross_profit,
            COALESCE(SUM(CASE WHEN s.is_credit THEN si.qty*si.unit_price-si.discount ELSE 0 END), 0) as credit_sales,
            COALESCE(SUM(CASE WHEN NOT s.is_credit THEN si.qty*si.unit_price-si.discount ELSE 0 END), 0) as cash_sales
        FROM warehouses w
        LEFT JOIN sales s ON s.warehouse_id = w.id AND s.status = 'confirmed'
            AND DATE(s.created_at) BETWEEN :fd AND :td
        LEFT JOIN sale_items si ON si.sale_id = s.id
        GROUP BY w.id, w.name, w.warehouse_type
        ORDER BY revenue DESC
    """), {"fd": fd_date, "td": td_date})
    branches_data = [dict(r._mapping) for r in branches.fetchall()]

    # 2. Stock value per warehouse (cost-based)
    stock = await db.execute(text("""
        SELECT w.id, w.name, w.warehouse_type,
            COALESCE(SUM(
                CASE WHEN sm.movement_type IN ('purchase','opening_stock','return_in','adjustment_in','transfer_in')
                     THEN sm.qty ELSE -sm.qty END * p.cost_price
            ), 0) as stock_cost_value,
            COALESCE(SUM(
                CASE WHEN sm.movement_type IN ('purchase','opening_stock','return_in','adjustment_in','transfer_in')
                     THEN sm.qty ELSE -sm.qty END * p.retail_price
            ), 0) as stock_retail_value,
            COALESCE(SUM(
                CASE WHEN sm.movement_type IN ('purchase','opening_stock','return_in','adjustment_in','transfer_in')
                     THEN sm.qty ELSE -sm.qty END
            ), 0) as total_units
        FROM warehouses w
        LEFT JOIN stock_movements sm ON sm.warehouse_id = w.id
        LEFT JOIN products p ON p.id = sm.product_id
        GROUP BY w.id, w.name, w.warehouse_type
        ORDER BY stock_cost_value DESC
    """))
    stock_data = [dict(r._mapping) for r in stock.fetchall()]

    # 3. Low stock items (total across all warehouses)
    low_stock = await db.execute(text("""
        SELECT p.name, p.unit, p.reorder_point,
            COALESCE(SUM(CASE WHEN sm.movement_type IN ('purchase','opening_stock','return_in','adjustment_in','transfer_in')
                              THEN sm.qty ELSE -sm.qty END), 0) as total_qty
        FROM products p
        LEFT JOIN stock_movements sm ON sm.product_id = p.id
        WHERE p.is_active = true AND p.reorder_point > 0
        GROUP BY p.id, p.name, p.unit, p.reorder_point
        HAVING COALESCE(SUM(CASE WHEN sm.movement_type IN ('purchase','opening_stock','return_in','adjustment_in','transfer_in')
                                  THEN sm.qty ELSE -sm.qty END), 0) <= p.reorder_point
        ORDER BY total_qty ASC LIMIT 10
    """))
    low_stock_data = [dict(r._mapping) for r in low_stock.fetchall()]

    # 4. Customer debts (top 10)
    customer_debts = await db.execute(text("""
        SELECT c.id, c.name, c.phone,
            COALESCE(SUM(si.qty*si.unit_price - si.discount), 0) -
            COALESCE((SELECT SUM(amount) FROM customer_payments WHERE customer_id = c.id), 0) as balance_due
        FROM customers c
        JOIN sales s ON s.customer_id = c.id AND s.is_credit = true AND s.status = 'confirmed'
        JOIN sale_items si ON si.sale_id = s.id
        GROUP BY c.id, c.name, c.phone
        HAVING COALESCE(SUM(si.qty*si.unit_price - si.discount), 0) -
               COALESCE((SELECT SUM(amount) FROM customer_payments WHERE customer_id = c.id), 0) > 0
        ORDER BY balance_due DESC LIMIT 10
    """))
    customer_debts_data = [dict(r._mapping) for r in customer_debts.fetchall()]

    # 5. Supplier debts
    supplier_debts = await db.execute(text("""
        SELECT id, name, phone, balance
        FROM suppliers WHERE balance > 0
        ORDER BY balance DESC LIMIT 10
    """))
    supplier_debts_data = [dict(r._mapping) for r in supplier_debts.fetchall()]

    # 6. Cash in drawers (open shifts)
    cash_drawers = await db.execute(text("""
        SELECT w.name, s.initial_amount,
            COALESCE((SELECT SUM(CASE WHEN dt.type='sale' THEN dt.amount
                                      WHEN dt.type IN ('expense','withdrawal') THEN -dt.amount
                                      WHEN dt.type='deposit' THEN dt.amount ELSE 0 END)
                      FROM drawer_transactions dt WHERE dt.shift_id = s.id), 0) as net_movement
        FROM shifts s JOIN warehouses w ON w.id = s.warehouse_id
        WHERE s.status = 'open'
        ORDER BY w.name
    """))
    cash_data = [dict(r._mapping) for r in cash_drawers.fetchall()]

    # 6b. Safes total
    safes_total_row = await db.execute(text("SELECT COALESCE(SUM(balance),0) FROM safes WHERE is_active=true"))
    total_safes = float(safes_total_row.scalar() or 0)

    # 7. Totals
    total_revenue = sum(float(b['revenue'] or 0) for b in branches_data)
    total_profit = sum(float(b['gross_profit'] or 0) for b in branches_data)
    total_stock_cost = sum(float(s['stock_cost_value'] or 0) for s in stock_data)
    total_stock_retail = sum(float(s['stock_retail_value'] or 0) for s in stock_data)
    total_customer_debt = sum(float(d['balance_due'] or 0) for d in customer_debts_data)
    total_supplier_debt = sum(float(d['balance'] or 0) for d in supplier_debts_data)
    total_cash = sum(float(c['initial_amount'] or 0) + float(c['net_movement'] or 0) for c in cash_data)

    return {
        "period": {"from": fd, "to": td},
        "summary": {
            "total_revenue": total_revenue,
            "total_profit": total_profit,
            "profit_margin": round((total_profit / total_revenue * 100) if total_revenue > 0 else 0, 1),
            "total_stock_cost": total_stock_cost,
            "total_stock_retail": total_stock_retail,
            "total_customer_debt": total_customer_debt,
            "total_supplier_debt": total_supplier_debt,
            "total_cash_in_drawers": total_cash,
            "total_safes_balance": total_safes,
            # Capital = stock + cash - supplier debts
            "net_capital": total_stock_cost + total_cash + total_safes - total_supplier_debt,
        },
        "branches": branches_data,
        "stock_per_warehouse": [s for s in stock_data if float(s['stock_cost_value'] or 0) > 0],
        "low_stock": low_stock_data,
        "customer_debts": customer_debts_data,
        "supplier_debts": supplier_debts_data,
        "cash_drawers": cash_data,
    }
