from __future__ import annotations
from decimal import Decimal
from datetime import date
from typing import Optional
from pydantic import BaseModel, Field
import uuid


class EmployeeCreate(BaseModel):
    """Schema for creating an HR employee (hr_employees table).
    Fields match the SQL INSERT in hr.py router.
    """
    emp_code: Optional[str] = None
    name: str = Field(..., min_length=1, max_length=128)
    position: Optional[str] = None
    monthly_salary: Decimal = Field(default=Decimal("0"), ge=0)
    shift_schedule: Optional[str] = None
    hire_date: Optional[date] = None


class EmployeeUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=128)
    position: Optional[str] = None
    monthly_salary: Optional[Decimal] = Field(default=None, ge=0)
    shift_schedule: Optional[str] = None
    hire_date: Optional[date] = None
    is_active: Optional[bool] = None


class AttendanceCreate(BaseModel):
    employee_id: uuid.UUID
    work_date: date
    check_in: Optional[str] = None
    check_out: Optional[str] = None
    status: str = "present"
    notes: Optional[str] = None


class PayrollCalculate(BaseModel):
    month: str
    employee_id: Optional[uuid.UUID] = None


class PayrollUpdate(BaseModel):
    bonus: Decimal = Decimal("0")
    deductions: Decimal = Decimal("0")
    drawer_variance: Decimal = Decimal("0")
    status: str = "draft"
    notes: Optional[str] = None


class AdvanceCreate(BaseModel):
    employee_id: uuid.UUID
    amount: Decimal = Field(..., gt=0)
    date: Optional[date] = None
    note: Optional[str] = None
    record_type: str = "سلفة"


class HRSettingsUpdate(BaseModel):
    """Generic key-value settings update."""
    settings: dict = {}
