from __future__ import annotations
from pydantic import BaseModel, Field


class FinancialCategoryCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=128)
    type: str = "expense"
    color: str = "#64748b"


class FinancialCategoryUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=128)
    color: str | None = None


class PermissionsUpdate(BaseModel):
    permissions: list[str] = []
    is_manager: bool = False
