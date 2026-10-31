import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Numeric, String, Text, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.tenancy import TenantScoped
from app.db.base import Base


class HrEmployee(TenantScoped, Base):
    """Maps to hr_employees table — the actual HR employee records used by raw SQL in hr.py."""
    __tablename__ = "hr_employees"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    emp_code: Mapped[str | None] = mapped_column(String(32), nullable=True, index=True)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    position: Mapped[str | None] = mapped_column(String(64), nullable=True)
    monthly_salary: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    shift_schedule: Mapped[str | None] = mapped_column(String(32), nullable=True)
    hire_date: Mapped[datetime | None] = mapped_column(Date, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint("tenant_id", "emp_code", name="uq_hr_employees_emp_code"),)

class HrPayrollPeriod(TenantScoped, Base):
    """Maps to hr_payroll_periods table — payroll month tracking."""
    __tablename__ = "hr_payroll_periods"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    month: Mapped[str] = mapped_column(String(7), index=True, nullable=False)
    status: Mapped[str] = mapped_column(String(16), default="draft")
    submitted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    approved_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    paid_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    __table_args__ = (UniqueConstraint("tenant_id", "month", name="uq_hr_payroll_periods_month"),)

class HrPayrollEntry(TenantScoped, Base):
    """Maps to hr_payroll_entries table — per-employee payroll entries (replaces old hr_payroll table)."""
    __tablename__ = "hr_payroll_entries"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    period_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("hr_payroll_periods.id", ondelete="CASCADE"))
    employee_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("hr_employees.id", ondelete="CASCADE"))
    base_salary: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    working_days: Mapped[int | None] = mapped_column(nullable=True)
    actual_working_days: Mapped[int | None] = mapped_column(nullable=True)
    absent_days: Mapped[int | None] = mapped_column(nullable=True)
    vacation_days: Mapped[int | None] = mapped_column(nullable=True)
    total_hours: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    lateness_minutes: Mapped[int | None] = mapped_column(nullable=True)
    early_leave_minutes: Mapped[int | None] = mapped_column(nullable=True)
    missing_scan_minutes: Mapped[int | None] = mapped_column(nullable=True)
    lateness_deduction: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    overtime_hours: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    overtime_pay: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    bonus_days: Mapped[int | None] = mapped_column(nullable=True)
    bonus_payment: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    bonuses: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    deductions: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    advances: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    drawer_variance: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    net_salary: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    hourly_rate: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    daily_breakdown: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    status: Mapped[str] = mapped_column(String(16), default="draft")
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
