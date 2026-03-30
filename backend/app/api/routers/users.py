from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.db.base import get_db
from app.schemas.user import UserCreate, UserUpdate, UserOut
from app.services import auth_service
from app.dependencies import require_role, get_current_user
from app.models.user import User
from app.core.exceptions import NotFoundError
import uuid

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/managers")
async def list_managers(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Any authenticated user can get the list of managers (for shift close)."""
    rows = await db.execute(text("SELECT id, full_name FROM users WHERE is_manager = true AND is_active = true ORDER BY full_name"))
    return [{"id": str(r.id), "full_name": r.full_name} for r in rows.fetchall()]


@router.get("/staff")
async def list_staff(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Any authenticated user can get basic staff list (id + name) for display purposes."""
    rows = await db.execute(text("SELECT id, full_name, role FROM users WHERE is_active = true ORDER BY full_name"))
    return [{"id": str(r.id), "full_name": r.full_name, "role": r.role} for r in rows.fetchall()]


@router.get("")
async def list_users(db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    rows = await db.execute(text("""
        SELECT u.*, w.name as default_warehouse_name
        FROM users u
        LEFT JOIN warehouses w ON w.id = u.default_warehouse_id
        WHERE u.is_active = true ORDER BY u.full_name
    """))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("", response_model=UserOut)
async def create_user(data: UserCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    return await auth_service.create_user(db, data)


@router.get("/{user_id}", response_model=UserOut)
async def get_user(user_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise NotFoundError("User not found")
    return user


@router.put("/{user_id}")
async def update_user(user_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise NotFoundError("User not found")
    allowed = {"full_name", "role", "is_manager", "default_warehouse_id"}
    for k, v in data.items():
        if k in allowed:
            setattr(user, k, v if v != "" else None)
    await db.commit()
    await db.refresh(user)
    return user


@router.post("/{user_id}/reset-password", status_code=204)
async def reset_password(user_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    from app.core.security import hash_password
    new_pw = data.get("password", "").strip()
    if len(new_pw) < 4:
        from fastapi import HTTPException
        raise HTTPException(400, "كلمة المرور قصيرة جداً")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user: raise NotFoundError()
    user.password_hash = hash_password(new_pw)
    await db.commit()


@router.delete("/{user_id}", status_code=204)
async def delete_user(user_id: uuid.UUID, db: AsyncSession = Depends(get_db), current_user=Depends(require_role("admin"))):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise NotFoundError("User not found")
    if str(user.id) == str(current_user.id):
        from app.core.exceptions import BusinessError
        raise BusinessError("Cannot delete your own account")
    user.is_active = False
    await db.commit()
