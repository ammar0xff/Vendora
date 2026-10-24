"""Schema migrations tracking model."""
from datetime import datetime

from sqlalchemy import DateTime, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SchemaMigration(Base):
    """Maps to schema_migrations table — tracks applied migrations."""
    __tablename__ = "schema_migrations"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    applied_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
