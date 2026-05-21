from decimal import Decimal
from datetime import date
from pydantic import BaseModel, Field
import uuid


class EmployeeCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    emp_code: str | None = None
    position: str | None = None
    monthly_salary: Decimal = Field(default=Decimal("0"), ge=0)
    shift_schedule: str | None = None
    hire_date: date | None = None


class EmployeeUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    emp_code: str | None = None
    position: str | None = None
    monthly_salary: Decimal | None = Field(default=None, ge=0)
    shift_schedule: str | None = None
    hire_date: date | None = None


class AttendanceCreate(BaseModel):
    employee_id: uuid.UUID
    work_date: date
    check_in: str | None = None
    check_out: str | None = None
    status: str = "present"
    notes: str | None = None


class PayrollCalculate(BaseModel):
    month: str
    employee_id: uuid.UUID | None = None


class PayrollUpdate(BaseModel):
    bonus: Decimal = 0
    deductions: Decimal = 0
    drawer_variance: Decimal = 0
    status: str = "draft"
    notes: str | None = None


class AdvanceCreate(BaseModel):
    employee_id: uuid.UUID
    amount: Decimal = Field(..., gt=0)
    date: date | None = None
    note: str | None = None
    record_type: str = "سلفة"


class HRSettingsUpdate(BaseModel):
    """Generic key-value settings update."""
    settings: dict = {}
