import uuid
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Numeric, DateTime, ForeignKey, func, Text, Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base
import enum


class ShiftStatus(str, enum.Enum):
    open = "open"
    closed = "closed"


class DrawerTxType(str, enum.Enum):
    sale = "sale"
    return_ = "return"
    expense = "expense"
    deposit = "deposit"
    withdrawal = "withdrawal"


class Shift(Base):
    __tablename__ = "shifts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cashier_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    warehouse_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("warehouses.id"), nullable=True, index=True)
    supervisor_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    status: Mapped[ShiftStatus] = mapped_column(SAEnum(ShiftStatus, name="shift_status_enum"), default=ShiftStatus.open)
    initial_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    closing_balance: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    next_day_drawer: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    closed_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    transactions: Mapped[list["DrawerTransaction"]] = relationship(back_populates="shift", cascade="all, delete-orphan")


class DrawerTransaction(Base):
    __tablename__ = "drawer_transactions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shift_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shifts.id", ondelete="CASCADE"), index=True)
    type: Mapped[DrawerTxType] = mapped_column(SAEnum(DrawerTxType, name="drawer_tx_type_enum"), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    ref_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    category_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    payment_method: Mapped[str | None] = mapped_column(String(32), default="cash", nullable=True)
    wallet_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    shift: Mapped["Shift"] = relationship(back_populates="transactions")
