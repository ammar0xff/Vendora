from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import os
from app.db.base import engine, Base
from app.api.router import router
from app.core.config import settings

# Import all models so Base knows about them before create_all
import app.models.user       # noqa
import app.models.product    # noqa
import app.models.warehouse  # noqa
import app.models.stock      # noqa
import app.models.party      # noqa
import app.models.sale       # noqa
import app.models.shift      # noqa
import app.models.purchase   # noqa
import app.models.archive    # noqa
import app.models.payroll    # noqa
import app.models.settings   # noqa
import app.models.customer_payment  # noqa


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


app = FastAPI(title="Inventory ERP API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.include_router(router)


@app.get("/health")
async def health():
    return {"status": "ok"}
