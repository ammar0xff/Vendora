"""HR Audit log model."""
import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.tenancy import TenantScoped
from app.db.base import Base


class HrAuditLog(TenantScoped, Base):
    """Maps to hr_audit_log table — HR-specific audit trail."""
    __tablename__ = "hr_audit_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    action_type: Mapped[str] = mapped_column(Text, nullable=False)  # create/update/delete/calculate/approve/pay
    entity_type: Mapped[str] = mapped_column(Text, nullable=False)  # employee/attendance/advance/payroll
    entity_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    performed_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    details: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON as text
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
