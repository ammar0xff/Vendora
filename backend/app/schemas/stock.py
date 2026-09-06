import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field, field_validator

from app.models.stock import MovementType


class StockMovementCreate(BaseModel):
    product_id: uuid.UUID
    warehouse_id: uuid.UUID
    movement_type: MovementType
    qty: Decimal = Field(..., gt=0)
    unit_cost: Decimal = Decimal("0")
    unit_price: Decimal = Decimal("0")
    note: str | None = None

    @field_validator('note')
    def note_required_for_damage(cls, v, info):
        movement_type = info.data.get('movement_type') if hasattr(info, 'data') else None
        if movement_type in ('damage', 'adjustment_out') and not v:
            raise ValueError('note is required for damage and adjustment movements')
        return v


class StockMovementOut(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    warehouse_id: uuid.UUID
    movement_type: MovementType
    qty: Decimal
    unit_cost: Decimal
    unit_price: Decimal
    ref_id: uuid.UUID | None
    ref_type: str | None
    sale_id: uuid.UUID | None = None
    purchase_id: uuid.UUID | None = None
    operation_id: uuid.UUID | None = None
    note: str | None
    created_by: uuid.UUID | None
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
    qty: Decimal = Field(..., gt=0)
    note: str | None = None
