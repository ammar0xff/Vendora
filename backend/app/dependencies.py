from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.db.base import get_db
from app.core.security import decode_token
from app.models.user import User, user_warehouses
from datetime import datetime
from typing import Optional
import uuid

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login", auto_error=False)


def _decode_user_id(payload: dict) -> str:
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    return user_id


async def get_current_user(
    request: Request,
    token: Optional[str] = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    # 1: Try httpOnly cookie first
    cookie_token = request.cookies.get("access_token")
    payload = None
    if cookie_token:
        try:
            payload = decode_token(cookie_token)
        except HTTPException:
            payload = None

    # 2: Fallback to Bearer header (migration compat)
    if not payload and token:
        try:
            payload = decode_token(token)
        except HTTPException:
            payload = None

    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    user_id = _decode_user_id(payload)
    result = await db.execute(
        select(User).where(User.id == uuid.UUID(user_id), User.is_active)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


async def get_print_user(request: Request, db: AsyncSession = Depends(get_db)) -> User:
    t = request.cookies.get("access_token") or request.query_params.get("token")
    if not t:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token required")
    payload = decode_token(t)
    scope = payload.get("scope")
    if scope and scope != "print":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token scope")
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == uuid.UUID(user_id), User.is_active))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


def require_perm(*perms: str):
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        user_perms = current_user.permissions or []
        if any(p in user_perms for p in perms):
            return current_user
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
    return checker


async def require_is_manager(current_user: User = Depends(get_current_user)) -> User:
    if not current_user.is_manager:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="مدير فقط")
    return current_user


async def require_open_period(db: AsyncSession = Depends(get_db)):
    """Block transactions if the current accounting month is closed.
    Uses the same table schema as periods.py (UUID pk, closed_by, closed_at).
    """
    month = datetime.now().strftime("%Y-%m")
    # Use the correct schema (same as periods.py / models/period.py)
    try:
        status_row = (await db.execute(text(
            "SELECT status FROM accounting_periods WHERE month=:m"
        ), {"m": month})).scalar_one_or_none()
    except Exception:
        # Table doesn't exist yet — let the transaction proceed; periods.py creates it on first use
        return
    if status_row == "closed":
        raise HTTPException(status_code=400, detail=f"الشهر {month} مغلق — لا يمكن إجراء المعاملات")


async def verify_warehouse_access(
    db: AsyncSession,
    current_user: User,
    warehouse_id: uuid.UUID | None,
) -> uuid.UUID | None:
    """Check if user has access to a warehouse. Returns warehouse_id if valid."""
    if warehouse_id is None:
        return None
    if current_user.is_manager:
        return warehouse_id
    result = await db.execute(
        select(user_warehouses.c.warehouse_id).where(
            user_warehouses.c.user_id == current_user.id,
            user_warehouses.c.warehouse_id == warehouse_id,
        )
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="ليس لديك صلاحية الوصول إلى هذا الفرع")
    return warehouse_id


