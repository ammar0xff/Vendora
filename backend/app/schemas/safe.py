from __future__ import annotations
import uuid
from decimal import Decimal
from pydantic import BaseModel, Field


class SafeCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    location: str | None = None


class SafeUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    location: str | None = None


class SafeTransferCreate(BaseModel):
    from_wallet_id: uuid.UUID
    to_safe_id: uuid.UUID
    amount: Decimal = Field(..., gt=0)
    note: str | None = None


class SafeDepositCreate(BaseModel):
    amount: Decimal = Field(..., gt=0)
    shift_id: uuid.UUID | None = None
    warehouse_id: uuid.UUID | None = None
    received_by_id: uuid.UUID | None = None
    notes: str | None = None


class SafeWithdrawCreate(BaseModel):
    amount: Decimal = Field(..., gt=0)
    note: str | None = None
