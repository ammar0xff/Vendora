import uuid
from datetime import UTC, date, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import get_db
from app.dependencies import get_current_user, verify_warehouse_access
from app.models.sale import Sale, SaleItem
from app.models.stock import IN_TYPES
from app.models.user import User
from app.services import report_service

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/sales/daily")
async def daily_sales(target_date: date = Query(default_factory=date.today), warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.daily_sales(db, target_date, warehouse_id=warehouse_id)


@router.get("/sales/monthly")
async def monthly_sales(year: int, month: int, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.monthly_sales(db, year, month, warehouse_id=warehouse_id)


@router.get("/sales/top-products")
async def top_products(from_date: str, to_date: str, limit: int = 10, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await report_service.top_products(db, from_date, to_date, limit)


@router.get("/sales/by-cashier")
async def sales_by_cashier(from_date: str, to_date: str, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.sales_by_cashier(db, from_date, to_date, warehouse_id=warehouse_id)


@router.get("/profit")
async def profit(from_date: str, to_date: str, warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.profit_report(db, from_date, to_date, warehouse_id=warehouse_id)


@router.get("/inventory/print")
async def inventory_print_report(warehouse_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """تقرير المخزون الكامل للطباعة."""
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id))
    return await report_service.inventory_print_report(db, warehouse_id)


@router.get("/ledger/daily-items")
async def daily_items(target_date: date = Query(default_factory=date.today), warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Daily ledger: each product sold with qty, price, total, returns, expenses."""
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.daily_items(db, target_date, warehouse_id=warehouse_id)


@router.get("/ledger/periodic")
async def periodic_ledger(period: str = "weekly", warehouse_id: str | None = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Weekly / monthly / yearly summary: income, expenses, net."""
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.periodic_ledger(db, period, warehouse_id=warehouse_id)


@router.get("/cash-flow")
async def cash_flow(
    from_date: str = Query(...),
    to_date: str = Query(...),
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Formal cash flow: incoming (sales, collections) vs outgoing (purchases, expenses, payroll)."""
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    return await report_service.cash_flow(db, from_date, to_date, warehouse_id=warehouse_id)


@router.get("/aging")
async def aging_report(
    as_of: str | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    """Aging report: customer and supplier debts split into 0-30 / 30-60 / 60-90 / 90+ day buckets."""
    return await report_service.aging_report(db, as_of=as_of)