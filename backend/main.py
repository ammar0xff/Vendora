import logging
import os
import tempfile
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

import app.models.archive
import app.models.customer_payment
import app.models.device_token
import app.models.expense
import app.models.financial_category
import app.models.party
import app.models.payment_wallet
import app.models.payroll
import app.models.period
import app.models.product
import app.models.purchase
import app.models.safe
import app.models.sale
import app.models.sale_payment
import app.models.settings
import app.models.shift
import app.models.stock
import app.models.user
import app.models.warehouse
from app.api.router import router
from app.core.config import settings
from app.db.base import Base, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        # Ensure safe_deposit exists in the doc_type_enum (added after initial creation)
        await conn.execute(text("ALTER TYPE doc_type_enum ADD VALUE IF NOT EXISTS 'safe_deposit'"))
    yield


app = FastAPI(title="Inventory ERP API", version="1.0.0", lifespan=lifespan)

logger = logging.getLogger("validation")


@app.exception_handler(RequestValidationError)
async def log_validation_error(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    logger.error("Validation error on %s %s: %s", request.method, request.url.path, errors)
    safe_errors = []
    for e in errors:
        ctx = e.get("ctx", {})
        clean_ctx = {}
        for k, v in ctx.items():
            clean_ctx[k] = str(v) if not isinstance(v, (str, int, float, bool, type(None))) else v
        safe_errors.append({**e, "ctx": clean_ctx})
    return JSONResponse(status_code=422, content={"detail": safe_errors})


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def _resolve_writable_dir(path: str) -> str:
    """Return the path if writable, else a writable mirror under /tmp."""
    try:
        os.makedirs(path, exist_ok=True)
        probe = os.path.join(path, ".wprobe")
        with open(probe, "w") as f:
            f.write("")
        os.remove(probe)
        return path
    except OSError:
        alt = os.path.join(tempfile.gettempdir(), os.path.basename(path.strip(os.sep)))
        os.makedirs(alt, exist_ok=True)
        return alt


upload_dir = _resolve_writable_dir(settings.UPLOAD_DIR)
settings.UPLOAD_DIR = upload_dir
app.mount("/uploads", StaticFiles(directory=upload_dir), name="uploads")
updates_dir = _resolve_writable_dir(os.environ.get("UPDATES_DIR", "./updates"))
app.mount("/updates", StaticFiles(directory=updates_dir), name="updates")
app.include_router(router)


@app.get("/")
async def root():
    return {"name": "Vendora Inventory ERP API", "docs": "/docs", "health": "/health"}


@app.get("/health")
async def health():
    from sqlalchemy import text

    from app.db.base import AsyncSessionLocal
    try:
        async with AsyncSessionLocal() as sess:
            await sess.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except Exception as e:
        return {"status": "degraded", "database": "disconnected", "detail": str(e)}
