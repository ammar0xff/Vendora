import os
import re
import uuid
from datetime import datetime
from decimal import Decimal
from typing import Any

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.core.exceptions import BusinessError, NotFoundError
from app.core.pagination import Page
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm, verify_warehouse_access
from app.models.product import Category, Product, ProductBarcode, Subcategory
from app.models.user import User
from app.schemas.product import (
    CategoryCreate,
    CategoryOut,
    MoveProduct,
    ProductBarcodeCreate,
    ProductBarcodeOut,
    ProductCreate,
    ProductOut,
    ProductUpdate,
    ProductWithBarcodes,
    SubcategoryCreate,
    SubcategoryOut,
)
from app.services import product_service
from app.services.audit_service import log as audit_log

router = APIRouter(tags=["products"])


# ── Categories ──────────────────────────────────────────────────────────────
@router.get("/categories", response_model=list[CategoryOut])
async def list_categories(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await product_service.list_categories(db)


@router.post("/categories", response_model=CategoryOut)
async def create_category(data: CategoryCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    return await product_service.create_category(db, data, current_user.id)


@router.put("/categories/{cat_id}", response_model=CategoryOut)
async def update_category(cat_id: uuid.UUID, data: CategoryCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    return await product_service.update_category(db, cat_id, data, current_user.id)


@router.delete("/categories/{cat_id}", status_code=204)
async def delete_category(cat_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    await product_service.delete_category(db, cat_id)


# ── Subcategories ────────────────────────────────────────────────────────────
@router.get("/subcategories", response_model=list[SubcategoryOut])
async def list_subcategories(category_id: uuid.UUID | None = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await product_service.list_subcategories(db, category_id)


@router.post("/subcategories", response_model=SubcategoryOut)
async def create_subcategory(data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    return await product_service.create_subcategory(db, data)


@router.put("/subcategories/{sub_id}", response_model=SubcategoryOut)
async def update_subcategory(sub_id: uuid.UUID, data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    return await product_service.update_subcategory(db, sub_id, data)


# ── Products ─────────────────────────────────────────────────────────────────
@router.get("/products")
async def list_products(
    search: str | None = None,
    subcategory_id: uuid.UUID | None = None,
    category_id: uuid.UUID | None = None,
    warehouse_id: uuid.UUID | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(5000, ge=1, le=5000),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await product_service.list_products(
        db, search, subcategory_id, category_id, warehouse_id, page, page_size, current_user
    )


@router.post("/products", response_model=ProductOut)
async def create_product(data: ProductCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    return await product_service.create_product(db, data, current_user.id)


@router.get("/products/barcode/{barcode}", response_model=ProductOut)
async def get_by_barcode(barcode: str, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await product_service.get_product_by_barcode(db, barcode)


@router.get("/products/{product_id}", response_model=ProductWithBarcodes)
async def get_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await product_service.get_product(db, product_id)


@router.put("/products/{product_id}", response_model=ProductOut)
async def update_product(product_id: uuid.UUID, data: ProductUpdate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    return await product_service.update_product(db, product_id, data, current_user)


@router.delete("/products/{product_id}", status_code=204)
async def delete_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    await product_service.delete_product(db, product_id)


@router.get("/products/{product_id}/movements")
async def product_movements(product_id: uuid.UUID, from_date: str | None = None, to_date: str | None = None, page: int = Query(1, ge=1), page_size: int = Query(100, ge=1, le=1000), db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await product_service.product_movements(db, product_id, from_date, to_date, page, page_size)


@router.delete("/subcategories/{sub_id}", status_code=204)
async def delete_subcategory(sub_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    await product_service.delete_subcategory(db, sub_id)


@router.post("/products/{product_id}/move")
async def move_product(product_id: uuid.UUID, data: MoveProduct, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    return await product_service.move_product(db, product_id, data, current_user)


# ── Product Image ────────────────────────────────────────────────────────────
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"}
MAX_UPLOAD_SIZE = 5 * 1024 * 1024


@router.post("/products/{product_id}/image")
async def upload_product_image(product_id: uuid.UUID, file: UploadFile = File(...), db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP")
    contents = await file.read()
    if len(contents) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 5 ميجابايت")
    image_url = await product_service.upload_product_image(db, product_id, contents, file.filename or "img.png", file.content_type)
    return {"image_url": image_url}


# ── Product Barcodes ────────────────────────────────────────────────────────
@router.post("/products/{product_id}/barcodes", response_model=ProductBarcodeOut)
async def add_barcode(
    product_id: uuid.UUID,
    data: ProductBarcodeCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("inventory"))
):
    return await product_service.add_barcode(db, product_id, data, current_user)


@router.put("/barcodes/{barcode_id}", response_model=ProductBarcodeOut)
async def update_barcode(
    barcode_id: uuid.UUID,
    data: ProductBarcodeCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("inventory"))
):
    return await product_service.update_barcode(db, barcode_id, data, current_user)


@router.delete("/barcodes/{barcode_id}", status_code=204)
async def delete_barcode(
    barcode_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("inventory"))
):
    await product_service.delete_barcode(db, barcode_id, current_user)