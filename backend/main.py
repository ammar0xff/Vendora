from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import os
from app.db.base import engine, Base
from app.api.router import router
from app.core.config import settings
from app.middleware import CSRFSecurityMiddleware

import app.models.user
import app.models.product
import app.models.warehouse
import app.models.stock
import app.models.party
import app.models.payment_wallet
import app.models.sale
import app.models.shift
import app.models.purchase
import app.models.archive
import app.models.payroll
import app.models.settings
import app.models.customer_payment


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


app = FastAPI(title="Inventory ERP API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(CSRFSecurityMiddleware)

os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.include_router(router)


@app.get("/health")
async def health():
    from app.db.base import AsyncSessionLocal
    from sqlalchemy import text
    try:
        async with AsyncSessionLocal() as sess:
            await sess.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except Exception as e:
        return {"status": "degraded", "database": "disconnected", "detail": str(e)}
