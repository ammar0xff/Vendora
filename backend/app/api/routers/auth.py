from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserPasswordUpdate
from app.services import auth_service
from app.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    user = await auth_service.authenticate(db, data.username, data.password)
    return auth_service.issue_token(user)


@router.get("/roles")
async def get_roles():
    from app.core.roles import ROLE_LABELS, ROLE_DEFAULT_PERMISSIONS
    return [{"value": k, "label": v, "permissions": ROLE_DEFAULT_PERMISSIONS.get(k, [])}
            for k, v in ROLE_LABELS.items()]


@router.get("/me")
async def me(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    # Re-attach user to current session and refresh
    user = await db.merge(current_user)
    await db.refresh(user)
    return {
        "id": str(user.id),
        "username": user.username,
        "full_name": user.full_name,
        "role": user.role,
        "permissions": user.permissions or [],
        "is_manager": bool(user.is_manager) if user.is_manager is not None else False,
        "default_warehouse_id": str(user.default_warehouse_id) if user.default_warehouse_id else None,
    }


@router.put("/me/password")
async def change_password(data: UserPasswordUpdate, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    await auth_service.change_password(db, current_user, data.current_password, data.new_password)
    return {"detail": "Password updated"}
