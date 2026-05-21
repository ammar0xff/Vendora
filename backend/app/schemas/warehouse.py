from pydantic import BaseModel, Field


class WarehouseCreate(BaseModel):
    code: str = Field(..., min_length=1, max_length=32)
    name: str = Field(..., min_length=1, max_length=128)
    warehouse_type: str = Field(default="warehouse", pattern="^(showroom|warehouse)$")


class WarehouseUpdate(BaseModel):
    code: str | None = Field(None, min_length=1, max_length=32)
    name: str | None = Field(None, min_length=1, max_length=128)
    warehouse_type: str | None = Field(None, pattern="^(showroom|warehouse)$")
    is_active: bool | None = None
