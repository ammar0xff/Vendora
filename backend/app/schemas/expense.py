from decimal import Decimal
from datetime import date
from typing import Optional
from pydantic import BaseModel, Field
from uuid import UUID


class ExpenseVendorCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    phone: Optional[str] = Field(None, max_length=32)
    address: Optional[str] = None
    tax_id: Optional[str] = Field(None, max_length=64)
    notes: Optional[str] = None


class ExpenseVendorUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=128)
    phone: Optional[str] = Field(None, max_length=32)
    address: Optional[str] = None
    tax_id: Optional[str] = Field(None, max_length=64)
    notes: Optional[str] = None
    is_active: Optional[bool] = None


class ExpenseCreate(BaseModel):
    vendor_id: Optional[UUID] = None
    category_id: Optional[UUID] = None
    warehouse_id: Optional[UUID] = None
    amount: Decimal = Field(..., gt=0)
    description: str = Field(..., min_length=1)
    date: Optional[date] = None
    payment_method: Optional[str] = None
    wallet_id: Optional[UUID] = None
    safe_id: Optional[UUID] = None
    is_recurring: bool = False
    recurring_interval: Optional[str] = None
    recurring_end_date: Optional[date] = None
    notes: Optional[str] = None


class ExpenseUpdate(BaseModel):
    vendor_id: Optional[UUID] = None
    category_id: Optional[UUID] = None
    warehouse_id: Optional[UUID] = None
    amount: Optional[Decimal] = Field(None, gt=0)
    description: Optional[str] = Field(None, min_length=1)
    date: Optional[date] = None
    payment_method: Optional[str] = None
    wallet_id: Optional[UUID] = None
    safe_id: Optional[UUID] = None
    status: Optional[str] = None
    notes: Optional[str] = None


class ExpenseApprove(BaseModel):
    approved: bool = True
    notes: Optional[str] = None
