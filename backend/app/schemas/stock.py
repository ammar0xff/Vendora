import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel
from app.models.stock import MovementType


class StockMovementCreate(BaseModel):
    product_id: uuid.UUID
    warehouse_id: uuid.UUID
    movement_type: MovementType
    qty: Decimal
    unit_cost: Decimal = Decimal("0")
    unit_price: Decimal = Decimal("0")
    note: Optional[str] = None


class StockMovementOut(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    warehouse_id: uuid.UUID
    movement_type: MovementType
    qty: Decimal
    unit_cost: Decimal
    unit_price: Decimal
    ref_id: Optional[uuid.UUID]
    ref_type: Optional[str]
    note: Optional[str]
    created_by: Optional[uuid.UUID]
    created_at: datetime
    model_config = {"from_attributes": True}


class StockBalance(BaseModel):
    product_id: uuid.UUID
    warehouse_id: uuid.UUID
    current_qty: Decimal


class TransferRequest(BaseModel):
    product_id: uuid.UUID
    from_warehouse_id: uuid.UUID
    to_warehouse_id: uuid.UUID
    qty: Decimal
    note: Optional[str] = None
