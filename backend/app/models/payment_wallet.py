from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Numeric, Boolean
from app.db.base import Base
import uuid
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime


class PaymentWallet(Base):
    __tablename__ = "payment_wallets"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(128))
    type: Mapped[str] = mapped_column(String(32))
    phone: Mapped[str | None] = mapped_column(String(32), nullable=True)
    balance: Mapped[float] = mapped_column(Numeric(14, 2), default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
