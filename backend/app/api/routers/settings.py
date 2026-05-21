from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/settings", tags=["settings"])

# Store settings are key/value rows in store_settings table
# We use a simple dict-based approach here


@router.post("/upload-logo")
async def upload_logo(file: UploadFile = File(...), db: AsyncSession = Depends(get_db), _=Depends(require_perm("settings"))):
    import os
    import shutil
    from app.core.config import settings as cfg
    os.makedirs(cfg.UPLOAD_DIR, exist_ok=True)
    ext = os.path.splitext(file.filename or "logo.png")[1] or ".png"
    dest = os.path.join(cfg.UPLOAD_DIR, f"logo{ext}")
    with open(dest, "wb") as f:
        shutil.copyfileobj(file.file, f)
    url = f"/uploads/logo{ext}"
    await db.execute(text("UPDATE store_settings SET value=:v WHERE key='logo_url'"), {"v": url})
    await db.commit()
    return {"logo_url": url}


@router.get("/manifest.json", include_in_schema=False)
async def pwa_manifest(db: AsyncSession = Depends(get_db)):
    """Dynamic PWA manifest using logo from settings."""
    rows = (await db.execute(text("SELECT key, value FROM store_settings WHERE key IN ('store_name','logo_url')"))).fetchall()
    s = {r.key: r.value for r in rows}
    name = s.get("store_name") or "نظام إدارة الأعمال"
    logo = s.get("logo_url") or ""
    icons = []
    if logo:
        icons.append({"src": logo, "sizes": "any", "type": "image/png", "purpose": "any maskable"})
    icons += [
        {"src": "/icon-192.png", "sizes": "192x192", "type": "image/png", "purpose": "any"},
        {"src": "/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable"},
    ]
    from fastapi.responses import JSONResponse
    return JSONResponse({"name": name, "short_name": name[:12], "theme_color": "#1e3a5f",
                         "background_color": "#1e3a5f", "display": "standalone",
                         "start_url": "/", "lang": "ar", "dir": "rtl", "icons": icons})


@router.get("")
async def get_settings(db: AsyncSession = Depends(get_db)):
    """Public endpoint — returns store settings for login page and app."""
    import json as _json
    from app.models.settings import StoreSetting
    result = await db.execute(select(StoreSetting))
    out = {}
    for row in result.scalars().all():
        try:
            out[row.key] = _json.loads(row.value) if row.value and row.value.startswith(('[', '{')) else row.value
        except (ValueError, _json.JSONDecodeError):
            logger.warning("Failed to parse setting %s: %s", row.key, row.value)
            out[row.key] = row.value
    return out


@router.put("")
async def update_settings(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("settings"))):
    import json as _json
    from app.models.settings import StoreSetting
    for key, value in data.items():
        # Store lists/dicts as JSON string
        str_value = _json.dumps(value, ensure_ascii=False) if isinstance(value, (list, dict)) else str(value)
        result = await db.execute(select(StoreSetting).where(StoreSetting.key == key))
        row = result.scalar_one_or_none()
        if row:
            row.value = str_value
        else:
            db.add(StoreSetting(key=key, value=str_value))
    await db.commit()
    return {"detail": "Settings updated"}


@router.get("/product-options")
async def get_product_options(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Return sizes, companies, materials, units lists."""
    from app.models.settings import StoreSetting
    import json as _json
    keys = ["product_options_sizes", "product_options_companies", "product_options_materials", "product_options_units"]
    result = await db.execute(select(StoreSetting).where(StoreSetting.key.in_(keys)))
    rows = {r.key: r.value for r in result.scalars().all()}
    return {
        "sizes":     _json.loads(rows.get("product_options_sizes", "[]")),
        "companies": _json.loads(rows.get("product_options_companies", "[]")),
        "materials": _json.loads(rows.get("product_options_materials", "[]")),
        "units":     _json.loads(rows.get("product_options_units", "[]")),
    }


@router.put("/product-options")
async def update_product_options(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_perm("settings"))):
    """Update one or more option lists. Pass {sizes:[...], companies:[...], ...}"""
    from app.models.settings import StoreSetting
    import json as _json
    mapping = {"sizes": "product_options_sizes", "companies": "product_options_companies",
               "materials": "product_options_materials", "units": "product_options_units"}
    for field, db_key in mapping.items():
        if field in data:
            result = await db.execute(select(StoreSetting).where(StoreSetting.key == db_key))
            row = result.scalar_one_or_none()
            val = _json.dumps(data[field], ensure_ascii=False)
            if row:
                row.value = val
            else:
                db.add(StoreSetting(key=db_key, value=val))
    await db.commit()
    return {"detail": "Product options updated"}
