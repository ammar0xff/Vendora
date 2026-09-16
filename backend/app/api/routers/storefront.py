"""Public, read-only storefront endpoints.

Guests (no session) can browse the live catalog through /store/* so the
customer-facing storefront can render real data without exposing auth-gated
router internals. All responses are a safe subset: active products only, no
barcodes, no stock/warehouse internals.
"""

import uuid

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy import func, or_, select, text as sqlt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.pagination import Page
from app.db.base import get_db
from app.models.product import Category, Product, ProductImage, Subcategory

router = APIRouter(prefix="/store", tags=["storefront"])


class StoreProductOut(BaseModel):
    id: uuid.UUID
    name: str
    code: str | None
    unit: str
    retail_price: float
    wholesale_price: float
    company: str | None
    size: str | None
    image_url: str | None
    description: str | None = None
    images: list[str] = []
    subcategory_id: uuid.UUID | None
    category_id: uuid.UUID | None
    category_name: str | None
    model_config = {"from_attributes": True}


class StoreCategoryOut(BaseModel):
    id: uuid.UUID
    name: str
    code: str | None
    image_url: str | None = None
    product_count: int = 0
    model_config = {"from_attributes": True}


def _to_store_out(p: Product) -> StoreProductOut:
    return StoreProductOut(
        id=p.id,
        name=p.name,
        code=p.code,
        unit=p.unit,
        retail_price=float(p.retail_price),
        wholesale_price=float(p.wholesale_price),
        company=p.company,
        size=p.size,
        image_url=p.image_url,
        description=p.description,
        images=[img.image_url for img in p.images],
        subcategory_id=p.subcategory_id,
        category_id=p.subcategory.category_id if p.subcategory else None,
        category_name=p.subcategory.category.name if p.subcategory and p.subcategory.category else None,
    )


@router.get("/products", response_model=Page[StoreProductOut])
async def store_products(
    search: str | None = None,
    category_id: uuid.UUID | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(24, ge=1, le=60),
    db: AsyncSession = Depends(get_db),
):
    base = select(Product).where(Product.is_active)
    countq = select(func.count(Product.id)).where(Product.is_active)

    if search:
        like = f"%{search}%"
        base = base.where(or_(Product.name.ilike(like), Product.code.ilike(like)))
        countq = countq.where(or_(Product.name.ilike(like), Product.code.ilike(like)))
    if category_id:
        base = base.join(Subcategory).where(Subcategory.category_id == category_id)
        countq = countq.join(Subcategory).where(Subcategory.category_id == category_id)

    base = base.options(
        selectinload(Product.subcategory).selectinload(Subcategory.category),
        selectinload(Product.images),
    ).order_by(func.nullif(Product.code, "").asc().nullslast(), Product.name)

    total = (await db.execute(countq)).scalar_one() or 0
    pages = max(1, (total + page_size - 1) // page_size)
    offset = (page - 1) * page_size
    rows = (await db.execute(base.offset(offset).limit(page_size))).scalars().all()
    return Page(items=[_to_store_out(p) for p in rows], total=total, page=page, size=page_size, pages=pages)


@router.get("/products/{product_id}", response_model=StoreProductOut)
async def store_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    row = (
        await db.execute(
            select(Product)
            .options(
                selectinload(Product.subcategory).selectinload(Subcategory.category),
                selectinload(Product.images),
            )
            .where(Product.id == product_id, Product.is_active)
        )
    ).scalar_one_or_none()
    if not row:
        raise HTTPException(404, "المنتج غير موجود")
    return _to_store_out(row)


@router.get("/categories", response_model=list[StoreCategoryOut])
async def store_categories(db: AsyncSession = Depends(get_db)):
    counts = dict(
        (await db.execute(
            sqlt(
                """SELECT c.id, COUNT(p.id)
                   FROM categories c
                   JOIN subcategories s ON s.category_id = c.id
                   JOIN products p ON p.subcategory_id = s.id AND p.is_active = true
                   GROUP BY c.id"""
            )
        )).all()
    )
    cats = (await db.execute(
        select(Category).order_by(func.nullif(Category.code, "").asc().nullslast(), Category.name)
    )).scalars().all()
    return [
        StoreCategoryOut(id=c.id, name=c.name, code=c.code, image_url=c.image_url, product_count=int(counts.get(c.id, 0)))
        for c in cats
    ]