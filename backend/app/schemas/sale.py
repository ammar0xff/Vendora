import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel
from app.models.sale import SaleMode, SaleStatus


class SaleItemCreate(BaseModel):
    product_id: uuid.UUID
    qty: Decimal
    unit_price: Decimal
    unit_cost: Decimal = Decimal("0")
    discount: Decimal = Decimal("0")


class SaleCreate(BaseModel):
    customer_id: Optional[uuid.UUID] = None
    warehouse_id: uuid.UUID
    shift_id: Optional[uuid.UUID] = None
    sale_mode: SaleMode = SaleMode.retail
    discount_amount: Decimal = Decimal("0")
    is_credit: bool = False
    payment_method: str = "cash"
    wallet_id: Optional[uuid.UUID] = None
    notes: Optional[str] = None
    items: List[SaleItemCreate]


class SaleItemOut(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    qty: Decimal
    unit_price: Decimal
    unit_cost: Decimal
    discount: Decimal
    model_config = {"from_attributes": True}


class SaleOut(BaseModel):
    id: uuid.UUID
    invoice_number: str
    customer_id: Optional[uuid.UUID]
    warehouse_id: uuid.UUID
    cashier_id: uuid.UUID
    shift_id: Optional[uuid.UUID]
    sale_mode: SaleMode
    status: SaleStatus
    discount_amount: Decimal
    is_credit: bool = False
    notes: Optional[str]
    created_at: datetime
    items: List[SaleItemOut] = []
    model_config = {"from_attributes": True}
