from fastapi import Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_db
from app.core.security import decode_token
from app.models.user import User
import uuid

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    payload = decode_token(token)
    user_id = payload.get("sub")
    result = await db.execute(
        select(User).where(User.id == uuid.UUID(user_id), User.is_active == True)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


async def get_print_user(token: str = Query(None), db: AsyncSession = Depends(get_db)) -> User:
    """Accepts token from query param — for print/report endpoints opened in new tab."""
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token required")
    payload = decode_token(token)
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == uuid.UUID(user_id), User.is_active == True))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


def require_role(*roles: str):
    """Allow access if user's role OR permissions match any of the given roles/permissions."""
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


# ── Permission-based shortcuts ────────────────────────────────────────────────
# Use these instead of require_role("admin") for granular access control

def require_perm(*perms: str):
    """Allow if user has admin role OR any of the listed permissions."""
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role == 'admin':
            return current_user
        user_perms = current_user.permissions or []
        if any(p in user_perms for p in perms):
            return current_user
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
    return checker
