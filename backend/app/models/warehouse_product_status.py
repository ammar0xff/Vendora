"""Warehouse product status model."""
import uuid

from sqlalchemy import ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class WarehouseProductStatus(Base):
    """Maps to warehouse_product_status table — tracks if a product is tracked/untracked per warehouse."""
    __tablename__ = "warehouse_product_status"

    warehouse_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("warehouses.id", ondelete="CASCADE"), primary_key=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), primary_key=True)
    status: Mapped[str] = mapped_column(Text, default="untracked")  # tracked/untracked