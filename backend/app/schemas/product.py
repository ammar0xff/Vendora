import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field, field_validator


class CategoryCreate(BaseModel):
    name: str
    code: str | None = None


class CategoryOut(BaseModel):
    id: uuid.UUID
    name: str
    code: str | None = None
    model_config = {"from_attributes": True}


class SubcategoryCreate(BaseModel):
    category_id: uuid.UUID
    name: str
    code: str | None = None


class SubcategoryOut(BaseModel):
    id: uuid.UUID
    category_id: uuid.UUID
    name: str
    code: str | None = None
    model_config = {"from_attributes": True}


class ProductCreate(BaseModel):
    subcategory_id: uuid.UUID
    name: str
    code: str | None = None
    barcode: str | None = None
    unit: str = "عدد"
    retail_price: Decimal = Field(default=Decimal("0"), ge=0)
    wholesale_price: Decimal = Field(default=Decimal("0"), ge=0)
    cost_price: Decimal = Field(default=Decimal("0"), ge=0)
    company: str | None = None
    size: str | None = None
    product_type: str | None = None
    material: str | None = None
    image_url: str | None = None
    shelf_number: str | None = None
    reorder_point: Decimal = Field(default=Decimal("0"), ge=0)
    reorder_qty: Decimal = Field(default=Decimal("0"), ge=0)


class ProductUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    barcode: str | None = None
    unit: str | None = None
    retail_price: Decimal | None = None
    wholesale_price: Decimal | None = None
    cost_price: Decimal | None = None
    subcategory_id: uuid.UUID | None = None
    company: str | None = None
    size: str | None = None
    product_type: str | None = None
    material: str | None = None
    shelf_number: str | None = None
    is_active: bool | None = None
    reorder_point: Decimal | None = None
    reorder_qty: Decimal | None = None
    stock_status: str | None = None

    @field_validator("retail_price", "wholesale_price", "cost_price", "reorder_point", "reorder_qty")
    @classmethod
    def prices_non_negative(cls, v):
        if v is not None and v < 0:
            raise ValueError("must be >= 0")
        return v


class ProductOut(BaseModel):
    id: uuid.UUID
    subcategory_id: uuid.UUID | None = None
    name: str
    code: str | None = None
    barcode: str | None
    unit: str
    retail_price: Decimal
    wholesale_price: Decimal
    cost_price: Decimal
    company: str | None
    size: str | None
    product_type: str | None
    material: str | None
    shelf_number: str | None
    is_active: bool
    reorder_point: Decimal
    reorder_qty: Decimal
    stock_status: str = "untracked"
    created_at: datetime
    updated_at: datetime
    model_config = {"from_attributes": True}


class ProductWithStock(ProductOut):
    current_qty: Decimal = Decimal("0")


class ProductOutWithBalance(ProductOut):
    model_config = {"from_attributes": True, "extra": "allow"}


class ProductBarcodeCreate(BaseModel):
    barcode: str
    is_primary: bool = False


class ProductBarcodeOut(BaseModel):
    id: uuid.UUID
    barcode: str
    is_primary: bool
    created_at: datetime
    model_config = {"from_attributes": True}


class ProductWithBarcodes(ProductOut):
    barcodes: list[ProductBarcodeOut] = []


class MoveProduct(BaseModel):
    subcategory_id: uuid.UUID
