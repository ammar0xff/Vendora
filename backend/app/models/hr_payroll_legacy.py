"""Legacy hr_payroll model (replaced by hr_payroll_periods + hr_payroll_entries)."""
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Numeric, String, Text, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.tenancy import TenantScoped
from app.db.base import Base


class HrPayrollLegacy(TenantScoped, Base):
    """Maps to hr_payroll table — legacy payroll table (replaced by normalized tables)."""
    __tablename__ = "hr_payroll"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    employee_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("hr_employees.id", ondelete="CASCADE"))
    month: Mapped[str] = mapped_column(String(7), nullable=False)
    base_salary: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    working_days: Mapped[int] = mapped_column(default=0)
    actual_working_days: Mapped[int] = mapped_column(default=0)
    absent_days: Mapped[int] = mapped_column(default=0)
    vacation_days: Mapped[int] = mapped_column(default=0)
    total_hours: Mapped[Decimal] = mapped_column(Numeric(8, 2), default=0)
    lateness_minutes: Mapped[int] = mapped_column(default=0)
    early_leave_minutes: Mapped[int] = mapped_column(default=0)
    missing_scan_minutes: Mapped[int] = mapped_column(default=0)
    lateness_deduction: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    overtime_hours: Mapped[Decimal] = mapped_column(Numeric(6, 2), default=0)
    overtime_pay: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    bonus_days: Mapped[int] = mapped_column(default=0)
    bonus_payment: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    bonus: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    deductions: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    advances: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    drawer_variance: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    net_salary: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    hourly_rate: Mapped[Decimal] = mapped_column(Numeric(10, 4), default=0)
    daily_breakdown: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    status: Mapped[str] = mapped_column(String(16), default="draft")
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
