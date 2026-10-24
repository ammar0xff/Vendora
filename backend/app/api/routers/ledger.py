"""
GET /reports/ledger
Returns all sale items + returns + expenses for a date range.
"""
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import get_db
from app.dependencies import get_current_user, verify_warehouse_access
from app.models.user import User
from app.services import ledger_service

router = APIRouter(prefix="/reports/ledger", tags=["ledger"])


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
    return await ledger_service.get_ledger(db, from_date, to_date, warehouse_id, page, page_size)