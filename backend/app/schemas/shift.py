import uuid
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field
from app.models.shift import ShiftStatus, DrawerTxType


class ShiftOpen(BaseModel):
    initial_amount: Decimal = Field(..., ge=0, description="عهدة الدرج الافتتاحية")
    warehouse_id: uuid.UUID
    supervisor_id: uuid.UUID | None = None


class ShiftClose(BaseModel):
    closing_balance: Decimal = Field(..., ge=0, description="الرصيد الفعلي في الدرج")
    next_day_drawer: Decimal | None = None
    notes: str | None = None


class CloseWithManagerRequest(BaseModel):
    closing_balance: Decimal = Field(..., ge=0)
    next_day_drawer: Decimal | None = None
    notes: str | None = None
    manager_id: uuid.UUID
    manager_password: str


class TransferDrawerRequest(BaseModel):
    to_user_id: uuid.UUID
    amount: Decimal = Field(..., ge=0, description="المبلغ المسلَّم")
    notes: str | None = None


class RevenueDeliveryRequest(BaseModel):
    amount: Decimal = Field(..., gt=0)
    safe_id: uuid.UUID
    manager_id: uuid.UUID
    manager_password: str
    notes: str | None = None


class DrawerTxCreate(BaseModel):
    type: DrawerTxType
    amount: Decimal = Field(..., gt=0)
    note: str | None = None
    customer_id: uuid.UUID | None = None
    category_id: uuid.UUID | None = None
    payment_method: str = "cash"
    wallet_id: uuid.UUID | None = None


class DrawerTxOut(BaseModel):
    id: uuid.UUID
    shift_id: uuid.UUID
    type: DrawerTxType
    amount: Decimal
    ref_id: uuid.UUID | None = None
    note: str | None = None
    category_id: uuid.UUID | None = None
    payment_method: str | None = "cash"
    wallet_id: uuid.UUID | None = None
    created_by: uuid.UUID | None = None
    created_at: datetime
    model_config = {"from_attributes": True}


class ShiftSummary(BaseModel):
    shift_id: uuid.UUID
    initial_amount: Decimal
    sales_total: Decimal
    returns_total: Decimal
    expenses_total: Decimal
    deposits_total: Decimal = Decimal("0")
    withdrawals_total: Decimal = Decimal("0")
    revenue_delivery_total: Decimal = Decimal("0")
    expected_balance: Decimal
    cash_in_drawer: Decimal | None = None
    wallet_total: Decimal | None = None
    closing_balance: Decimal | None = None
    variance: Decimal | None = None
    transaction_count: int
    payment_breakdown: list = []
    wallet_tx_breakdown: list = []


class ShiftOut(BaseModel):
    id: uuid.UUID
    cashier_id: uuid.UUID | None = None
    cashier_name: str | None = None
    warehouse_id: uuid.UUID | None = None
    supervisor_id: uuid.UUID | None = None
    status: ShiftStatus
    initial_amount: Decimal
    closing_balance: Decimal | None = None
    expected_balance: Decimal | None = None
    difference: Decimal | None = None
    next_day_drawer: Decimal | None = None
    deposit_received_by: uuid.UUID | None = None
    deposit_amount: Decimal | None = None
    closed_by: uuid.UUID | None = None
    notes: str | None = None
    started_at: datetime
    closed_at: datetime | None = None
    model_config = {"from_attributes": True}
