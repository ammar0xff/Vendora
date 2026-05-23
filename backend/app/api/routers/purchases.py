from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text, or_
from datetime import datetime, timezone
from app.db.base import get_db
from app.models.purchase import PurchaseOrder, PurchaseOrderItem, POStatus
from app.models.supplier_price import SupplierPrice
from app.models.product import Product
from app.models.stock import MovementType
from app.schemas.stock import StockMovementCreate
from app.schemas.purchase import PurchaseCreate, PurchaseUpdate, PurchaseReceive, QuickProductCreate
from app.schemas.supplier_price import (
    SupplierPriceCreate, SupplierPriceUpdate, SupplierPriceOut, 
    SupplierPriceComparison
)
from app.services.stock_service import record_movement
from app.dependencies import get_current_user, require_perm, require_open_period
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
import uuid
import re

router = APIRouter(prefix="/purchases", tags=["purchases"])


@router.get("/suggestions")
async def purchase_suggestions(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Products where total stock across all warehouses <= reorder_point."""
    rows = await db.execute(text("""
        SELECT
            p.id, p.name, p.barcode as sku, p.cost_price, p.reorder_point, p.reorder_qty,
            COALESCE(SUM(CASE WHEN sm.movement_type IN ('purchase','transfer_in','adjustment_in','return_in','opening_stock')
                              THEN sm.qty ELSE 0 END)
                   - SUM(CASE WHEN sm.movement_type IN ('sale','transfer_out','adjustment_out','damage')
                              THEN sm.qty ELSE 0 END), 0) AS total_stock,
            p.unit
        FROM products p
        LEFT JOIN stock_movements sm ON sm.product_id = p.id
        WHERE p.is_active = true AND p.reorder_point > 0
        GROUP BY p.id
        HAVING COALESCE(SUM(CASE WHEN sm.movement_type IN ('purchase','transfer_in','adjustment_in','return_in','opening_stock')
                                  THEN sm.qty ELSE 0 END)
                       - SUM(CASE WHEN sm.movement_type IN ('sale','transfer_out','adjustment_out','damage')
                                  THEN sm.qty ELSE 0 END), 0) <= p.reorder_point
        ORDER BY total_stock ASC
    """))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.get("")
async def list_purchases(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("""
        SELECT po.*, s.name as supplier_name, w.name as warehouse_name,
               u.full_name as created_by_name
        FROM purchase_orders po
        LEFT JOIN suppliers s ON s.id = po.supplier_id
        LEFT JOIN warehouses w ON w.id = po.warehouse_id
        LEFT JOIN users u ON u.id = po.created_by
        ORDER BY po.created_at DESC LIMIT 100
    """))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.get("/{po_id}")
async def get_purchase(po_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    po_row = await db.execute(text("""
        SELECT po.*, s.name as supplier_name, w.name as warehouse_name
        FROM purchase_orders po
        LEFT JOIN suppliers s ON s.id = po.supplier_id
        LEFT JOIN warehouses w ON w.id = po.warehouse_id
        WHERE po.id = :id
    """), {"id": po_id})
    po = po_row.fetchone()
    if not po:
        raise NotFoundError()
    items_row = await db.execute(text("""
        SELECT poi.*, p.name as product_name, p.barcode as sku, p.cost_price as current_cost
        FROM purchase_order_items poi
        JOIN products p ON p.id = poi.product_id
        WHERE poi.po_id = :po_id
    """), {"po_id": po_id})
    return {**dict(po._mapping), "items": [dict(r._mapping) for r in items_row.fetchall()]}


@router.post("")
async def create_purchase(data: PurchaseCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory")), _=Depends(require_open_period)):
    from sqlalchemy import text as _text
    seq = (await db.execute(_text("SELECT nextval('purchase_seq')"))).scalar()
    po_number = f"PO-{seq:06d}"
    po = PurchaseOrder(
        po_number=po_number,
        supplier_id=data.supplier_id,
        warehouse_id=data.warehouse_id,
        created_by=current_user.id,
        notes=data.notes,
    )
    db.add(po)
    await db.flush()
    if data.amount_paid or data.received_by_name:
        await db.execute(_text("UPDATE purchase_orders SET amount_paid=:ap, received_by_name=:rbn WHERE id=:id"),
                         {"ap": data.amount_paid or 0, "rbn": data.received_by_name or "", "id": po.id})
    for item in data.items:
        db.add(PurchaseOrderItem(
            po_id=po.id,
            product_id=item.product_id,
            qty_ordered=item.qty,
            unit_cost=item.unit_cost,
            notes=item.notes,
        ))
    await db.commit()
    await db.refresh(po)
    return {"id": str(po.id), "po_number": po.po_number, "status": po.status}


@router.put("/{po_id}")
async def update_purchase(po_id: uuid.UUID, data: PurchaseUpdate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Update draft PO items/supplier before receiving."""
    result = await db.execute(select(PurchaseOrder).where(PurchaseOrder.id == po_id))
    po = result.scalar_one_or_none()
    if not po:
        raise NotFoundError()
    if po.status != POStatus.draft:
        raise BusinessError("Can only edit draft POs")

    if data.supplier_id is not None:
        po.supplier_id = data.supplier_id
    if data.notes is not None:
        po.notes = data.notes

    if data.items is not None:
        await db.execute(text("DELETE FROM purchase_order_items WHERE po_id=:id"), {"id": po_id})
        for item in data.items:
            db.add(PurchaseOrderItem(
                po_id=po.id,
                product_id=item.product_id,
                qty_ordered=item.qty,
                unit_cost=item.unit_cost,
                notes=item.notes,
            ))
    await db.commit()
    return {"ok": True}


@router.post("/{po_id}/receive")
async def receive_purchase(po_id: uuid.UUID, data: PurchaseReceive = PurchaseReceive(), db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Receive PO. Optionally pass overridden items with actual received qty/cost."""
    result = await db.execute(select(PurchaseOrder).where(PurchaseOrder.id == po_id))
    po = result.scalar_one_or_none()
    if not po:
        raise NotFoundError()
    if po.status == POStatus.received:
        raise BusinessError("Already received")

    items = (await db.execute(select(PurchaseOrderItem).where(PurchaseOrderItem.po_id == po_id))).scalars().all()

    overrides = {str(i.product_id): {'qty_received': i.qty_received, 'unit_cost': i.unit_cost} for i in data.items}

    for item in items:
        override = overrides.get(str(item.product_id), {})
        qty = float(override.get("qty_received", item.qty_ordered))
        cost = float(override.get("unit_cost", item.unit_cost))

        # Record stock movement
        mv = StockMovementCreate(
            product_id=item.product_id,
            warehouse_id=po.warehouse_id,
            movement_type=MovementType.purchase,
            qty=qty,
            unit_cost=cost,
        )
        await record_movement(db, mv, current_user.id, ref_id=po.id, ref_type="purchase")
        item.qty_received = qty
        item.unit_cost = cost

        # Update product cost_price + record history
        old_cost_row = await db.execute(text("SELECT cost_price FROM products WHERE id=:id"), {"id": item.product_id})
        old_cost = old_cost_row.scalar()
        await db.execute(text("UPDATE products SET cost_price=:cost WHERE id=:id"), {"cost": cost, "id": item.product_id})
        await db.execute(text("""
            INSERT INTO purchase_price_history (product_id, po_id, supplier_id, old_cost, new_cost)
            VALUES (:pid, :po_id, :sid, :old, :new)
        """), {"pid": item.product_id, "po_id": po_id, "sid": po.supplier_id, "old": old_cost, "new": cost})

    po.status = POStatus.received
    po.received_at = datetime.now(timezone.utc)

    # Auto-update supplier balance
    if po.supplier_id:
        total_cost = sum(
            float(overrides.get(str(item.product_id), {}).get("unit_cost", item.unit_cost)) *
            float(overrides.get(str(item.product_id), {}).get("qty_received", item.qty_ordered))
            for item in items
        )
        amount_paid = float(po.amount_paid or 0)
        remaining = total_cost - amount_paid

        # Record full invoice as debit (we owe them)
        await db.execute(text(
            "INSERT INTO supplier_transactions (supplier_id, amount, type, reference_doc, notes) VALUES (:sid, :amt, 'debit', :ref, 'فاتورة مشتريات')"
        ), {"sid": po.supplier_id, "amt": total_cost, "ref": po.po_number})

        # Record payment as credit if any paid
        if amount_paid > 0:
            await db.execute(text(
                "INSERT INTO supplier_transactions (supplier_id, amount, type, reference_doc, notes) VALUES (:sid, :amt, 'credit', :ref, 'دفعة عند الاستلام')"
            ), {"sid": po.supplier_id, "amt": amount_paid, "ref": po.po_number})

        # Update balance = debit - credit (remaining owed)
        await db.execute(text(
            "UPDATE suppliers SET balance = balance + :remaining WHERE id = :sid"
        ), {"remaining": remaining, "sid": po.supplier_id})

    # Archive the purchase invoice
    from app.models.archive import ArchivedDocument
    supplier_name = (await db.execute(text("SELECT name FROM suppliers WHERE id=:id"), {"id": po.supplier_id})).scalar() if po.supplier_id else None
    total_received = sum(
        float(overrides.get(str(item.product_id), {}).get("unit_cost", item.unit_cost)) *
        float(overrides.get(str(item.product_id), {}).get("qty_received", item.qty_ordered))
        for item in items
    )
    db.add(ArchivedDocument(
        doc_number=po.po_number,
        doc_type="purchase_invoice",
        amount=total_received,
        ref_id=po.id,
        created_by=current_user.id,
        metadata_={
            "supplier": supplier_name or "",
            "warehouse_id": str(po.warehouse_id),
            "items_count": len(items),
            "received_by": getattr(po, "received_by_name", "") or "",
            "amount_paid": float(po.amount_paid or 0),
            "remaining": round(total_received - float(po.amount_paid or 0), 2),
        }
    ))

    await db.commit()
    return {"detail": "Received", "po_number": po.po_number}


@router.get("/price-history/{product_id}")
async def price_history(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("""
        SELECT pph.*, s.name as supplier_name, po.po_number
        FROM purchase_price_history pph
        LEFT JOIN suppliers s ON s.id = pph.supplier_id
        LEFT JOIN purchase_orders po ON po.id = pph.po_id
        WHERE pph.product_id = :pid
        ORDER BY pph.created_at DESC LIMIT 50
    """), {"pid": product_id})
    return [dict(r._mapping) for r in rows.fetchall()]


ALLOWED_UPLOAD_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp", "application/pdf"}
MAX_UPLOAD_SIZE = 10 * 1024 * 1024


@router.post("/{po_id}/upload-invoice")
async def upload_invoice_image(po_id: uuid.UUID, file: UploadFile = File(...),
                                db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    import os
    import shutil
    from app.core.config import settings as cfg
    if file.content_type not in ALLOWED_UPLOAD_TYPES:
        raise HTTPException(400, "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP, PDF")
    contents = await file.read()
    if len(contents) > MAX_UPLOAD_SIZE:
        raise HTTPException(400, "حجم الملف يتجاوز 10 ميجابايت")
    os.makedirs(cfg.UPLOAD_DIR, exist_ok=True)
    safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', file.filename or "invoice.jpg")
    ext = os.path.splitext(safe_name)[1] or ".jpg"
    dest = os.path.join(cfg.UPLOAD_DIR, f"po_{po_id}{ext}")
    with open(dest, "wb") as f:
        f.write(contents)
    url = f"/uploads/po_{po_id}{ext}"
    await db.execute(text("UPDATE purchase_orders SET invoice_image_url=:url WHERE id=:id"), {"url": url, "id": po_id})
    await db.commit()
    return {"invoice_image_url": url}


@router.post("/quick-add-product")
async def quick_add_product(data: QuickProductCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("purchases", "inventory"))):
    """Create a new product inline during purchase entry."""
    from app.models.product import Product
    from app.models.product import Subcategory
    
    # If subcategory_id is provided, use it
    if data.subcategory_id:
        sub = await db.scalar(select(Subcategory).where(Subcategory.id == data.subcategory_id))
        if not sub:
            raise BusinessError("التصنيف الفرعي غير موجود")
    else:
        # Try to find a default subcategory named "عام" or "متنوع"
        sub = await db.scalar(
            select(Subcategory).where(
                or_(
                    Subcategory.name.ilike("عام"),
                    Subcategory.name.ilike("متنوع"),
                    Subcategory.name.ilike("general"),
                    Subcategory.name.ilike("miscellaneous")
                )
            ).limit(1)
        )
        # If no default found, use first subcategory
        if not sub:
            sub = await db.scalar(select(Subcategory).limit(1))
            if not sub:
                raise BusinessError("لا توجد تصنيفات — أضف تصنيف أولاً")
    
    p = Product(
        name=data.name,
        unit=data.unit or "عدد",
        cost_price=float(data.cost_price or 0),
        retail_price=float(data.retail_price or 0),
        wholesale_price=float(data.wholesale_price or 0),
        company=data.company or "",
        subcategory_id=sub.id,
    )
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return {
        "id": str(p.id),
        "name": p.name,
        "unit": p.unit,
        "cost_price": float(p.cost_price),
        "retail_price": float(p.retail_price),
        "barcode": p.barcode,
    }


# ── Supplier Prices ────────────────────────────────────────────────────────
@router.get("/supplier-prices/product/{product_id}", response_model=SupplierPriceComparison)
async def get_product_supplier_prices(product_id: str, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Get all supplier prices for a product with comparison."""
    prod_uuid = uuid.UUID(product_id)
    prod = await db.scalar(select(Product).where(Product.id == prod_uuid))
    if not prod:
        raise NotFoundError()

    rows = await db.execute(
        text(
            """
            SELECT sp.id, sp.supplier_id, sp.product_id, sp.price, sp.currency, sp.min_qty,
                   sp.last_purchase_date, sp.notes, sp.is_active, sp.created_at, sp.updated_at,
                   s.name AS supplier_name
            FROM supplier_prices sp
            JOIN suppliers s ON s.id = sp.supplier_id
            WHERE sp.product_id = :pid AND sp.is_active = true
            ORDER BY sp.price ASC
            """
        ),
        {"pid": prod_uuid},
    )

    suppliers = [dict(r._mapping) for r in rows.fetchall()]
    return {
        "product_id": prod_uuid,
        "product_name": prod.name,
        "suppliers": suppliers,
    }


@router.post("/supplier-prices", response_model=SupplierPriceOut)
async def create_supplier_price(
    data: SupplierPriceCreate,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(require_perm("operations"))
):
    """Create or update supplier price."""
    
    # Check if already exists
    existing = await db.scalar(
        select(SupplierPrice).where(
            SupplierPrice.supplier_id == data.supplier_id,
            SupplierPrice.product_id == data.product_id
        )
    )
    
    if existing:
        # Update
        existing.price = data.price
        existing.currency = data.currency
        existing.min_qty = data.min_qty
        existing.notes = data.notes
        existing.is_active = True
    else:
        # Create
        existing = SupplierPrice(**data.model_dump())
        db.add(existing)
    
    await db.commit()
    await db.refresh(existing)
    return existing


@router.put("/supplier-prices/{price_id}", response_model=SupplierPriceOut)
async def update_supplier_price(
    price_id: str,
    data: SupplierPriceUpdate,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_perm("operations"))
):
    """Update supplier price."""
    import uuid
    from app.core.exceptions import NotFoundError
    
    sp = await db.scalar(select(SupplierPrice).where(SupplierPrice.id == uuid.UUID(price_id)))
    if not sp:
        raise NotFoundError()
    
    for k, v in data.model_dump(exclude_none=True).items():
        setattr(sp, k, v)
    
    await db.commit()
    await db.refresh(sp)
    return sp


@router.delete("/supplier-prices/{price_id}", status_code=204)
async def delete_supplier_price(
    price_id: str,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_perm("operations"))
):
    """Soft-delete supplier price."""
    import uuid
    from app.core.exceptions import NotFoundError
    
    sp = await db.scalar(select(SupplierPrice).where(SupplierPrice.id == uuid.UUID(price_id)))
    if not sp:
        raise NotFoundError()
    
    sp.is_active = False
    await db.commit()
