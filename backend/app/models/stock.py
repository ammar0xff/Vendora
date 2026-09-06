import enum
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Index, Numeric, String, Text, func
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class MovementType(str, enum.Enum):
    opening_stock  = "opening_stock"
    purchase       = "purchase"
    return_in      = "return_in"
    adjustment_in  = "adjustment_in"
    transfer_in    = "transfer_in"
    sale           = "sale"
    damage         = "damage"
    adjustment_out = "adjustment_out"
    transfer_out   = "transfer_out"

    @property
    def is_in(self) -> bool:
        return self in IN_TYPES

# Canonical tuples — import from here instead of redeclaring
IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
OUT_TYPES = ("sale", "damage", "adjustment_out", "transfer_out")


class StockMovement(Base):
    __tablename__ = "stock_movements"
    __table_args__ = (
        Index("idx_stock_movements_product_warehouse", "product_id", "warehouse_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="RESTRICT"), index=True)
    warehouse_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("warehouses.id", ondelete="RESTRICT"), index=True)
    movement_type: Mapped[MovementType] = mapped_column(SAEnum(MovementType, name="movement_type_enum"), nullable=False)
    qty: Mapped[Decimal] = mapped_column(Numeric(12, 3), nullable=False)
    unit_cost: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    ref_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    ref_type: Mapped[str | None] = mapped_column(String(32), nullable=True)
    sale_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("sales.id", ondelete="SET NULL"), nullable=True, index=True)
    purchase_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("purchase_orders.id", ondelete="SET NULL"), nullable=True, index=True)
    operation_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)
