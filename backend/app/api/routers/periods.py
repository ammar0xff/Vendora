"""Accounting periods — month-end closing."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm
from app.models.user import User
from app.core.exceptions import BusinessError

router = APIRouter(prefix="/periods", tags=["periods"])

_initialized = False


def current_month() -> str:
    from datetime import datetime
    return datetime.now().strftime("%Y-%m")


# Ensure accounting_periods table exists (run once at startup)
async def ensure_period_table(db: AsyncSession):
    """Create accounting_periods table if it doesn't exist."""
    global _initialized
    if _initialized:
        return
    await db.execute(text("""
        CREATE TABLE IF NOT EXISTS accounting_periods (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            month VARCHAR(7) UNIQUE NOT NULL,
            status VARCHAR(20) NOT NULL DEFAULT 'open',
            closed_by UUID REFERENCES users(id),
            closed_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ DEFAULT now(),
            updated_at TIMESTAMPTZ DEFAULT now()
        )
    """))
    await db.commit()
    _initialized = True


@router.get("")
async def list_periods(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    # Do NOT call ensure_table from GET handler; table should be created at startup.
    # For compatibility with existing deployments, just skip the DDL.
    rows = await db.execute(text("SELECT * FROM accounting_periods ORDER BY month DESC LIMIT 24"))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("/{month}/close")
async def close_period(month: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("finance"))):
    await ensure_period_table(db)
    if month >= current_month():
        raise BusinessError("لا يمكن إغلاق الشهر الحالي أو المستقبلي")
    existing = (await db.execute(text("SELECT status FROM accounting_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
    if existing == "closed":
        raise BusinessError(f"شهر {month} مغلق بالفعل")
    await db.execute(text("""
        INSERT INTO accounting_periods (month, status, closed_by, closed_at)
        VALUES (:m, 'closed', :by, now())
        ON CONFLICT (month) DO UPDATE SET status='closed', closed_by=:by, closed_at=now(), updated_at=now()
    """), {"m": month, "by": current_user.id})
    await db.commit()
    return {"detail": f"شهر {month} مغلق"}


@router.post("/{month}/reopen")
async def reopen_period(month: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("finance"))):
    await ensure_period_table(db)
    existing = (await db.execute(text("SELECT status FROM accounting_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
    if not existing or existing != "closed":
        raise BusinessError(f"شهر {month} غير مغلق")
    await db.execute(text("""
        UPDATE accounting_periods SET status='open', closed_by=NULL, closed_at=NULL, updated_at=now() WHERE month=:m
    """), {"m": month})
    await db.commit()
    return {"detail": f"شهر {month} مفتوح"}


# Dead code — kept for reference but unused.
# async def check_period_open(month: str, db: AsyncSession):
#     """Raise BusinessError if the given month is closed."""
#     await ensure_table(db)
#     status = (await db.execute(text("SELECT status FROM accounting_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
#     if status == "closed":
#         raise BusinessError(f"هذا الشهر {month} مغلق — لا يمكن تعديل أو إضافة قيود")
