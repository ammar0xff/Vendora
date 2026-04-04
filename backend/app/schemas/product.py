import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel


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
    retail_price: Decimal = Decimal("0")
    wholesale_price: Decimal = Decimal("0")
    cost_price: Decimal = Decimal("0")
    company: Optional[str] = None
    size: Optional[str] = None
    product_type: Optional[str] = None
    material: Optional[str] = None
    image_url: Optional[str] = None
    reorder_point: Decimal = Decimal("0")
    reorder_qty: Decimal = Decimal("0")


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
    stock_status: str = "tracked"
    created_at: datetime
    updated_at: datetime
    model_config = {"from_attributes": True}


class ProductWithStock(ProductOut):
    current_qty: Decimal = Decimal("0")
