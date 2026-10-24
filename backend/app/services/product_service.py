"""Product service — business logic for products, categories, subcategories, barcodes."""
import os
import re
import uuid
from datetime import datetime
from decimal import Decimal
from typing import Any

from fastapi import HTTPException
from sqlalchemy import func, or_, select, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.core.exceptions import BusinessError, NotFoundError
from app.core.pagination import Page
from app.models.product import Category, Product, ProductBarcode, Subcategory
from app.models.stock import IN_TYPES, StockMovement
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
from app.services.audit_service import log as audit_log

# ── Categories ──────────────────────────────────────────────────────────────

async def list_categories(db: AsyncSession) -> list[CategoryOut]:
    return (await db.execute(
        select(Category).order_by(func.nullif(Category.code, '').asc().nullslast(), Category.name)
    )).scalars().all()


async def create_category(db: AsyncSession, data: CategoryCreate, current_user_id: uuid.UUID) -> CategoryOut:
    cat = Category(name=data.name, code=data.code or None)
    db.add(cat)
    await db.commit()
    await db.refresh(cat)
    return cat


async def update_category(db: AsyncSession, cat_id: uuid.UUID, data: CategoryCreate, current_user_id: uuid.UUID) -> CategoryOut:
    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
    cat.name = data.name
    cat.code = data.code or None
    await db.commit()
    await db.refresh(cat)
    return cat


async def delete_category(db: AsyncSession, cat_id: uuid.UUID) -> None:
    from sqlalchemy import text as sqlt

    from app.core.exceptions import BusinessError

    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
    count = await db.scalar(sqlt(
        "SELECT COUNT(*) FROM products p JOIN subcategories s ON s.id = p.subcategory_id WHERE s.category_id = :id AND p.is_active = true"
    ), {"id": cat_id})
    if count and count > 0:
        raise BusinessError(f"لا يمكن حذف التصنيف — يوجد {count} منتج نشط مرتبط به")
    # Detach soft-deleted (inactive) products so FK RESTRICT doesn't block deletion
    await db.execute(sqlt(
        "UPDATE products SET subcategory_id = NULL FROM subcategories s WHERE s.category_id = :id AND products.subcategory_id = s.id AND products.is_active = false"
    ), {"id": cat_id})
    await db.delete(cat)
    await db.commit()


# ── Subcategories ────────────────────────────────────────────────────────────

async def list_subcategories(db: AsyncSession, category_id: uuid.UUID | None = None) -> list[SubcategoryOut]:
    q = select(Subcategory)
    if category_id:
        q = q.where(Subcategory.category_id == category_id)
    q = q.order_by(func.nullif(Subcategory.code, '').asc().nullslast(), Subcategory.name)
    return (await db.execute(q)).scalars().all()


async def create_subcategory(db: AsyncSession, data: SubcategoryCreate) -> SubcategoryOut:
    sub = Subcategory(category_id=data.category_id, name=data.name, code=data.code or None)
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub


async def update_subcategory(db: AsyncSession, sub_id: uuid.UUID, data: SubcategoryCreate) -> SubcategoryOut:
    result = await db.execute(select(Subcategory).where(Subcategory.id == sub_id))
    sub = result.scalar_one_or_none()
    if not sub:
        raise NotFoundError()
    sub.name = data.name
    sub.category_id = data.category_id
    sub.code = data.code or None
    await db.commit()
    await db.refresh(sub)
    return sub


async def delete_subcategory(db: AsyncSession, sub_id: uuid.UUID) -> None:
    from sqlalchemy import text as sqlt

    from app.core.exceptions import BusinessError

    result = await db.execute(select(Subcategory).where(Subcategory.id == sub_id))
    sub = result.scalar_one_or_none()
    if not sub:
        raise NotFoundError()
    count = await db.scalar(sqlt("SELECT COUNT(*) FROM products WHERE subcategory_id = :id AND is_active = true"), {"id": sub_id})
    if count and count > 0:
        raise BusinessError(f"لا يمكن حذف التصنيف الفرعي — يوجد {count} منتج نشط مرتبط به")
    # Detach soft-deleted (inactive) products so FK RESTRICT doesn't block deletion
    await db.execute(sqlt("UPDATE products SET subcategory_id = NULL WHERE subcategory_id = :id AND is_active = false"), {"id": sub_id})
    await db.delete(sub)
    await db.commit()


# ── Products ─────────────────────────────────────────────────────────────────

async def list_products(
    db: AsyncSession,
    search: str | None = None,
    subcategory_id: uuid.UUID | None = None,
    category_id: uuid.UUID | None = None,
    warehouse_id: uuid.UUID | None = None,
    page: int = 1,
    page_size: int = 5000,
    current_user: User | None = None,
) -> Page:
    from sqlalchemy import case as sa_case

    from app.dependencies import verify_warehouse_access
    if current_user:
        await verify_warehouse_access(db, current_user, warehouse_id)
    base_q = select(Product).where(Product.is_active)
    count_q = select(func.count(Product.id)).where(Product.is_active)

    if search:
        like = f"%{search}%"
        base_q = base_q.where(or_(Product.name.ilike(like), Product.code.ilike(like)))
        count_q = count_q.where(or_(Product.name.ilike(like), Product.code.ilike(like)))
    if subcategory_id:
        base_q = base_q.where(Product.subcategory_id == subcategory_id)
        count_q = count_q.where(Product.subcategory_id == subcategory_id)
    if category_id:
        base_q = base_q.join(Subcategory).where(Subcategory.category_id == category_id)
        count_q = count_q.join(Subcategory).where(Subcategory.category_id == category_id)

    base_q = base_q.order_by(func.nullif(Product.code, '').asc().nullslast(), Product.name)

    total = (await db.execute(count_q)).scalar_one() or 0
    pages = max(1, (total + page_size - 1) // page_size)
    offset = (page - 1) * page_size
    products = (await db.execute(base_q.offset(offset).limit(page_size))).scalars().all()

    from app.schemas.product import ProductOutWithBalance

    items_out: list[ProductOutWithBalance] = []
    for p in products:
        items_out.append(ProductOutWithBalance.model_validate(p))

    product_ids = [p.id for p in products]
    if product_ids:
        # Compute current balance per product (warehouse-scoped or company-wide)
        bal_q = select(
            StockMovement.product_id,
            func.coalesce(
                func.sum(sa_case(
                    (StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty),
                    else_=-StockMovement.qty,
                )), 0
            ).label("qty"),
        ).where(StockMovement.product_id.in_(product_ids))
        if warehouse_id:
            bal_q = bal_q.where(StockMovement.warehouse_id == warehouse_id)
        bal_q = bal_q.group_by(StockMovement.product_id)
        bal_rows = (await db.execute(bal_q)).all()
        bal_map = {str(r[0]): float(r[1]) for r in bal_rows}

        # Per-warehouse tracking status (only applies in warehouse scope)
        wh_status: dict[str, str] = {}
        if warehouse_id:
            wh_rows = (await db.execute(text(
                "SELECT product_id, status FROM warehouse_product_status WHERE warehouse_id = :wid"
            ), {"wid": warehouse_id})).fetchall()
            wh_status = {str(r[0]): str(r[1]) for r in wh_rows}

        for po in items_out:
            po.current_qty = Decimal(str(bal_map.get(str(po.id), 0)))
            if warehouse_id:
                po.stock_status = wh_status.get(str(po.id), 'untracked')

    return Page(items=items_out, total=total, page=page, size=page_size, pages=pages)


async def create_product(db: AsyncSession, data: ProductCreate, current_user_id: uuid.UUID) -> ProductOut:
    payload = data.model_dump()
    if not payload.get("code"):
        payload["code"] = None
    p = Product(**payload)
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return p


async def get_product_by_barcode(db: AsyncSession, barcode: str) -> ProductOut:
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


async def get_product(db: AsyncSession, product_id: uuid.UUID) -> ProductWithBarcodes:
    result = await db.execute(
        select(Product)
        .options(selectinload(Product.barcodes))
        .where(Product.id == product_id)
    )
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError("Product not found")
    return p


async def update_product(
    db: AsyncSession,
    product_id: uuid.UUID,
    data: ProductUpdate,
    current_user: User,
) -> ProductOut:
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    payload = data.model_dump(exclude_none=True)
    if "code" in payload and not payload["code"]:
        payload["code"] = None
    for k, v in payload.items():
        setattr(p, k, v)
    await audit_log(db, "product", "update", current_user.id, current_user.full_name, product_id, data.model_dump(mode="json", exclude_none=True), "تعديل المنتج")
    await db.commit()
    await db.refresh(p)
    return p


async def delete_product(db: AsyncSession, product_id: uuid.UUID) -> None:
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    p.is_active = False  # soft delete — preserves stock movement history
    await db.commit()


# ── Product Movements ────────────────────────────────────────────────────────

async def product_movements(
    db: AsyncSession,
    product_id: uuid.UUID,
    from_date: str | None = None,
    to_date: str | None = None,
    page: int = 1,
    page_size: int = 100,
) -> dict[str, Any]:
    """Per-product movement log — used in product analytics."""
    from math import ceil

    conditions = ["sm.product_id = :product_id"]
    params: dict = {"product_id": product_id}
    if from_date:
        try:
            params["from_date"] = datetime.fromisoformat(from_date)
            conditions.append("sm.created_at >= :from_date")
        except ValueError:
            raise HTTPException(400, f"Invalid from_date format: {from_date}") from None
    if to_date:
        try:
            params["to_date"] = datetime.fromisoformat(to_date)
            conditions.append("sm.created_at <= :to_date")
        except ValueError:
            raise HTTPException(400, f"Invalid to_date format: {to_date}") from None
    where_sql = " AND ".join(conditions)
    total = (await db.execute(text(f"SELECT COUNT(*) FROM stock_movements sm WHERE {where_sql}"), params)).scalar() or 0
    pages = max(1, ceil(total / page_size))
    params["limit"] = page_size
    params["offset"] = (page - 1) * page_size
    rows = await db.execute(text(f"""
        SELECT sm.*, p.name as product_name, w.name as warehouse_name,
               u.full_name as created_by_name
        FROM stock_movements sm
        LEFT JOIN products p ON p.id = sm.product_id
        LEFT JOIN warehouses w ON w.id = sm.warehouse_id
        LEFT JOIN users u ON u.id = sm.created_by
        WHERE {where_sql}
        ORDER BY sm.created_at DESC LIMIT :limit OFFSET :offset
    """), params)
    items = [dict(r._mapping) for r in rows.fetchall()]
    return {"items": items, "total": total, "page": page, "size": page_size, "pages": pages}


# ── Product Barcodes ─────────────────────────────────────────────────────────

async def add_barcode(
    db: AsyncSession,
    product_id: uuid.UUID,
    data: ProductBarcodeCreate,
    current_user: User,
) -> ProductBarcodeOut:
    """Add a barcode to a product."""
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


async def update_barcode(
    db: AsyncSession,
    barcode_id: uuid.UUID,
    data: ProductBarcodeCreate,
    current_user: User,
) -> ProductBarcodeOut:
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


async def delete_barcode(
    db: AsyncSession,
    barcode_id: uuid.UUID,
    current_user: User,
) -> None:
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


# ── Move Product ─────────────────────────────────────────────────────────────

async def move_product(
    db: AsyncSession,
    product_id: uuid.UUID,
    data: MoveProduct,
    current_user: User,
) -> dict[str, str]:
    """Move product to a different subcategory."""
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()

    new_subcategory_id = data.subcategory_id

    # Validate new subcategory exists
    sub_result = await db.execute(select(Subcategory).where(Subcategory.id == new_subcategory_id))
    if not sub_result.scalar_one_or_none():
        raise NotFoundError("التصنيف الفرعي الجديد غير موجود")

    old_subcat = str(p.subcategory_id)
    p.subcategory_id = new_subcategory_id
    await audit_log(db, "product", "move", current_user.id, current_user.full_name, product_id, {"from_subcategory": old_subcat, "to_subcategory": str(p.subcategory_id)}, "نقل منتج بين الفئات")
    await db.commit()
    return {"detail": "Moved"}


# ── Product Image ────────────────────────────────────────────────────────────

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"}
MAX_UPLOAD_SIZE = 5 * 1024 * 1024


async def upload_product_image(
    db: AsyncSession,
    product_id: uuid.UUID,
    file_content: bytes,
    filename: str,
    content_type: str,
) -> str:
    if content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP")
    if len(file_content) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 5 ميجابايت")

    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()

    upload_dir = os.path.join(settings.UPLOAD_DIR, "products")
    os.makedirs(upload_dir, exist_ok=True)
    safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', filename or "img.png")
    ext = os.path.splitext(safe_name)[1]
    filename = f"{product_id}{ext}"
    path = os.path.join(upload_dir, filename)
    with open(path, "wb") as f:
        f.write(file_content)
    p.image_url = f"/uploads/products/{filename}"
    await db.commit()
    return p.image_url
