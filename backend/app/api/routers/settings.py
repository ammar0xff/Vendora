from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm
from pydantic import BaseModel
from typing import Any
import logging
import re

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/settings", tags=["settings"])

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"}
MAX_UPLOAD_SIZE = 5 * 1024 * 1024


class SettingsUpdate(BaseModel):
    settings: dict[str, Any]


@router.post("/upload-logo")
async def upload_logo(file: UploadFile = File(...), db: AsyncSession = Depends(get_db), _=Depends(require_perm("settings"))):
    import os, io
    from app.core.config import settings as cfg
    from PIL import Image
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP")
    contents = await file.read()
    if len(contents) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 5 ميجابايت")
    os.makedirs(cfg.UPLOAD_DIR, exist_ok=True)
    # Clean old generated PWA icons
    for f in os.listdir(cfg.UPLOAD_DIR):
        if f.startswith("logo-") and f.endswith(".png"):
            os.remove(os.path.join(cfg.UPLOAD_DIR, f))
    safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', file.filename or "logo.png")
    ext = os.path.splitext(safe_name)[1] or ".png"
    dest = os.path.join(cfg.UPLOAD_DIR, f"logo{ext}")
    with open(dest, "wb") as f:
        f.write(contents)
    # Generate square PWA icons from uploaded image
    img = Image.open(io.BytesIO(contents))
    w, h = img.size
    size = min(w, h)
    left = (w - size) // 2
    top = (h - size) // 2
    cropped = img.crop((left, top, left + size, top + size))
    for icon_size in (192, 512):
        resized = cropped.resize((icon_size, icon_size), Image.LANCZOS)
        resized.save(os.path.join(cfg.UPLOAD_DIR, f"logo-{icon_size}x{icon_size}.png"), "PNG")
    url = f"/uploads/logo{ext}"
    await db.execute(text("UPDATE store_settings SET value=:v WHERE key='logo_url'"), {"v": url})
    await db.commit()
    return {"logo_url": url}


@router.get("/manifest.json", include_in_schema=False)
async def pwa_manifest(db: AsyncSession = Depends(get_db)):
    """Dynamic PWA manifest using logo from settings."""
    import os
    rows = (await db.execute(text("SELECT key, value FROM store_settings WHERE key IN ('store_name','logo_url')"))).fetchall()
    s = {r.key: r.value for r in rows}
    name = s.get("store_name") or "نظام إدارة الأعمال"
    logo = s.get("logo_url") or ""
    icons = []
    if logo:
        if logo.startswith("/"):
            base = os.path.splitext(logo)[0]
            icons.append({"src": f"{base}-192x192.png", "sizes": "192x192", "type": "image/png", "purpose": "any"})
            icons.append({"src": f"{base}-512x512.png", "sizes": "512x512", "type": "image/png", "purpose": "any maskable"})
        else:
            icons.append({"src": logo, "sizes": "any", "type": "image/png", "purpose": "any maskable"})
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
async def update_settings(data: SettingsUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("settings"))):
    import json as _json
    from app.models.settings import StoreSetting
    for key, value in data.settings.items():
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
