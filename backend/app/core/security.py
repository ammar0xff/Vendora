from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
import bcrypt
import hmac
import hashlib
import uuid
from fastapi import HTTPException, status
from app.core.config import settings


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    expire = now + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode["exp"] = expire
    to_encode["iat"] = now
    to_encode["jti"] = str(uuid.uuid4())
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


def create_csrf_token(user_id: str) -> str:
    msg = f"{user_id}:{settings.SECRET_KEY}"
    return hmac.new(settings.SECRET_KEY.encode(), msg.encode(), hashlib.sha256).hexdigest()


def verify_csrf_token(user_id: str, token: str) -> bool:
    expected = create_csrf_token(user_id)
    return hmac.compare_digest(expected, token)
