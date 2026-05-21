from datetime import date, datetime
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.sale import Sale, SaleItem
from app.models.product import Product


async def daily_sales(db: AsyncSession, target_date: date, warehouse_id: str | None = None):
    start = datetime(target_date.year, target_date.month, target_date.day, 0, 0, 0)
    end   = datetime(target_date.year, target_date.month, target_date.day, 23, 59, 59)
    q = (
        select(
            func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_price - SaleItem.discount), 0).label("total_sales"),
            func.coalesce(func.sum(SaleItem.qty), 0).label("total_items"),
            func.count(Sale.id.distinct()).label("invoice_count"),
        )
        .join(SaleItem, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end))
        .where(Sale.status == "confirmed")
    )
    if warehouse_id:
        import uuid as _uuid
        q = q.where(Sale.warehouse_id == _uuid.UUID(warehouse_id))
    row = (await db.execute(q)).one()
    return {"date": str(target_date), "total_sales": row.total_sales, "total_items": row.total_items, "invoice_count": row.invoice_count}


async def monthly_sales(db: AsyncSession, year: int, month: int, warehouse_id: str | None = None):
    import calendar
    import uuid as _uuid
    last_day = calendar.monthrange(year, month)[1]
    start = datetime(year, month, 1)
    end   = datetime(year, month, last_day, 23, 59, 59)
    q = (
        select(
            func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_price - SaleItem.discount), 0).label("total_sales"),
            func.count(Sale.id.distinct()).label("invoice_count"),
        )
        .join(SaleItem, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end))
        .where(Sale.status == "confirmed")
    )
    if warehouse_id:
        q = q.where(Sale.warehouse_id == _uuid.UUID(warehouse_id))
    row = (await db.execute(q)).one()
    return {"year": year, "month": month, "total_sales": row.total_sales, "invoice_count": row.invoice_count}


async def top_products(db: AsyncSession, from_date: str, to_date: str, limit: int = 10):
    start = datetime.fromisoformat(from_date)
    end   = datetime.fromisoformat(to_date)
    result = await db.execute(
        select(
            Product.id, Product.name,
            func.sum(SaleItem.qty).label("total_qty"),
            func.sum(SaleItem.qty * SaleItem.unit_price).label("total_revenue"),
        )
        .join(SaleItem, Product.id == SaleItem.product_id)
        .join(Sale, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end))
        .group_by(Product.id, Product.name)
        .order_by(func.sum(SaleItem.qty * SaleItem.unit_price).desc())
        .limit(limit)
    )
    return [{"product_id": str(r.id), "product_name": r.name, "total_qty": r.total_qty, "total_revenue": r.total_revenue} for r in result.all()]


async def profit_report(db: AsyncSession, from_date: str, to_date: str, warehouse_id: str | None = None):
    import uuid as _uuid
    from sqlalchemy import text as sqlt
    start = datetime.fromisoformat(from_date)
    end   = datetime.fromisoformat(to_date)
    wh_filter = [Sale.warehouse_id == _uuid.UUID(warehouse_id)] if warehouse_id else []

    rev = await db.execute(
        select(func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_price - SaleItem.discount), 0))
        .join(Sale, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end), Sale.status == "confirmed", *wh_filter)
    )
    cogs = await db.execute(
        select(func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_cost), 0))
        .join(Sale, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end), Sale.status == "confirmed", *wh_filter)
    )

    # Expenses from drawer transactions
    exp_params: dict = {"start": start, "end": end}
    exp_wh = "AND s.warehouse_id = :wh_id" if warehouse_id else ""
    if warehouse_id:
        exp_params["wh_id"] = _uuid.UUID(warehouse_id)
    exp_rows = await db.execute(sqlt(f"""
        SELECT dt.note, SUM(dt.amount) as total
        FROM drawer_transactions dt
        JOIN shifts s ON s.id = dt.shift_id
        WHERE dt.type = 'expense'
          AND dt.created_at BETWEEN :start AND :end
          {exp_wh}
        GROUP BY dt.note
        ORDER BY total DESC
    """), exp_params)
    expenses_detail = [{"note": r.note or "مصروف", "amount": float(r.total)} for r in exp_rows.fetchall()]
    total_expenses = sum(e["amount"] for e in expenses_detail)

    # Returns
    returns = await db.execute(
        select(func.coalesce(func.sum(SaleItem.qty * SaleItem.unit_price - SaleItem.discount), 0))
        .join(Sale, Sale.id == SaleItem.sale_id)
        .where(Sale.created_at.between(start, end), Sale.status == "returned", *wh_filter)
    )
    total_returns = returns.scalar_one() or Decimal("0")

    total_rev  = rev.scalar_one()  or Decimal("0")
    total_cogs = cogs.scalar_one() or Decimal("0")
    gross_profit = total_rev - total_returns - total_cogs
    net_profit = gross_profit - Decimal(str(total_expenses))

    return {
        "from_date": from_date,
        "to_date": to_date,
        "total_revenue": total_rev,
        "total_returns": total_returns,
        "net_revenue": total_rev - total_returns,
        "total_cogs": total_cogs,
        "gross_profit": gross_profit,
        "gross_margin": round(float(gross_profit) / float(total_rev) * 100, 1) if total_rev > 0 else 0,
        "total_expenses": total_expenses,
        "expenses_detail": expenses_detail,
        "net_profit": net_profit,
        "net_margin": round(float(net_profit) / float(total_rev) * 100, 1) if total_rev > 0 else 0,
    }
