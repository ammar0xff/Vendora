"""Accounting periods — month-end closing."""
import uuid

from sqlalchemy import UniqueConstraint, Column, DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.core.tenancy import TenantScoped
from app.db.base import Base


class AccountingPeriod(TenantScoped, Base):
    __tablename__ = "accounting_periods"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    month = Column(String(7), index=True, nullable=False)
    status = Column(String(20), nullable=False, default="open")
    closed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    closed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    __table_args__ = (UniqueConstraint("tenant_id", "month", name="uq_accounting_periods_month"),)
