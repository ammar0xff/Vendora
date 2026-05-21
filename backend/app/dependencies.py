from fastapi import Depends, HTTPException, status, Query, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.db.base import get_db
from app.core.security import decode_token, verify_csrf_token
from app.models.user import User
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


async def get_print_user(request: Request, token: str = Query(None), db: AsyncSession = Depends(get_db)) -> User:
    t = token or request.cookies.get("access_token")
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


def require_role(*roles: str):
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role == 'admin':
            return current_user
        if current_user.role in roles:
            return current_user
        user_perms = current_user.permissions or []
        if any(r in user_perms for r in roles):
            return current_user
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
    return checker


def require_perm(*perms: str):
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role == 'admin':
            return current_user
        user_perms = current_user.permissions or []
        if any(p in user_perms for p in perms):
            return current_user
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
    return checker


async def require_open_period(db: AsyncSession = Depends(get_db)):
    await db.execute(text("""
        CREATE TABLE IF NOT EXISTS accounting_periods (
            month TEXT PRIMARY KEY,
            status TEXT DEFAULT 'open',
            locked_at TIMESTAMP,
            locked_by_id UUID REFERENCES users(id)
        )
    """))
    month = datetime.now().strftime("%Y-%m")
    status_row = (await db.execute(text("SELECT status FROM accounting_periods WHERE month=:m"), {"m": month})).scalar_one_or_none()
    if status_row == "closed":
        raise HTTPException(status_code=400, detail=f"الشهر {month} مغلق — لا يمكن إجراء المعاملات")


async def require_csrf(request: Request):
    """Validate CSRF token for authenticated mutating requests.
    
    Skips validation for GET/HEAD/OPTIONS and unauthenticated requests.
    Safe to apply globally via router-level dependencies.
    """
    if request.method in ("GET", "HEAD", "OPTIONS"):
        return
    cookie_token = request.cookies.get("access_token")
    bearer = request.headers.get("Authorization", "").replace("Bearer ", "")
    token_str = cookie_token or bearer or None
    if not token_str:
        return
    try:
        payload = decode_token(token_str)
    except HTTPException:
        return
    user_id = payload.get("sub")
    if not user_id:
        return
    csrf_header = request.headers.get("X-CSRF-Token")
    if not csrf_header:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Missing CSRF token")
    if not verify_csrf_token(user_id, csrf_header):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid CSRF token")
