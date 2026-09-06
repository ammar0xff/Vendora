"""
notifications.py — Push notification infrastructure (FCM)
- Register/unregister device tokens
- Send push notifications to users
Requires: FIREBASE_CREDENTIALS env var pointing to service account JSON
"""
import logging
import os

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import get_db
from app.dependencies import get_current_user, require_perm
from app.models.device_token import DeviceToken
from app.models.user import User

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/notifications", tags=["notifications"])

_firebase_app = None


def _get_firebase_app():
    """Lazy-initialize Firebase Admin SDK."""
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    cred_path = os.environ.get("FIREBASE_CREDENTIALS")
    if not cred_path or not os.path.exists(cred_path):
        logger.warning("FIREBASE_CREDENTIALS not set — push notifications disabled")
        return None

    try:
        import firebase_admin
        from firebase_admin import credentials
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        _firebase_app = firebase_admin.get_app()
        logger.info("Firebase Admin SDK initialized")
        return _firebase_app
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return None


class RegisterTokenRequest(BaseModel):
    token: str
    platform: str = "android"
    device_name: str | None = None


class SendNotificationRequest(BaseModel):
    user_id: str
    title: str
    body: str
    data: dict | None = None


@router.post("/register")
async def register_token(data: RegisterTokenRequest, db: AsyncSession = Depends(get_db),
                         current_user: User = Depends(get_current_user)):
    """Register a device token for push notifications."""
    existing = (await db.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == current_user.id,
            DeviceToken.token == data.token,
        )
    )).scalar_one_or_none()

    if existing:
        existing.is_active = True
        existing.platform = data.platform
        existing.device_name = data.device_name
    else:
        db.add(DeviceToken(
            user_id=current_user.id,
            token=data.token,
            platform=data.platform,
            device_name=data.device_name,
        ))
    await db.commit()
    return {"detail": "Token registered"}


@router.post("/unregister")
async def unregister_token(token: str, db: AsyncSession = Depends(get_db),
                           current_user: User = Depends(get_current_user)):
    """Deactivate a device token."""
    await db.execute(
        update(DeviceToken).where(
            DeviceToken.user_id == current_user.id,
            DeviceToken.token == token,
        ).values(is_active=False)
    )
    await db.commit()
    return {"detail": "Token unregistered"}


@router.post("/send")
async def send_notification(data: SendNotificationRequest, db: AsyncSession = Depends(get_db),
                           current_user: User = Depends(require_perm("admin"))):
    """Send a push notification to a specific user (admin only)."""
    app = _get_firebase_app()
    if not app:
        raise HTTPException(503, "Push notifications not configured (FIREBASE_CREDENTIALS missing)")

    from firebase_admin import messaging

    tokens = (await db.execute(
        select(DeviceToken.token).where(
            DeviceToken.user_id == data.user_id,
            DeviceToken.is_active.is_(True),
        )
    )).scalars().all()

    if not tokens:
        return {"detail": "No active devices", "sent": 0}

    message = messaging.MulticastMessage(
        notification=messaging.Notification(title=data.title, body=data.body),
        data=data.data or {},
        tokens=list(tokens),
    )

    try:
        response = messaging.send_each_for_multicast(message)
        return {"detail": "Sent", "success": response.success_count, "failed": response.failure_count}
    except Exception as e:
        logger.error(f"FCM send error: {e}")
        raise HTTPException(500, f"Failed to send: {e}") from e


@router.get("/tokens")
async def list_tokens(user_id: str = None, db: AsyncSession = Depends(get_db),
                      current_user: User = Depends(require_perm("admin"))):
    """List registered device tokens (admin only)."""
    q = select(DeviceToken)
    if user_id:
        q = q.where(DeviceToken.user_id == user_id)
    tokens = (await db.execute(q.order_by(DeviceToken.created_at.desc()).limit(100))).scalars().all()
    return [
        {"id": str(t.id), "user_id": str(t.user_id), "platform": t.platform,
         "device_name": t.device_name, "is_active": t.is_active,
         "created_at": t.created_at.isoformat()}
        for t in tokens
    ]
