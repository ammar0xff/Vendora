from fastapi import APIRouter, Depends, Query, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_db
from app.schemas.product import CategoryCreate, CategoryOut, SubcategoryCreate, SubcategoryOut, ProductCreate, ProductUpdate, ProductOut, ProductWithStock
from app.models.product import Category, Subcategory, Product
from app.services.stock_service import get_balance
from app.dependencies import get_current_user, require_role
from app.core.config import settings
import uuid, os
from app.core.exceptions import NotFoundError
import uuid

router = APIRouter(tags=["products"])


# ── Categories ──────────────────────────────────────────────────────────────
@router.get("/categories", response_model=list[CategoryOut])
async def list_categories(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return (await db.execute(select(Category))).scalars().all()


@router.post("/categories", response_model=CategoryOut)
async def create_category(data: CategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    cat = Category(name=data.name)
    db.add(cat)
    await db.commit()
    await db.refresh(cat)
    return cat


@router.put("/categories/{cat_id}", response_model=CategoryOut)
async def update_category(cat_id: uuid.UUID, data: CategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
    cat.name = data.name
    await db.commit()
    await db.refresh(cat)
    return cat


@router.put("/subcategories/{sub_id}", response_model=SubcategoryOut)
async def update_subcategory(sub_id: uuid.UUID, data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
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
async def move_product(product_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    """Move product to a different subcategory."""
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    p.subcategory_id = data["subcategory_id"]
    await db.commit()
    return {"detail": "Moved"}


@router.delete("/categories/{cat_id}", status_code=204)
async def delete_category(cat_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Category).where(Category.id == cat_id))
    cat = result.scalar_one_or_none()
    if not cat:
        raise NotFoundError()
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
async def create_subcategory(data: SubcategoryCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    sub = Subcategory(category_id=data.category_id, name=data.name)
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub


# ── Products ─────────────────────────────────────────────────────────────────
@router.get("/products", response_model=list[ProductOut])
async def list_products(
    search: str | None = None,
    subcategory_id: uuid.UUID | None = None,
    category_id: uuid.UUID | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    q = select(Product).where(Product.is_active == True)
    if search:
        q = q.where(Product.name.ilike(f"%{search}%"))
    if subcategory_id:
        q = q.where(Product.subcategory_id == subcategory_id)
    if category_id:
        q = q.join(Subcategory).where(Subcategory.category_id == category_id)
    return (await db.execute(q)).scalars().all()


@router.post("/products", response_model=ProductOut)
async def create_product(data: ProductCreate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    p = Product(**data.model_dump())
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return p


@router.get("/products/barcode/{barcode}", response_model=ProductOut)
async def get_by_barcode(barcode: str, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(select(Product).where(Product.barcode == barcode))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError("Product not found")
    return p


@router.get("/products/{product_id}", response_model=ProductOut)
async def get_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError("Product not found")
    return p


@router.delete("/products/{product_id}", status_code=204)
async def delete_product(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    p.is_active = False  # soft delete — preserves stock movement history
    await db.commit()


@router.delete("/subcategories/{sub_id}", status_code=204)
async def delete_subcategory(sub_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Subcategory).where(Subcategory.id == sub_id))
    sub = result.scalar_one_or_none()
    if not sub:
        raise NotFoundError()
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
async def update_product(product_id: uuid.UUID, data: ProductUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    for k, v in data.model_dump(exclude_none=True).items():
        setattr(p, k, v)
    await db.commit()
    await db.refresh(p)
    return p


@router.post("/products/{product_id}/image")
async def upload_product_image(product_id: uuid.UUID, file: UploadFile = File(...), db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Product).where(Product.id == product_id))
    p = result.scalar_one_or_none()
    if not p:
        raise NotFoundError()
    upload_dir = os.path.join(settings.UPLOAD_DIR, "products")
    os.makedirs(upload_dir, exist_ok=True)
    ext = os.path.splitext(file.filename or "img.png")[1]
    filename = f"{product_id}{ext}"
    path = os.path.join(upload_dir, filename)
    with open(path, "wb") as f:
        f.write(await file.read())
    p.image_url = f"/uploads/products/{filename}"
    await db.commit()
    return {"image_url": p.image_url}
