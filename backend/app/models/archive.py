import enum
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import DateTime, ForeignKey, Numeric, String, func
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class DocType(enum.StrEnum):
    sale_invoice    = "sale_invoice"
    quotation       = "quotation"
    purchase_order  = "purchase_order"
    purchase_invoice = "purchase_invoice"  # فاتورة مشتريات مستلمة
    dispatch_order  = "dispatch_order"
    goods_receipt   = "goods_receipt"
    stock_request   = "stock_request"
    shift_report    = "shift_report"
    shift_handover  = "shift_handover"
    inventory_report = "inventory_report"
    safe_deposit    = "safe_deposit"
    other           = "other"


class ArchivedDocument(Base):
    __tablename__ = "archived_documents"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    doc_number: Mapped[str] = mapped_column(String(64), nullable=False)
    doc_type: Mapped[DocType] = mapped_column(SAEnum(DocType, name="doc_type_enum"), nullable=False, index=True)
    customer_name: Mapped[str | None] = mapped_column(String(128), nullable=True)
    amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    file_path: Mapped[str | None] = mapped_column(String(512), nullable=True)
    storage_key: Mapped[str | None] = mapped_column(String(512), nullable=True)
    metadata_: Mapped[dict | None] = mapped_column("metadata", JSONB, nullable=True)
    ref_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)
