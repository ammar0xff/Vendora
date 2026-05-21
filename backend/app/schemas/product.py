import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, Field, field_validator


class CategoryCreate(BaseModel):
    name: str


class CategoryOut(BaseModel):
    id: uuid.UUID
    name: str
    model_config = {"from_attributes": True}


class SubcategoryCreate(BaseModel):
    category_id: uuid.UUID
    name: str


class SubcategoryOut(BaseModel):
    id: uuid.UUID
    category_id: uuid.UUID
    name: str
    model_config = {"from_attributes": True}


class ProductCreate(BaseModel):
    subcategory_id: uuid.UUID
    name: str
    barcode: Optional[str] = None
    unit: str = "عدد"
    retail_price: Decimal = Field(default=Decimal("0"), ge=0)
    wholesale_price: Decimal = Field(default=Decimal("0"), ge=0)
    cost_price: Decimal = Field(default=Decimal("0"), ge=0)
    company: Optional[str] = None
    size: Optional[str] = None
    product_type: Optional[str] = None
    material: Optional[str] = None
    image_url: Optional[str] = None
    reorder_point: Decimal = Field(default=Decimal("0"), ge=0)
    reorder_qty: Decimal = Field(default=Decimal("0"), ge=0)


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    barcode: Optional[str] = None
    unit: Optional[str] = None
    retail_price: Optional[Decimal] = None
    wholesale_price: Optional[Decimal] = None
    cost_price: Optional[Decimal] = None
    subcategory_id: Optional[uuid.UUID] = None
    company: Optional[str] = None
    size: Optional[str] = None
    product_type: Optional[str] = None
    material: Optional[str] = None
    is_active: Optional[bool] = None
    reorder_point: Optional[Decimal] = None
    reorder_qty: Optional[Decimal] = None
    stock_status: Optional[str] = None

    @field_validator("retail_price", "wholesale_price", "cost_price", "reorder_point", "reorder_qty")
    @classmethod
    def prices_non_negative(cls, v):
        if v is not None and v < 0:
            raise ValueError("must be >= 0")
        return v


class ProductOut(BaseModel):
    id: uuid.UUID
    subcategory_id: uuid.UUID
    name: str
    barcode: Optional[str]
    unit: str
    retail_price: Decimal
    wholesale_price: Decimal
    cost_price: Decimal
    company: Optional[str]
    size: Optional[str]
    product_type: Optional[str]
    material: Optional[str]
    is_active: bool
    reorder_point: Decimal
    reorder_qty: Decimal
    stock_status: str = "untracked"
    created_at: datetime
    updated_at: datetime
    model_config = {"from_attributes": True}


class ProductWithStock(ProductOut):
    current_qty: Decimal = Decimal("0")


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
