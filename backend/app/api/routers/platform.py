"""Public platform surface: signup, plans, subscription requests.

Self-serve flow: a merchant signs up through the onboarding wizard →
a workspace tenant is created with a tailored demo dataset → they run on
a trial; the banner routes them to pricing where a subscription request
is recorded until payment integration lands.
"""
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import hash_password
from app.core.tenancy import bind_tenant, current_tenant_id
from app.db.base import get_db
from app.models.tenant import Subscription, Tenant
from app.models.user import User
from app.dependencies import get_current_user
from app.services.demo_seed import seed_demo
from app.core.ratelimit import RateLimiter

router = APIRouter(prefix="/platform", tags=["platform"])

signup_limiter = RateLimiter(max_requests=5, window_seconds=3600)

TRIAL_DAYS = 14

PLANS = [
    {"id": "basic", "name": "أساسي", "price_egp": 499,
     "tagline": "ابدأ صح — فرع واحد جاهز للبيع",
     "features": ["فرع واحد · 3 مستخدمين", "نقطة بيع + مخزون + مبيعات", "عملاء وموردون", "تقارير أساسية"]},
    {"id": "pro", "name": "احترافي", "price_egp": 999, "popular": True,
     "tagline": "للمحلات اللي بتكبر — كل الميزات",
     "features": ["حتى 3 فروع · 15 مستخدمًا", "كل ميزات أساسي", "مشتريات وذمم وخزائن", "تقارير متقدمة + تصدير"]},
    {"id": "enterprise", "name": "مؤسسي", "price_egp": None,
     "tagline": "سلاسل وفروع كثيرة",
     "features": ["فروع ومستخدمون بلا حدود", "صلاحيات متقدمة", "أولوية دعم", "تهيئة وتدريب فريق العمل"]},
]

SECTORS = ["plumbing", "electrical", "tiles", "paint"]
SCALES = ["small", "medium", "large"]


class SignupRequest(BaseModel):
    company_name: str = Field(min_length=2, max_length=128)
    sector: str
    scale: str
    palette: str = "water"
    features: list[str] = Field(default_factory=list)
    owner_username: str = Field(min_length=3, max_length=64, pattern=r"^[a-zA-Z0-9_.-]+$")
    owner_password: str = Field(min_length=6, max_length=128)
    owner_full_name: str = Field(min_length=2, max_length=128)
    owner_phone: str | None = Field(default=None, max_length=32)


class SubscribeRequest(BaseModel):
    plan: str
    contact_phone: str | None = Field(default=None, max_length=32)


@router.get("/plans")
async def list_plans():
    return {"plans": PLANS, "trial_days": TRIAL_DAYS}


@router.post("/signup")
async def signup(data: SignupRequest, request: Request, db: AsyncSession = Depends(get_db), _=Depends(signup_limiter)):
    if data.sector not in SECTORS or data.scale not in SCALES:
        raise HTTPException(status_code=422, detail="نشاط غير معروف")

    existing = await db.execute(select(User.id).where(User.username == data.owner_username))
    if existing.scalar():
        raise HTTPException(status_code=409, detail="اسم المستخدم محجوز — اختر اسمًا آخر")

    tenant = Tenant(
        id=uuid.uuid4(),
        name=data.company_name.strip(),
        sector=data.sector,
        scale=data.scale,
        palette={"hue": {"water": 250, "emerald": 155, "copper": 55, "midnight": 230}.get(data.palette, 250)},
        features=data.features,
        plan="trial",
        trial_ends_at=datetime.now(timezone.utc) + timedelta(days=TRIAL_DAYS),
    )
    db.add(tenant)
    await db.flush()

    await bind_tenant(db, tenant.id)  # seed inside the tenant's context (ctx + RLS GUC)
    owner = User(
        id=uuid.uuid4(),
        username=data.owner_username,
        full_name=data.owner_full_name.strip(),
        role="admin",
        password_hash=hash_password(data.owner_password),
        tenant_id=tenant.id,
    )
    db.add(owner)
    await db.flush()

    await seed_demo(db, tenant.id, owner.id, data.sector, data.scale, data.features)

    await db.commit()

    # issue a token exactly like /auth/login does
    from app.services import auth_service
    token = auth_service.issue_token(owner)
    from app.api.routers.auth import TokenResponse
    body = TokenResponse(
        access_token=token["access_token"], token_type="bearer",
        user_id=token["user_id"], username=token["username"],
        full_name=token["full_name"], role=token["role"],
    ).model_dump()
    from fastapi.responses import JSONResponse
    resp = JSONResponse(content={**body, "tenant": {
        "id": str(tenant.id), "name": tenant.name, "plan": tenant.plan,
        "trial_ends_at": tenant.trial_ends_at.isoformat(), "palette": tenant.palette,
        "features": tenant.features,
    }})
    resp.set_cookie(
        key="access_token", value=token["access_token"],
        httponly=True, secure=settings.IS_PRODUCTION, samesite="lax",
        max_age=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60, path="/",
    )
    return resp


@router.post("/subscribe-request")
async def subscribe_request(data: SubscribeRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    tid = current_tenant_id.get()
    if tid is None:
        raise HTTPException(status_code=403, detail="لا يوجد مساحة عمل مرتبطة")
    sub = Subscription(id=uuid.uuid4(), tenant_id=tid, plan=data.plan,
                       status="requested", contact_phone=data.contact_phone)
    db.add(sub)
    await db.commit()
    return {"status": "requested", "plan": data.plan,
            "message": "وصلنا طلبك — فريق المبيعات هيتواصل معاك لتفعيل الخطة"}


@router.get("/me/tenant")
async def my_tenant(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    tid = current_tenant_id.get()
    tenant = (await db.execute(select(Tenant).where(Tenant.id == tid))).scalar_one_or_none()
    if not tenant:
        raise HTTPException(status_code=404, detail="لا توجد مساحة عمل")
    return {
        "id": str(tenant.id), "name": tenant.name, "sector": tenant.sector,
        "scale": tenant.scale, "palette": tenant.palette, "features": tenant.features,
        "plan": tenant.plan, "trial_ends_at": tenant.trial_ends_at.isoformat() if tenant.trial_ends_at else None,
    }
