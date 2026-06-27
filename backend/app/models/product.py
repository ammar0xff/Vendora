import uuid
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Boolean, Numeric, DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class Category(Base):
    __tablename__ = "categories"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    subcategories: Mapped[list["Subcategory"]] = relationship(back_populates="category", cascade="all, delete-orphan")


class Subcategory(Base):
    __tablename__ = "subcategories"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    category_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("categories.id", ondelete="CASCADE"))
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    category: Mapped["Category"] = relationship(back_populates="subcategories")
    products: Mapped[list["Product"]] = relationship(back_populates="subcategory")


class Product(Base):
    __tablename__ = "products"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    subcategory_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("subcategories.id", ondelete="RESTRICT"))
    name: Mapped[str] = mapped_column(String(256), nullable=False)
    barcode: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    unit: Mapped[str] = mapped_column(String(32), nullable=False, default="عدد")
    retail_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    wholesale_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    cost_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0)
    reorder_point: Mapped[Decimal] = mapped_column(Numeric(12, 3), default=0)
    reorder_qty: Mapped[Decimal] = mapped_column(Numeric(12, 3), default=0)
    stock_status: Mapped[str] = mapped_column(String(32), default="untracked")
    # Extra descriptive fields from the original system
    company: Mapped[str | None] = mapped_column(String(128), nullable=True)
    size: Mapped[str | None] = mapped_column(String(64), nullable=True)
    product_type: Mapped[str | None] = mapped_column("type", String(64), nullable=True)
    material: Mapped[str | None] = mapped_column(String(64), nullable=True)
    shelf_number: Mapped[str | None] = mapped_column(String(32), nullable=True, default=None)
    image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    subcategory: Mapped["Subcategory"] = relationship(back_populates="products")
    barcodes: Mapped[list["ProductBarcode"]] = relationship(back_populates="product", cascade="all, delete-orphan")


class ProductBarcode(Base):
    __tablename__ = "product_barcodes"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"))
    barcode: Mapped[str] = mapped_column(String(64), unique=True, nullable=False, index=True)
    is_primary: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    product: Mapped["Product"] = relationship(back_populates="barcodes")
