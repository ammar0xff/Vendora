import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field


class SupplierPriceCreate(BaseModel):
    supplier_id: uuid.UUID
    product_id: uuid.UUID
    price: Decimal = Field(gt=0)
    currency: str = "EGP"
    min_qty: Decimal = Field(default=1, ge=1)
    notes: str | None = None


class SupplierPriceUpdate(BaseModel):
    price: Decimal | None = Field(None, gt=0)
    currency: str | None = None
    min_qty: Decimal | None = Field(None, ge=1)
    notes: str | None = None
    is_active: bool | None = None


class SupplierPriceOut(BaseModel):
    id: uuid.UUID
    supplier_id: uuid.UUID
    product_id: uuid.UUID
    price: Decimal
    currency: str
    min_qty: Decimal
    last_purchase_date: datetime | None
    notes: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    model_config = {"from_attributes": True}


class SupplierPriceWithSupplier(SupplierPriceOut):
    supplier_name: str = ""


class SupplierPriceComparison(BaseModel):
    product_id: uuid.UUID
    product_name: str
    suppliers: list[SupplierPriceWithSupplier] = []
