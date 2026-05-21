from __future__ import annotations
from decimal import Decimal
from datetime import date
from typing import Optional
from pydantic import BaseModel, Field


class ExpenseVendorCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    phone: str | None = Field(None, max_length=32)
    address: str | None = None
    tax_id: str | None = Field(None, max_length=64)
    notes: str | None = None


class ExpenseVendorUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    phone: str | None = Field(None, max_length=32)
    address: str | None = None
    tax_id: str | None = Field(None, max_length=64)
    notes: str | None = None
    is_active: bool | None = None


class ExpenseCreate(BaseModel):
    vendor_id: str | None = None
    category_id: str | None = None
    warehouse_id: str | None = None
    amount: Decimal = Field(..., gt=0)
    description: str = Field(..., min_length=1)
    date: Optional[date] = None
    payment_method: str | None = None
    wallet_id: str | None = None
    safe_id: str | None = None
    is_recurring: bool = False
    recurring_interval: str | None = None
    recurring_end_date: date | None = None
    notes: str | None = None


class ExpenseUpdate(BaseModel):
    vendor_id: str | None = None
    category_id: str | None = None
    warehouse_id: str | None = None
    amount: Decimal | None = Field(None, gt=0)
    description: str | None = Field(None, min_length=1)
    date: Optional[date] = None
    payment_method: str | None = None
    wallet_id: str | None = None
    safe_id: str | None = None
    status: str | None = None
    notes: str | None = None


class ExpenseApprove(BaseModel):
    approved: bool = True
    notes: str | None = None
