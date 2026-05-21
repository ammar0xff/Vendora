from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user import User
from app.core.security import verify_password, create_access_token, hash_password
from fastapi import HTTPException, status


async def authenticate(db: AsyncSession, username: str, password: str) -> User:
    result = await db.execute(select(User).where(User.username == username, User.is_active))
    user = result.scalar_one_or_none()
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    return user


def issue_token(user: User) -> dict:
    token = create_access_token({"sub": str(user.id), "role": user.role, "username": user.username})
    return {"access_token": token, "token_type": "bearer", "user_id": str(user.id), "username": user.username, "role": user.role}


async def create_user(db: AsyncSession, data) -> User:
    from app.core.roles import ROLE_DEFAULT_PERMISSIONS
    from sqlalchemy.exc import IntegrityError
    from fastapi import HTTPException
    user = User(
        username=data.username,
        full_name=data.full_name,
        role=data.role,
        password_hash=hash_password(data.password),
        permissions=ROLE_DEFAULT_PERMISSIONS.get(data.role, []),
    )
    db.add(user)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(400, f"اسم المستخدم '{data.username}' مستخدم بالفعل")
    await db.refresh(user)
    return user


async def change_password(db: AsyncSession, user: User, current_password: str, new_password: str):
    if not verify_password(current_password, user.password_hash):
        raise HTTPException(status_code=400, detail="Current password incorrect")
    user.password_hash = hash_password(new_password)
    await db.commit()
