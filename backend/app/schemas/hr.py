from __future__ import annotations

import uuid
from datetime import date as date_type
from decimal import Decimal

from pydantic import BaseModel, Field


class EmployeeCreate(BaseModel):
    """Schema for creating an HR employee (hr_employees table).
    Fields match the SQL INSERT in hr.py router.
    """
    emp_code: str | None = None
    user_id: uuid.UUID | None = None
    name: str = Field(..., min_length=1, max_length=128)
    position: str | None = None
    monthly_salary: Decimal = Field(default=Decimal("0"), ge=0)
    shift_schedule: str | None = None
    hire_date: date_type | None = None


class EmployeeUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    user_id: uuid.UUID | None = None
    position: str | None = None
    monthly_salary: Decimal | None = Field(default=None, ge=0)
    shift_schedule: str | None = None
    hire_date: date_type | None = None
    is_active: bool | None = None


class AttendanceCreate(BaseModel):
    employee_id: uuid.UUID
    work_date: date_type
    check_in: str | None = None
    check_out: str | None = None
    status: str = "present"
    notes: str | None = None


class PayrollCalculate(BaseModel):
    month: str
    employee_id: uuid.UUID | None = None


class PayrollUpdate(BaseModel):
    bonus: Decimal = Decimal("0")
    deductions: Decimal = Decimal("0")
    drawer_variance: Decimal = Decimal("0")
    status: str = "draft"
    notes: str | None = None


class AdvanceCreate(BaseModel):
    employee_id: uuid.UUID
    amount: Decimal = Field(..., gt=0)
    date: date_type | None = None
    note: str | None = None
    record_type: str = "سلفة"


class ShiftCreate(BaseModel):
    name: str
    start_time: str
    end_time: str
    description: str = ""


class HRSettingsUpdate(BaseModel):
    """Generic key-value settings update."""
    settings: dict = {}
