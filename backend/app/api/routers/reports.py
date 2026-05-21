from datetime import date
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.db.base import get_db
from app.models.sale import Sale, SaleItem
from app.services import report_service
from app.dependencies import require_role

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/sales/daily")
async def daily_sales(target_date: date = Query(default=date.today()), warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "cashier", "manager", "accountant"))):
    return await report_service.daily_sales(db, target_date, warehouse_id=warehouse_id)


@router.get("/sales/monthly")
async def monthly_sales(year: int, month: int, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "cashier", "manager", "accountant"))):
    return await report_service.monthly_sales(db, year, month, warehouse_id=warehouse_id)


@router.get("/sales/top-products")
async def top_products(from_date: str, to_date: str, limit: int = 10, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "manager", "accountant"))):
    return await report_service.top_products(db, from_date, to_date, limit)


@router.get("/sales/by-cashier")
async def sales_by_cashier(from_date: str, to_date: str, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "cashier", "manager", "accountant"))):
    from datetime import datetime
    from app.models.user import User as UserModel
    import uuid as _uuid
    start = datetime.fromisoformat(from_date)
    end   = datetime.fromisoformat(to_date)
    q = (
        select(
            UserModel.id, UserModel.full_name,
            func.count(Sale.id.distinct()).label("invoice_count"),
            func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_price - SaleItem.discount), 0).label("total_sales"),
        )
        .join(Sale, Sale.cashier_id == UserModel.id)
        .join(SaleItem, SaleItem.sale_id == Sale.id)
        .where(Sale.created_at.between(start, end))
        .where(Sale.status == "confirmed")
        .group_by(UserModel.id, UserModel.full_name)
        .order_by(func.sum(SaleItem.qty * SaleItem.unit_price).desc())
    )
    if warehouse_id:
        q = q.where(Sale.warehouse_id == _uuid.UUID(warehouse_id))
    result = await db.execute(q)
    return [{"cashier_id": str(r.id), "cashier_name": r.full_name, "invoice_count": r.invoice_count, "total_sales": r.total_sales} for r in result.all()]


@router.get("/profit")
async def profit(from_date: str, to_date: str, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "manager", "accountant"))):
    return await report_service.profit_report(db, from_date, to_date, warehouse_id=warehouse_id)


@router.get("/inventory/print")
async def inventory_print_report(warehouse_id: str, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "cashier", "manager", "accountant"))):
    """تقرير المخزون الكامل للطباعة."""
    from app.models.product import Product, Subcategory, Category
    from app.models.stock import StockMovement
    from app.models.warehouse import Warehouse
    from app.models.settings import StoreSetting
    from sqlalchemy import case as sa_case
    import uuid as _uuid
    import datetime as _dt

    wh_id = _uuid.UUID(warehouse_id)
    wh = (await db.execute(select(Warehouse).where(Warehouse.id == wh_id))).scalar_one_or_none()

    IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
    balance_subq = (
        select(StockMovement.product_id,
               func.coalesce(func.sum(sa_case((StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty), else_=-StockMovement.qty)), 0).label("qty"))
        .where(StockMovement.warehouse_id == wh_id)
        .group_by(StockMovement.product_id).subquery()
    )
    rows = await db.execute(
        select(Product, Subcategory.name.label("sub_name"), Category.name.label("cat_name"), balance_subq.c.qty)
        .join(Subcategory, Product.subcategory_id == Subcategory.id)
        .join(Category, Subcategory.category_id == Category.id)
        .outerjoin(balance_subq, Product.id == balance_subq.c.product_id)
        .where(Product.is_active)
        .order_by(Category.name, Subcategory.name, Product.name)
    )
    settings = {r.key: r.value for r in (await db.execute(select(StoreSetting))).scalars().all()}

    items, total_cost, total_retail = [], 0.0, 0.0
    for p, sub_name, cat_name, qty in rows.all():
        q = float(qty or 0)
        cv, rv = q * float(p.cost_price), q * float(p.retail_price)
        total_cost += cv
        total_retail += rv
        items.append({"category": cat_name, "subcategory": sub_name, "name": p.name, "unit": p.unit,
                      "qty": q, "cost_price": float(p.cost_price), "retail_price": float(p.retail_price),
                      "cost_value": cv, "retail_value": rv})

    return {
        "store": {"name": settings.get("store_name",""), "address": settings.get("store_address",""), "phone": settings.get("store_phone","")},
        "warehouse": wh.name if wh else warehouse_id,
        "generated_at": _dt.datetime.utcnow().isoformat(),
        "items": items,
        "summary": {"total_products": len(items), "total_cost_value": total_cost, "total_retail_value": total_retail},
    }


@router.get("/ledger/daily-items")
async def daily_items(target_date: date = Query(default=date.today()), warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "cashier", "manager", "accountant"))):
    """Daily ledger: each product sold with qty, price, total, returns, expenses."""
    from datetime import datetime
    from sqlalchemy import text as sqlt
    import uuid as _uuid
    start = datetime(target_date.year, target_date.month, target_date.day, 0, 0, 0)
    end   = datetime(target_date.year, target_date.month, target_date.day, 23, 59, 59)
    params: dict = {"start": start, "end": end}
    if warehouse_id:
        params["wh_id"] = _uuid.UUID(warehouse_id)

    items = (await db.execute(sqlt("""
        SELECT p.name, p.unit, si.unit_price as price,
               SUM(si.qty) as qty,
               SUM(si.qty * si.unit_price - si.discount) as total
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        GROUP BY p.name, p.unit, si.unit_price
        ORDER BY total DESC
    """), params)).fetchall()

    returns = (await db.execute(sqlt("""
        SELECT p.name, SUM(si.qty * si.unit_price - si.discount) as total
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        WHERE s.status = 'returned' AND s.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        GROUP BY p.name
    """), params)).fetchall()
    returns_map = {r.name: float(r.total) for r in returns}

    expenses = (await db.execute(sqlt("""
        SELECT dt.note, SUM(dt.amount) as total
        FROM drawer_transactions dt JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type = 'expense' AND dt.created_at BETWEEN :start AND :end
          AND (:wh_id IS NULL OR sh.warehouse_id = :wh_id)
        GROUP BY dt.note
    """), params)).fetchall()

    return {
        "items": [{"name": r.name, "unit": r.unit, "price": float(r.price), "qty": float(r.qty),
                   "total": float(r.total), "returns": returns_map.get(r.name, 0)} for r in items],
        "expenses": [{"note": r.note or "مصروف", "total": float(r.total)} for r in expenses],
    }


@router.get("/ledger/periodic")
async def periodic_ledger(period: str = "weekly", warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin", "manager", "accountant"))):
    """Weekly / monthly / yearly summary: income, expenses, net."""
    from sqlalchemy import text as sqlt
    import uuid as _uuid

    VALID_PERIODS = {
        "weekly": ("week", "YYYY-\"W\"IW"),
        "monthly": ("month", "YYYY-MM"),
        "yearly": ("year", "YYYY"),
    }
    if period not in VALID_PERIODS:
        from fastapi import HTTPException
        raise HTTPException(status_code=400, detail=f"Invalid period: {period}")
    trunc, label_fmt = VALID_PERIODS[period]

    params: dict = {}
    if warehouse_id:
        params["wh_id"] = _uuid.UUID(warehouse_id)

    rows = (await db.execute(sqlt(f"""
        SELECT TO_CHAR(DATE_TRUNC('{trunc}', s.created_at), '{label_fmt}') as period,
               COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) as income,
               COALESCE(SUM(CASE WHEN s.status='returned' THEN si.qty * si.unit_price - si.discount ELSE 0 END), 0) as returns
        FROM sale_items si JOIN sales s ON s.id = si.sale_id
        WHERE s.status IN ('confirmed','returned')
          AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        GROUP BY DATE_TRUNC('{trunc}', s.created_at)
        ORDER BY DATE_TRUNC('{trunc}', s.created_at) DESC
        LIMIT 52
    """), params)).fetchall()

    exp_rows = (await db.execute(sqlt(f"""
        SELECT TO_CHAR(DATE_TRUNC('{trunc}', dt.created_at), '{label_fmt}') as period,
               COALESCE(SUM(dt.amount), 0) as expenses
        FROM drawer_transactions dt JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type = 'expense'
          AND (:wh_id IS NULL OR sh.warehouse_id = :wh_id)
        GROUP BY DATE_TRUNC('{trunc}', dt.created_at)
    """), params)).fetchall()
    exp_map = {r.period: float(r.expenses) for r in exp_rows}

    return [{"period": r.period, "income": float(r.income), "returns": float(r.returns),
             "expenses": exp_map.get(r.period, 0),
             "net": float(r.income) - float(r.returns) - exp_map.get(r.period, 0)} for r in rows]


@router.get("/cash-flow")
async def cash_flow(
    from_date: str = Query(...),
    to_date: str = Query(...),
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin", "manager", "accountant")),
):
    """Formal cash flow: incoming (sales, collections) vs outgoing (purchases, expenses, payroll)."""
    from sqlalchemy import text as sqlt
    from datetime import datetime
    import uuid as _uuid

    start = datetime.fromisoformat(from_date)
    end = datetime.fromisoformat(to_date)
    params: dict = {"start": start, "end": end}
    if warehouse_id:
        params["wh_id"] = _uuid.UUID(warehouse_id)

    wh_filter_sales = "AND s.warehouse_id = :wh_id" if warehouse_id else ""
    wh_filter_sh = "AND sh.warehouse_id = :wh_id" if warehouse_id else ""
    wh_filter_ex = "AND e.warehouse_id = :wh_id" if warehouse_id else ""
    wh_filter_sm = "AND sm.warehouse_id = :wh_id" if warehouse_id else ""
    wh_filter_po = "AND po.warehouse_id = :wh_id" if warehouse_id else ""

    cash_sales = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(si.qty * si.unit_price - si.discount), 0)
        FROM sale_items si JOIN sales s ON s.id = si.sale_id
        WHERE s.status = 'confirmed' AND s.is_credit = false
          AND s.created_at BETWEEN :start AND :end {wh_filter_sales}
    """), params)).scalar()

    credit_sales = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(si.qty * si.unit_price - si.discount), 0)
        FROM sale_items si JOIN sales s ON s.id = si.sale_id
        WHERE s.status = 'confirmed' AND s.is_credit = true
          AND s.created_at BETWEEN :start AND :end {wh_filter_sales}
    """), params)).scalar()

    customer_payments = (await db.execute(sqlt("""
        SELECT COALESCE(SUM(amount), 0) FROM customer_payments
        WHERE created_at BETWEEN :start AND :end
    """), params)).scalar()

    returns_from_suppliers = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(sm.qty * sm.unit_cost), 0)
        FROM stock_movements sm
        WHERE sm.movement_type = 'return_in'
          AND sm.created_at BETWEEN :start AND :end {wh_filter_sm}
    """), params)).scalar()

    purchases = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(po.amount_paid), 0)
        FROM purchase_orders po
        WHERE po.status IN ('received', 'partial')
          AND po.received_at BETWEEN :start AND :end {wh_filter_po}
    """), params)).scalar()

    expenses_amt = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(e.amount), 0)
        FROM expenses e
        WHERE e.status = 'approved'
          AND e.date >= :start::date AND e.date <= :end::date {wh_filter_ex}
    """), params)).scalar()

    drawer_expenses = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(dt.amount), 0)
        FROM drawer_transactions dt JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type = 'expense'
          AND dt.created_at BETWEEN :start AND :end {wh_filter_sh}
    """), params)).scalar()

    payroll_amt = (await db.execute(sqlt("""
        SELECT COALESCE(SUM(pe.base_salary + COALESCE(pe.bonuses,0) - COALESCE(pe.deductions,0)), 0)
        FROM payroll_entries pe
        JOIN payroll_periods pp ON pp.id = pe.period_id
        WHERE pp.status = 'approved'
          AND pp.created_at BETWEEN :start AND :end
    """), params)).scalar()

    returns_to_customers = (await db.execute(sqlt(f"""
        SELECT COALESCE(SUM(si.qty * si.unit_price - si.discount), 0)
        FROM sale_items si JOIN sales s ON s.id = si.sale_id
        WHERE s.status = 'returned'
          AND s.created_at BETWEEN :start AND :end {wh_filter_sales}
    """), params)).scalar()

    supplier_payments = (await db.execute(sqlt("""
        SELECT COALESCE(SUM(amount), 0) FROM supplier_transactions
        WHERE type = 'credit' AND created_at BETWEEN :start AND :end
    """), params)).scalar()

    incoming = {
        "cash_sales": float(cash_sales),
        "credit_sales": float(credit_sales),
        "customer_payments": float(customer_payments),
        "returns_from_suppliers": float(returns_from_suppliers),
        "total_incoming": float(cash_sales) + float(credit_sales) + float(customer_payments) + float(returns_from_suppliers),
    }
    outgoing = {
        "purchases": float(purchases),
        "expenses": float(expenses_amt) + float(drawer_expenses),
        "payroll": float(payroll_amt),
        "returns_to_customers": float(returns_to_customers),
        "supplier_payments": float(supplier_payments),
        "total_outgoing": float(purchases) + float(expenses_amt) + float(drawer_expenses) + float(payroll_amt) + float(returns_to_customers) + float(supplier_payments),
    }

    # Expense breakdown by category
    cat_rows = (await db.execute(sqlt(f"""
        SELECT fc.name, fc.color, COALESCE(SUM(e.amount), 0) as total
        FROM expenses e JOIN financial_categories fc ON fc.id = e.category_id
        WHERE e.status = 'approved' AND e.date >= :start::date AND e.date <= :end::date {wh_filter_ex}
        GROUP BY fc.name, fc.color ORDER BY total DESC
    """), params)).fetchall()

    # Sales breakdown by warehouse
    sales_rows = (await db.execute(sqlt(f"""
        SELECT w.name, COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) as total
        FROM sale_items si JOIN sales s ON s.id = si.sale_id JOIN warehouses w ON w.id = s.warehouse_id
        WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end {wh_filter_sales}
        GROUP BY w.name ORDER BY total DESC
    """), params)).fetchall()

    return {
        "from_date": from_date,
        "to_date": to_date,
        "incoming": incoming,
        "outgoing": outgoing,
        "net_cash_flow": incoming["total_incoming"] - outgoing["total_outgoing"],
        "details": {
            "expenses_by_category": [{"name": r.name, "color": r.color, "amount": float(r.total)} for r in cat_rows],
            "sales_by_warehouse": [{"warehouse": r.name, "amount": float(r.total)} for r in sales_rows],
        },
    }


@router.get("/aging")
async def aging_report(
    as_of: str | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin", "manager", "accountant")),
):
    """Aging report: customer and supplier debts split into 0-30 / 30-60 / 60-90 / 90+ day buckets."""
    from sqlalchemy import text as sqlt
    from datetime import datetime, timedelta, date as dt_date

    as_of_date = dt_date.fromisoformat(as_of) if as_of else dt_date.today()
    d30 = as_of_date - timedelta(days=30)
    d60 = as_of_date - timedelta(days=60)
    d90 = as_of_date - timedelta(days=90)

    def bucket(created: datetime | dt_date) -> str:
        d = created if isinstance(created, dt_date) else created.date()
        if d > d30:
            return "0-30"
        if d > d60:
            return "30-60"
        if d > d90:
            return "60-90"
        return "90+"

    # ── Customer Aging ──
    # Get each credit sale invoice, compute remaining balance, bucket by date
    customer_rows = (await db.execute(sqlt("""
        SELECT c.id, c.name, s.id as sale_id, s.invoice_number, s.created_at,
            (SELECT COALESCE(SUM(si.qty * si.unit_price - si.discount), 0)
             FROM sale_items si WHERE si.sale_id = s.id) - COALESCE(s.discount_amount, 0) as invoice_total,
            COALESCE((SELECT SUM(amount) FROM customer_payments WHERE customer_id = c.id), 0) as total_paid
        FROM sales s
        JOIN customers c ON c.id = s.customer_id
        WHERE s.is_credit = true AND s.status = 'confirmed'
        ORDER BY c.name, s.created_at
    """))).fetchall()

    customer_map: dict = {}
    for r in customer_rows:
        cid = str(r.id)
        if cid not in customer_map:
            customer_map[cid] = {"id": cid, "name": r.name, "total_debt": 0, "buckets": {"0-30": 0, "30-60": 0, "60-90": 0, "90+": 0}, "invoices": []}
        remaining = float(r.invoice_total) - float(r.total_paid)
        if remaining <= 0:
            continue
        b = bucket(r.created_at)
        customer_map[cid]["buckets"][b] += remaining
        customer_map[cid]["total_debt"] += remaining
        customer_map[cid]["invoices"].append({
            "invoice": r.invoice_number, "date": r.created_at.isoformat(),
            "total": float(r.invoice_total), "remaining": remaining, "bucket": b,
        })

    # ── Supplier Aging ──
    # Debits (what we owe) - Credits (what we paid), aged by transaction date
    supplier_rows = (await db.execute(sqlt("""
        SELECT s.id, s.name, st.amount, st.type, st.created_at
        FROM supplier_transactions st
        JOIN suppliers s ON s.id = st.supplier_id
        ORDER BY s.name, st.created_at
    """)).fetchall())

    supplier_map: dict = {}
    for r in supplier_rows:
        sid = str(r.id)
        if sid not in supplier_map:
            supplier_map[sid] = {"id": sid, "name": r.name, "total_debt": 0, "buckets": {"0-30": 0, "30-60": 0, "60-90": 0, "90+": 0}}
        amt = float(r.amount) if r.type == 'debit' else -float(r.amount)
        b = bucket(r.created_at)
        supplier_map[sid]["buckets"][b] += amt
        supplier_map[sid]["total_debt"] += amt

    # Filter out zero/negative balances
    customers = [c for c in customer_map.values() if c["total_debt"] > 0.01]
    suppliers = [s for s in supplier_map.values() if s["total_debt"] > 0.01]

    # Sort by debt descending
    customers.sort(key=lambda x: x["total_debt"], reverse=True)
    suppliers.sort(key=lambda x: x["total_debt"], reverse=True)

    def totals(items: list) -> dict:
        return {
            "0-30": sum(i["buckets"]["0-30"] for i in items),
            "30-60": sum(i["buckets"]["30-60"] for i in items),
            "60-90": sum(i["buckets"]["60-90"] for i in items),
            "90+": sum(i["buckets"]["90+"] for i in items),
            "total": sum(i["total_debt"] for i in items),
        }

    return {
        "as_of": as_of_date.isoformat(),
        "customers": {"items": customers, "totals": totals(customers)},
        "suppliers": {"items": suppliers, "totals": totals(suppliers)},
    }
