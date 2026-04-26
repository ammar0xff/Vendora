from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_db
from app.models.payroll import Employee, PayrollPeriod, PayrollEntry
from app.dependencies import require_role, require_perm
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
import uuid

router = APIRouter(prefix="/payroll", tags=["payroll"])


@router.get("/employees")
async def list_employees(db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(Employee).where(Employee.is_active == True))).scalars().all()


@router.post("/employees")
async def create_employee(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    e = Employee(**data)
    db.add(e)
    await db.commit()
    await db.refresh(e)
    return e


@router.get("/periods")
async def list_periods(db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(PayrollPeriod).order_by(PayrollPeriod.year.desc(), PayrollPeriod.month.desc()))).scalars().all()


@router.post("/periods")
async def create_period(data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    p = PayrollPeriod(month=data["month"], year=data["year"], created_by=current_user.id)
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return p


@router.get("/periods/{period_id}/entries")
async def list_entries(period_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(PayrollEntry).where(PayrollEntry.period_id == period_id))).scalars().all()


@router.post("/periods/{period_id}/approve")
async def approve_period(period_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    result = await db.execute(select(PayrollPeriod).where(PayrollPeriod.id == period_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    if p.status != "draft":
        raise BusinessError("Period is not in draft state")
    p.status = "approved"
    await db.commit()
    return {"detail": "Approved"}
