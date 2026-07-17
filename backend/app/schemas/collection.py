from __future__ import annotations
import uuid
from decimal import Decimal
from pydantic import BaseModel, Field


class CollectionItem(BaseModel):
    product_id: uuid.UUID
    qty: Decimal = Field(..., gt=0)


class CollectionCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    description: str = ""
    retail_price: Decimal = Decimal("0")
    wholesale_price: Decimal = Decimal("0")
    items: list[CollectionItem] = []


class CollectionUpdate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    description: str = ""
    retail_price: Decimal = Decimal("0")
    wholesale_price: Decimal = Decimal("0")
    items: list[CollectionItem] = []
