from fastapi import APIRouter, Depends, Query, UploadFile, File, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.db.base import get_db
from app.core.pagination import Page
from app.schemas.product import (
    CategoryCreate, CategoryOut, SubcategoryCreate, SubcategoryOut, 
    ProductCreate, ProductUpdate, ProductOut,
    ProductBarcodeCreate, ProductBarcodeOut, ProductWithBarcodes
)
from app.models.product import Category, Subcategory, Product, ProductBarcode
from app.models.user import User
from app.dependencies import get_current_user, require_perm
from app.core.config import settings
import uuid
import os
import re
from app.core.exceptions import NotFoundError, BusinessError
from app.services.audit_service import log as audit_log

router = APIRouter(tags=["products"])


# ── Categories ──────────────────────────────────────────────────────────────
@router.get("/categories", response_model=list[CategoryOut])
async def list_categories(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return (await db.execute(select(Category))).scalars().all()


@router.post("/categories", response_model=CategoryOut)
async def create_category(data: CategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    cat = Category(name=data.name)
    db.add(cat)
    await db.commit()
    await db.refresh(cat)
    return cat


@router.put("/categories/{cat_id}", response_model=CategoryOut)
async def update_category(cat_id: uuid.UUID, data: CategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
    cat.name = data.name
    await db.commit()
    await db.refresh(cat)
    return cat


@router.put("/subcategories/{sub_id}", response_model=SubcategoryOut)
async def update_subcategory(sub_id: uuid.UUID, data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    result = await db.execute(select(Subcategory).where(Subcategory.id == sub_id))
    sub = result.scalar_one_or_none()
    if not sub:
        raise NotFoundError()
    sub.name = data.name
    sub.category_id = data.category_id
    await db.commit()
    await db.refresh(sub)
    return sub


@router.post("/products/{product_id}/move")
async def move_product(product_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    """Move product to a different subcategory."""
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()

    new_subcategory_id = data.get("subcategory_id")
    if not new_subcategory_id:
        raise BusinessError("معرف التصنيف الفرعي الجديد مطلوب")
    
    # Validate new subcategory exists
    sub_result = await db.execute(select(Subcategory).where(Subcategory.id == new_subcategory_id))
    if not sub_result.scalar_one_or_none():
        raise NotFoundError("التصنيف الفرعي الجديد غير موجود")

    old_subcat = str(p.subcategory_id)
    p.subcategory_id = new_subcategory_id
    await audit_log(db, "product", "move", current_user.id, current_user.full_name, product_id, {"from_subcategory": old_subcat, "to_subcategory": str(p.subcategory_id)}, "نقل منتج بين الفئات")
    await db.commit()
    return {"detail": "Moved"}


@router.delete("/categories/{cat_id}", status_code=204)
async def delete_category(cat_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    from app.core.exceptions import BusinessError
    from sqlalchemy import text as sqlt
    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
    count = await db.scalar(sqlt(
        "SELECT COUNT(*) FROM products p JOIN subcategories s ON s.id = p.subcategory_id WHERE s.category_id = :id AND p.is_active = true"
    ), {"id": cat_id})
    if count and count > 0:
        raise BusinessError(f"لا يمكن حذف التصنيف — يوجد {count} منتج مرتبط به")
    await db.delete(cat)
    await db.commit()


# ── Subcategories ────────────────────────────────────────────────────────────
@router.get("/subcategories", response_model=list[SubcategoryOut])
async def list_subcategories(category_id: uuid.UUID | None = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = select(Subcategory)
    if category_id:
        q = q.where(Subcategory.category_id == category_id)
    return (await db.execute(q)).scalars().all()


@router.post("/subcategories", response_model=SubcategoryOut)
async def create_subcategory(data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    sub = Subcategory(category_id=data.category_id, name=data.name)
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub


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
    _=Depends(get_current_user),
):
    from sqlalchemy import func, text as sqlt
    base_q = select(Product).where(Product.is_active)
    count_q = select(func.count(Product.id)).where(Product.is_active)
    if search:
        like = f"%{search}%"
        base_q = base_q.where(Product.name.ilike(like))
        count_q = count_q.where(Product.name.ilike(like))
    if subcategory_id:
        base_q = base_q.where(Product.subcategory_id == subcategory_id)
        count_q = count_q.where(Product.subcategory_id == subcategory_id)
    if category_id:
        base_q = base_q.join(Subcategory).where(Subcategory.category_id == category_id)
        count_q = count_q.join(Subcategory).where(Subcategory.category_id == category_id)

    total = (await db.execute(count_q)).scalar_one() or 0
    pages = max(1, (total + page_size - 1) // page_size)
    offset = (page - 1) * page_size
    products = (await db.execute(base_q.offset(offset).limit(page_size))).scalars().all()

    items_out: list[ProductOut] = []
    for p in products:
        po = ProductOut.model_validate(p)
        items_out.append(po)

    if warehouse_id:
        rows = (await db.execute(sqlt(
            "SELECT product_id, status FROM warehouse_product_status WHERE warehouse_id = :wid"
        ), {"wid": warehouse_id})).fetchall()
        wh_status = {str(r[0]): r[1] for r in rows}
        for po in items_out:
            po.stock_status = wh_status.get(str(po.id), po.stock_status)

    return Page(items=items_out, total=total, page=page, size=page_size, pages=pages)


@router.post("/products", response_model=ProductOut)
async def create_product(data: ProductCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    p = Product(**data.model_dump())
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return p


@router.get("/products/barcode/{barcode}", response_model=ProductOut)
async def get_by_barcode(barcode: str, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    # First try legacy single-barcode column.
    p = (await db.execute(select(Product).where(Product.barcode == barcode))).scalar_one_or_none()
    if p:
        return p

    # Then try multi-barcode table.
    p = (
        await db.execute(
            select(Product)
            .join(ProductBarcode, ProductBarcode.product_id == Product.id)
            .where(ProductBarcode.barcode == barcode)
        )
    ).scalar_one_or_none()
    if not p:
        raise NotFoundError("Product not found")
    return p


@router.get("/products/{product_id}", response_model=ProductWithBarcodes)
async def get_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(
        select(Product)
        .options(selectinload(Product.barcodes))
        .where(Product.id == product_id)
    )
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError("Product not found")
    return p


@router.delete("/products/{product_id}", status_code=204)
async def delete_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    p.is_active = False  # soft delete — preserves stock movement history
    await db.commit()


@router.delete("/subcategories/{sub_id}", status_code=204)
async def delete_subcategory(sub_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    from app.core.exceptions import BusinessError
    from sqlalchemy import text as sqlt
    result = await db.execute(select(Subcategory).where(Subcategory.id == sub_id))
    sub = result.scalar_one_or_none()
    if not sub:
        raise NotFoundError()
    count = await db.scalar(sqlt("SELECT COUNT(*) FROM products WHERE subcategory_id = :id AND is_active = true"), {"id": sub_id})
    if count and count > 0:
        raise BusinessError(f"لا يمكن حذف التصنيف الفرعي — يوجد {count} منتج نشط مرتبط به")
    await db.delete(sub)
    await db.commit()


@router.get("/products/{product_id}/movements")
async def product_movements(product_id: uuid.UUID, from_date: str | None = None, to_date: str | None = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Per-product movement log — used in product analytics."""
    from app.models.stock import StockMovement
    q = select(StockMovement).where(StockMovement.product_id == product_id).order_by(StockMovement.created_at.desc())
    if from_date:
        from datetime import datetime
        q = q.where(StockMovement.created_at >= datetime.fromisoformat(from_date))
    if to_date:
        from datetime import datetime
        q = q.where(StockMovement.created_at <= datetime.fromisoformat(to_date))
    result = await db.execute(q)
    return result.scalars().all()

@router.put("/products/{product_id}", response_model=ProductOut)
async def update_product(product_id: uuid.UUID, data: ProductUpdate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("inventory"))):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    for k, v in data.model_dump(exclude_none=True).items():
        setattr(p, k, v)
    await audit_log(db, "product", "update", current_user.id, current_user.full_name, product_id, data.model_dump(exclude_none=True), "تعديل المنتج")
    await db.commit()
    await db.refresh(p)
    return p


ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"}
MAX_UPLOAD_SIZE = 5 * 1024 * 1024


@router.post("/products/{product_id}/image")
async def upload_product_image(product_id: uuid.UUID, file: UploadFile = File(...), db: AsyncSession = Depends(get_db), _=Depends(require_perm("inventory"))):
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP")
    contents = await file.read()
    if len(contents) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 5 ميجابايت")
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    upload_dir = os.path.join(settings.UPLOAD_DIR, "products")
    os.makedirs(upload_dir, exist_ok=True)
    safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', file.filename or "img.png")
    ext = os.path.splitext(safe_name)[1]
    filename = f"{product_id}{ext}"
    path = os.path.join(upload_dir, filename)
    with open(path, "wb") as f:
        f.write(contents)
    p.image_url = f"/uploads/products/{filename}"
    await db.commit()
    return {"image_url": p.image_url}


# ── Product Barcodes ────────────────────────────────────────────────────────
@router.post("/products/{product_id}/barcodes", response_model=ProductBarcodeOut)
async def add_barcode(
    product_id: uuid.UUID, 
    data: ProductBarcodeCreate, 
    db: AsyncSession = Depends(get_db), 
    current_user: User = Depends(require_perm("inventory"))
):
    """Add a barcode to a product."""
    # Check product exists
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    
    # Check barcode doesn't already exist (including in products.barcode)
    existing = await db.execute(
        select(ProductBarcode).where(ProductBarcode.barcode == data.barcode)
    )
    if existing.scalar_one_or_none():
        raise BusinessError(f"الرمز الشريطي '{data.barcode}' موجود بالفعل")
    
    # If marking as primary, unmark all other barcodes for this product
    if data.is_primary:
        for other in (
            await db.execute(
                select(ProductBarcode)
                .where(ProductBarcode.product_id == product_id)
                .where(ProductBarcode.is_primary)
            )
        ).scalars().all():
            other.is_primary = False
    
    bc = ProductBarcode(product_id=product_id, barcode=data.barcode, is_primary=data.is_primary)
    db.add(bc)
    await audit_log(db, "product", "barcode_add", current_user.id, current_user.full_name, product_id, {"barcode": data.barcode}, "إضافة رمز شريطي")
    await db.commit()
    await db.refresh(bc)
    return bc


@router.put("/barcodes/{barcode_id}", response_model=ProductBarcodeOut)
async def update_barcode(
    barcode_id: uuid.UUID,
    data: ProductBarcodeCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("inventory"))
):
    """Update a barcode (change barcode string or mark as primary)."""
    result = await db.execute(select(ProductBarcode).where(ProductBarcode.id == barcode_id))
    bc = result.scalar_one_or_none()
    if not bc:
        raise NotFoundError()
    
    # If changing barcode string, check new one doesn't exist
    if data.barcode != bc.barcode:
        existing = await db.execute(
            select(ProductBarcode).where(ProductBarcode.barcode == data.barcode)
        )
        if existing.scalar_one_or_none():
            raise BusinessError(f"الرمز الشريطي '{data.barcode}' موجود بالفعل")
    
    # If marking as primary, unmark all other barcodes for this product
    if data.is_primary and not bc.is_primary:
        for other_bc in (await db.execute(
            select(ProductBarcode)
            .where(ProductBarcode.product_id == bc.product_id)
            .where(ProductBarcode.is_primary)
        )).scalars().all():
            other_bc.is_primary = False
    
    old_barcode = bc.barcode
    bc.barcode = data.barcode
    bc.is_primary = data.is_primary
    await audit_log(db, "product", "barcode_update", current_user.id, current_user.full_name, bc.product_id, {"from": old_barcode, "to": data.barcode}, "تعديل رمز شريطي")
    await db.commit()
    await db.refresh(bc)
    return bc


@router.delete("/barcodes/{barcode_id}", status_code=204)
async def delete_barcode(
    barcode_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("inventory"))
):
    """Delete a barcode."""
    result = await db.execute(select(ProductBarcode).where(ProductBarcode.id == barcode_id))
    bc = result.scalar_one_or_none()
    if not bc:
        raise NotFoundError()
    
    product_id = bc.product_id
    barcode_str = bc.barcode
    await db.delete(bc)
    await audit_log(db, "product", "barcode_delete", current_user.id, current_user.full_name, product_id, {"barcode": barcode_str}, "حذف رمز شريطي")
    await db.commit()
