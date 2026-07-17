import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class FinancialCategory(Base):
    __tablename__ = "financial_categories"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    type: Mapped[str] = mapped_column(String(16), nullable=False, default="expense")
    color: Mapped[str | None] = mapped_column(String(16), nullable=True, default="#64748b")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
