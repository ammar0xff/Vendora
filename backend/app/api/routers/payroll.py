from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.db.base import get_db
from app.models.payroll import Employee, PayrollPeriod, PayrollEntry
from app.schemas.hr import EmployeeCreate
from app.dependencies import require_perm
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
import uuid

router = APIRouter(prefix="/payroll", tags=["payroll"])


@router.get("/employees")
async def list_employees(db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(Employee).where(Employee.is_active))).scalars().all()


@router.post("/employees")
async def create_employee(data: EmployeeCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    e = Employee(**data.model_dump())
    db.add(e)
    await db.commit()
    await db.refresh(e)
    return e


@router.get("/periods")
async def list_periods(db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(PayrollPeriod).order_by(PayrollPeriod.year.desc(), PayrollPeriod.month.desc()))).scalars().all()


class CreatePeriodRequest(BaseModel):
    month: int
    year: int

@router.post("/periods")
async def create_period(data: CreatePeriodRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("payroll"))):
    p = PayrollPeriod(month=data.month, year=data.year, created_by=current_user.id)
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return p


@router.get("/periods/{period_id}/entries")
async def list_entries(period_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    return (await db.execute(select(PayrollEntry).where(PayrollEntry.period_id == period_id))).scalars().all()


@router.post("/periods/{period_id}/approve")
async def approve_period(period_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("payroll"))):
    from sqlalchemy import text as sqlt
    from decimal import Decimal

    result = await db.execute(select(PayrollPeriod).where(PayrollPeriod.id == period_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    if p.status != "draft":
        raise BusinessError("Period is not in draft state")

    # Calculate total payroll for this period
    total = await db.execute(
        select(func.coalesce(func.sum(PayrollEntry.base_salary + func.coalesce(PayrollEntry.bonuses, 0) - func.coalesce(PayrollEntry.deductions, 0)), 0))
        .where(PayrollEntry.period_id == period_id)
    )
    total_amount: Decimal = total.scalar_one()

    # Ensure salary expense category exists
    cat = await db.execute(sqlt("SELECT id FROM financial_categories WHERE name = 'رواتب'"))
    cat_row = cat.mappings().first()
    if cat_row:
        cat_id = cat_row["id"]
    else:
        cat_r = await db.execute(sqlt(
            "INSERT INTO financial_categories (name, type, color) VALUES ('رواتب', 'expense', '#dc2626') RETURNING id"
        ))
        cat_id = cat_r.mappings().first()["id"]

    # Record as expense
    if total_amount > 0:
        await db.execute(sqlt("""
            INSERT INTO expenses (category_id, amount, description, date, status, created_by, notes)
            VALUES (:cid, :amt, :desc, :dt, 'approved', :by, :notes)
        """), {
            "cid": cat_id,
            "amt": total_amount,
            "desc": f"رواتب شهر {p.month}/{p.year}",
            "dt": f"{p.year}-{p.month:02d}-01",
            "by": p.created_by or current_user.id,
            "notes": f"Payroll period {period_id}",
        })

    p.status = "approved"
    await db.commit()
    return {"detail": "Approved", "total_payroll": float(total_amount)}
