from __future__ import annotations
from decimal import Decimal
from pydantic import BaseModel, Field


class CustomerCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    phone: str | None = Field(None, max_length=32)
    address: str | None = None
    is_cash: bool = False
    credit_limit: Decimal | None = Field(None, ge=0)


class CustomerUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    phone: str | None = Field(None, max_length=32)
    address: str | None = None
    is_cash: bool | None = None
    credit_limit: Decimal | None = Field(None, ge=0)


class CustomerPaymentCreate(BaseModel):
    amount: Decimal = Field(..., gt=0)
    note: str | None = None


class SupplierCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    phone: str | None = Field(None, max_length=32)
    address: str | None = None



