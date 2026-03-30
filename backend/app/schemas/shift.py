import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel
from app.models.shift import ShiftStatus, DrawerTxType


class ShiftOpen(BaseModel):
    initial_amount: Decimal
    warehouse_id: uuid.UUID
    supervisor_id: Optional[uuid.UUID] = None


class ShiftClose(BaseModel):
    closing_balance: Decimal
    next_day_drawer: Optional[Decimal] = None
    notes: Optional[str] = None


class DrawerTxCreate(BaseModel):
    type: DrawerTxType
    amount: Decimal
    note: Optional[str] = None
    customer_id: Optional[uuid.UUID] = None
    category_id: Optional[uuid.UUID] = None


class DrawerTxOut(BaseModel):
    id: uuid.UUID
    shift_id: uuid.UUID
    type: DrawerTxType
    amount: Decimal
    note: Optional[str]
    created_at: datetime
    model_config = {"from_attributes": True}


class ShiftSummary(BaseModel):
    shift_id: uuid.UUID
    initial_amount: Decimal
    sales_total: Decimal
    returns_total: Decimal
    expenses_total: Decimal
    expected_balance: Decimal
    closing_balance: Optional[Decimal]
    variance: Optional[Decimal]
    transaction_count: int


class ShiftOut(BaseModel):
    id: uuid.UUID
    cashier_id: Optional[uuid.UUID]
    warehouse_id: Optional[uuid.UUID]
    supervisor_id: Optional[uuid.UUID]
    status: ShiftStatus
    initial_amount: Decimal
    closing_balance: Optional[Decimal]
    next_day_drawer: Optional[Decimal]
    started_at: datetime
    closed_at: Optional[datetime]
    model_config = {"from_attributes": True}
