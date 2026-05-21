from fastapi import APIRouter, Depends, Request, Response
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserPasswordUpdate
from app.services import auth_service
from app.dependencies import get_current_user
from app.models.user import User
from app.core.ratelimit import RateLimiter
from app.core.security import create_csrf_token, create_access_token
from app.core.config import settings
from datetime import timedelta

router = APIRouter(prefix="/auth", tags=["auth"])

login_limiter = RateLimiter(max_requests=10, window_seconds=60)


@router.post("/login")
async def login(data: LoginRequest, request: Request, db: AsyncSession = Depends(get_db), _=Depends(login_limiter)):
    user = await auth_service.authenticate(db, data.username, data.password)
    token = auth_service.issue_token(user)
    csrf = create_csrf_token(str(user.id))
    body = TokenResponse(
        access_token=token["access_token"],
        token_type="bearer",
        user_id=token["user_id"],
        username=token["username"],
        full_name=token["full_name"],
        role=token["role"],
        csrf_token=csrf,
    ).model_dump()
    resp = JSONResponse(content=body)
    resp.set_cookie(
        key="access_token",
        value=token["access_token"],
        httponly=True,
        samesite="lax",
        max_age=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        path="/",
    )
    return resp


@router.get("/csrf")
async def get_csrf_token(current_user: User = Depends(get_current_user)):
    csrf = create_csrf_token(str(current_user.id))
    return {"csrf_token": csrf}


@router.get("/roles")
async def get_roles(_=Depends(get_current_user)):
    from app.core.roles import ROLE_LABELS, ROLE_DEFAULT_PERMISSIONS
    return [{"value": k, "label": v, "permissions": ROLE_DEFAULT_PERMISSIONS.get(k, [])}
            for k, v in ROLE_LABELS.items()]


@router.get("/me")
async def me(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    user = await db.merge(current_user)
    await db.refresh(user)
    csrf = create_csrf_token(str(user.id))
    return {
        "id": str(user.id),
        "username": user.username,
        "full_name": user.full_name,
        "role": user.role,
        "permissions": user.permissions or [],
        "is_manager": bool(user.is_manager) if user.is_manager is not None else False,
        "default_warehouse_id": str(user.default_warehouse_id) if user.default_warehouse_id else None,
        "csrf_token": csrf,
    }


@router.put("/me/password")
async def change_password(data: UserPasswordUpdate, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    await auth_service.change_password(db, current_user, data.current_password, data.new_password)
    return {"detail": "Password updated"}


@router.post("/print-token")
async def issue_print_token(current_user: User = Depends(get_current_user)):
    from app.core.security import create_access_token
    from datetime import timedelta
    token = create_access_token(
        {"sub": str(current_user.id), "scope": "print"},
        expires_delta=timedelta(seconds=60),
    )
    return {"token": token}
