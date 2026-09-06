from __future__ import annotations

from pydantic import BaseModel, Field, field_validator

_VALID_PERMISSIONS = {
    "pos", "sales", "quotations", "inventory", "operations",
    "customers", "reports", "archive", "payroll", "users",
    "settings", "admin", "shifts", "finance",
}


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

    @field_validator("permissions")
    @classmethod
    def validate_permissions(cls, v: list[str]) -> list[str]:
        unknown = set(v) - _VALID_PERMISSIONS
        if unknown:
            raise ValueError(f"Unknown permissions: {', '.join(sorted(unknown))}")
        return v
