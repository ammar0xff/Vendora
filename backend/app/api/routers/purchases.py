import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import get_db
from app.dependencies import get_current_user, require_open_period, require_perm
from app.models.user import User
from app.schemas.purchase import PurchaseCreate, PurchaseReceive, PurchaseUpdate, QuickProductCreate
from app.schemas.supplier_price import (
    SupplierPriceComparison,
    SupplierPriceCreate,
    SupplierPriceOut,
    SupplierPriceUpdate,
)
from app.services import purchase_service

router = APIRouter(prefix="/purchases", tags=["purchases"])


@router.get("/suggestions")
async def purchase_suggestions(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Products where total stock across all warehouses <= reorder_point."""
    return await purchase_service.get_purchase_suggestions(db)


@router.get("")
async def list_purchases(page: int = 1, page_size: int = 50, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await purchase_service.list_purchases(db, page, page_size)


@router.get("/{po_id}")
async def get_purchase(po_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await purchase_service.get_purchase(db, po_id)


@router.post("")
async def create_purchase(data: PurchaseCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory")), _=Depends(require_open_period)):
    return await purchase_service.create_purchase(db, data, current_user)


@router.put("/{po_id}")
async def update_purchase(po_id: uuid.UUID, data: PurchaseUpdate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Update draft PO items/supplier before receiving."""
    return await purchase_service.update_purchase(db, po_id, data, current_user)


@router.post("/{po_id}/receive")
async def receive_purchase(po_id: uuid.UUID, data: PurchaseReceive = None, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Receive PO. Optionally pass overridden items with actual received qty/cost."""
    return await purchase_service.receive_purchase(db, po_id, data or PurchaseReceive(), current_user)


@router.get("/price-history/{product_id}")
async def price_history(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    return await purchase_service.get_price_history(db, product_id)


ALLOWED_UPLOAD_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp", "application/pdf"}
MAX_UPLOAD_SIZE = 10 * 1024 * 1024


@router.post("/{po_id}/upload-invoice")
async def upload_invoice_image(po_id: uuid.UUID, file: UploadFile = File(...),
                                db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    if file.content_type not in ALLOWED_UPLOAD_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP, PDF")
    contents = await file.read()
    if len(contents) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 10 ميجابايت")
    image_url = await purchase_service.upload_invoice_image(db, po_id, contents, file.filename or "invoice.jpg", file.content_type)
    return {"invoice_image_url": image_url}


@router.post("/quick-add-product")
async def quick_add_product(data: QuickProductCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Create a new product inline during purchase entry."""
    return await purchase_service.quick_add_product(db, data, current_user)


# ── Supplier Prices ────────────────────────────────────────────────────────
@router.get("/supplier-prices/product/{product_id}", response_model=SupplierPriceComparison)
async def get_product_supplier_prices(product_id: str, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Get all supplier prices for a product with comparison."""
    return await purchase_service.get_product_supplier_prices(db, product_id)


@router.post("/supplier-prices", response_model=SupplierPriceOut)
async def create_supplier_price(
    data: SupplierPriceCreate,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(require_perm("operations"))
):
    """Create or update supplier price."""
    return await purchase_service.create_supplier_price(db, data, current_user)


@router.put("/supplier-prices/{price_id}", response_model=SupplierPriceOut)
async def update_supplier_price(
    price_id: str,
    data: SupplierPriceUpdate,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_perm("operations"))
):
    """Update supplier price."""
    return await purchase_service.update_supplier_price(db, price_id, data)


@router.delete("/supplier-prices/{price_id}", status_code=204)
async def delete_supplier_price(
    price_id: str,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_perm("operations"))
):
    """Soft-delete supplier price."""
    await purchase_service.delete_supplier_price(db, price_id)
