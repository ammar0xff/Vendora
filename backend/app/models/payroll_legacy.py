"""Legacy payroll models (replaced by hr_payroll_periods + hr_payroll_entries)."""
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Numeric, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class PayrollPeriodLegacy(Base):
    """Maps to payroll_periods table — legacy payroll period table."""
    __tablename__ = "payroll_periods"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class PayrollEntryLegacy(Base):
    """Maps to payroll_entries table — legacy payroll entry table."""
    __tablename__ = "payroll_entries"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    period_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("payroll_periods.id", ondelete="CASCADE"))
    employee_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("employees.id", ondelete="CASCADE"))
    base_salary: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    bonuses: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    deductions: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())