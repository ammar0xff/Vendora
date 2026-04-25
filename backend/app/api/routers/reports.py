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
    import uuid as _uuid, datetime as _dt

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
        .where(Product.is_active == True)
        .order_by(Category.name, Subcategory.name, Product.name)
    )
    settings = {r.key: r.value for r in (await db.execute(select(StoreSetting))).scalars().all()}

    items, total_cost, total_retail = [], 0.0, 0.0
    for p, sub_name, cat_name, qty in rows.all():
        q = float(qty or 0)
        cv, rv = q * float(p.cost_price), q * float(p.retail_price)
        total_cost += cv; total_retail += rv
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
    wh_filter = "AND s.warehouse_id = :wh_id" if warehouse_id else ""
    params: dict = {"start": start, "end": end}
    if warehouse_id: params["wh_id"] = _uuid.UUID(warehouse_id)

    items = (await db.execute(sqlt(f"""
        SELECT p.name, p.unit, si.unit_price as price,
               SUM(si.qty) as qty,
               SUM(si.qty * si.unit_price - si.discount) as total
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end {wh_filter}
        GROUP BY p.name, p.unit, si.unit_price
        ORDER BY total DESC
    """), params)).fetchall()

    returns = (await db.execute(sqlt(f"""
        SELECT p.name, SUM(si.qty * si.unit_price - si.discount) as total
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        JOIN products p ON p.id = si.product_id
        WHERE s.status = 'returned' AND s.created_at BETWEEN :start AND :end {wh_filter}
        GROUP BY p.name
    """), params)).fetchall()
    returns_map = {r.name: float(r.total) for r in returns}

    expenses = (await db.execute(sqlt(f"""
        SELECT dt.note, SUM(dt.amount) as total
        FROM drawer_transactions dt JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type = 'expense' AND dt.created_at BETWEEN :start AND :end
        {'AND sh.warehouse_id = :wh_id' if warehouse_id else ''}
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

    if period == "weekly":
        trunc = "week"
        label_fmt = "YYYY-WW"
    elif period == "monthly":
        trunc = "month"
        label_fmt = "YYYY-MM"
    else:  # yearly
        trunc = "year"
        label_fmt = "YYYY"

    wh_filter = "AND s.warehouse_id = :wh_id" if warehouse_id else ""
    params: dict = {}
    if warehouse_id: params["wh_id"] = _uuid.UUID(warehouse_id)

    rows = (await db.execute(sqlt(f"""
        SELECT TO_CHAR(DATE_TRUNC('{trunc}', s.created_at), '{label_fmt}') as period,
               COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) as income,
               COALESCE(SUM(CASE WHEN s.status='returned' THEN si.qty * si.unit_price - si.discount ELSE 0 END), 0) as returns
        FROM sale_items si JOIN sales s ON s.id = si.sale_id
        WHERE s.status IN ('confirmed','returned') {wh_filter}
        GROUP BY DATE_TRUNC('{trunc}', s.created_at)
        ORDER BY DATE_TRUNC('{trunc}', s.created_at) DESC
        LIMIT 52
    """), params)).fetchall()

    exp_rows = (await db.execute(sqlt(f"""
        SELECT TO_CHAR(DATE_TRUNC('{trunc}', dt.created_at), '{label_fmt}') as period,
               COALESCE(SUM(dt.amount), 0) as expenses
        FROM drawer_transactions dt JOIN shifts sh ON sh.id = dt.shift_id
        WHERE dt.type = 'expense'
        {'AND sh.warehouse_id = :wh_id' if warehouse_id else ''}
        GROUP BY DATE_TRUNC('{trunc}', dt.created_at)
    """), params)).fetchall()
    exp_map = {r.period: float(r.expenses) for r in exp_rows}

    return [{"period": r.period, "income": float(r.income), "returns": float(r.returns),
             "expenses": exp_map.get(r.period, 0),
             "net": float(r.income) - float(r.returns) - exp_map.get(r.period, 0)} for r in rows]
