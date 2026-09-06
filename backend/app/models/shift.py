import enum
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Index, Numeric, String, Text, func
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class ShiftStatus(enum.StrEnum):
    open = "open"
    closed = "closed"


class DrawerTxType(enum.StrEnum):
    sale = "sale"
    return_ = "return"
    expense = "expense"
    deposit = "deposit"
    withdrawal = "withdrawal"
    revenue_delivery = "revenue_delivery"


class Shift(Base):
    __tablename__ = "shifts"
    __table_args__ = (
        Index("idx_shifts_warehouse_status", "warehouse_id", "status"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cashier_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    warehouse_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("warehouses.id", ondelete="SET NULL"), nullable=True, index=True)
    supervisor_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    status: Mapped[ShiftStatus] = mapped_column(SAEnum(ShiftStatus, name="shift_status_enum"), default=ShiftStatus.open, index=True)
    initial_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    closing_balance: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    expected_balance: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    difference: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    next_day_drawer: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    deposit_received_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    deposit_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    closed_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    transactions: Mapped[list["DrawerTransaction"]] = relationship(back_populates="shift", cascade="all, delete-orphan")


class DrawerTransaction(Base):
    __tablename__ = "drawer_transactions"
    __table_args__ = (
        Index("idx_drawer_tx_shift_id", "shift_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shift_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shifts.id", ondelete="CASCADE"), index=True)
    type: Mapped[DrawerTxType] = mapped_column(SAEnum(DrawerTxType, name="drawer_tx_type_enum"), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    ref_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("sales.id", ondelete="SET NULL"), nullable=True, index=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    category_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("financial_categories.id", ondelete="SET NULL"), nullable=True)
    payment_method: Mapped[str | None] = mapped_column(String(32), default="cash", nullable=True)
    wallet_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("payment_wallets.id", ondelete="SET NULL"), nullable=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    shift: Mapped["Shift"] = relationship(back_populates="transactions")
    sale = relationship("Sale", foreign_keys=[ref_id], primaryjoin="DrawerTransaction.ref_id == Sale.id", viewonly=True)
