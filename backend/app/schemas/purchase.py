from __future__ import annotations

import uuid
from decimal import Decimal

from pydantic import BaseModel, Field


class PurchaseItemCreate(BaseModel):
    product_id: uuid.UUID
    qty: Decimal = Field(..., gt=0)
    unit_cost: Decimal = Field(..., ge=0)
    notes: str | None = None


class PurchaseCreate(BaseModel):
    warehouse_id: uuid.UUID
    supplier_id: uuid.UUID | None = None
    notes: str | None = None
    amount_paid: Decimal | None = Field(None, ge=0)
    received_by_name: str | None = None
    items: list[PurchaseItemCreate] = []


class PurchaseUpdate(BaseModel):
    supplier_id: uuid.UUID | None = None
    notes: str | None = None
    items: list[PurchaseItemCreate] | None = None


class ReceiveItemOverride(BaseModel):
    product_id: uuid.UUID
    qty_received: Decimal | None = Field(None, gt=0)
    unit_cost: Decimal | None = Field(None, ge=0)


class PurchaseReceive(BaseModel):
    items: list[ReceiveItemOverride] = []


class QuickProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    unit: str = "عدد"
    cost_price: Decimal = 0
    retail_price: Decimal = 0
    wholesale_price: Decimal = 0
    company: str | None = None
    subcategory_id: uuid.UUID | None = None
