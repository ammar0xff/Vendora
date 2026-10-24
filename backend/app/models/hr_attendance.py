"""HR Attendance model."""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class HrAttendance(Base):
    """Maps to hr_attendance table."""
    __tablename__ = "hr_attendance"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    employee_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("hr_employees.id", ondelete="CASCADE"))
    work_date: Mapped[datetime] = mapped_column(Date, nullable=False)
    check_in: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    check_out: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[str] = mapped_column(Text, default="present")  # present/absent/leave/weekend/mission
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    edited: Mapped[bool] = mapped_column(Boolean, default=False)
    edited_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    edit_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    excuse_no_late: Mapped[bool] = mapped_column(Boolean, default=False)
    excuse_no_early: Mapped[bool] = mapped_column(Boolean, default=False)
    excuse_allow_overtime: Mapped[bool] = mapped_column(Boolean, default=False)
    shift_override: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("hr_shifts.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
