from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from datetime import datetime
from app.db.base import get_db
from app.models.purchase import PurchaseOrder, PurchaseOrderItem, POStatus
from app.models.stock import MovementType
from app.schemas.stock import StockMovementCreate
from app.services.stock_service import record_movement
from app.dependencies import get_current_user, require_role
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
import uuid

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
async def create_purchase(data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    from sqlalchemy import text as _text
    seq = (await db.execute(_text("SELECT nextval('purchase_seq')"))).scalar()
    po_number = f"PO-{seq:06d}"
    po = PurchaseOrder(
        po_number=po_number,
        supplier_id=data.get("supplier_id"),
        warehouse_id=data["warehouse_id"],
        created_by=current_user.id,
        notes=data.get("notes"),
    )
    # Extra fields via raw update after flush
    db.add(po)
    await db.flush()
    if data.get("amount_paid") or data.get("received_by_name"):
        await db.execute(_text("UPDATE purchase_orders SET amount_paid=:ap, received_by_name=:rbn WHERE id=:id"),
                         {"ap": data.get("amount_paid", 0), "rbn": data.get("received_by_name", ""), "id": po.id})
    for item in data.get("items", []):
        db.add(PurchaseOrderItem(
            po_id=po.id,
            product_id=item["product_id"],
            qty_ordered=item["qty"],
            unit_cost=item["unit_cost"],
            notes=item.get("notes"),
        ))
    await db.commit()
    await db.refresh(po)
    return {"id": str(po.id), "po_number": po.po_number, "status": po.status}


@router.put("/{po_id}")
async def update_purchase(po_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Update draft PO items/supplier before receiving."""
    result = await db.execute(select(PurchaseOrder).where(PurchaseOrder.id == po_id))
    po = result.scalar_one_or_none()
    if not po:
        raise NotFoundError()
    if po.status != POStatus.draft:
        raise BusinessError("Can only edit draft POs")

    if "supplier_id" in data:
        po.supplier_id = data["supplier_id"]
    if "notes" in data:
        po.notes = data["notes"]

    # Replace items
    await db.execute(text("DELETE FROM purchase_order_items WHERE po_id=:id"), {"id": po_id})
    for item in data.get("items", []):
        db.add(PurchaseOrderItem(
            po_id=po.id,
            product_id=item["product_id"],
            qty_ordered=item["qty"],
            unit_cost=item["unit_cost"],
            notes=item.get("notes"),
        ))
    await db.commit()
    return {"ok": True}


@router.post("/{po_id}/receive")
async def receive_purchase(po_id: uuid.UUID, data: dict = {}, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Receive PO. Optionally pass overridden items with actual received qty/cost:
    { items: [{product_id, qty_received, unit_cost}] }
    """
    result = await db.execute(select(PurchaseOrder).where(PurchaseOrder.id == po_id))
    po = result.scalar_one_or_none()
    if not po:
        raise NotFoundError()
    if po.status == POStatus.received:
        raise BusinessError("Already received")

    items = (await db.execute(select(PurchaseOrderItem).where(PurchaseOrderItem.po_id == po_id))).scalars().all()

    # Build override map if provided
    overrides = {str(i["product_id"]): i for i in data.get("items", [])}

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
    po.received_at = datetime.utcnow()

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
    from app.models.archive import ArchivedDocument, DocType
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


@router.post("/{po_id}/upload-invoice")
async def upload_invoice_image(po_id: uuid.UUID, file: UploadFile = File(...),
                                db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    import os, shutil
    from app.core.config import settings as cfg
    os.makedirs(cfg.UPLOAD_DIR, exist_ok=True)
    ext = os.path.splitext(file.filename or "invoice.jpg")[1] or ".jpg"
    dest = os.path.join(cfg.UPLOAD_DIR, f"po_{po_id}{ext}")
    with open(dest, "wb") as f:
        shutil.copyfileobj(file.file, f)
    url = f"/uploads/po_{po_id}{ext}"
    await db.execute(text("UPDATE purchase_orders SET invoice_image_url=:url WHERE id=:id"), {"url": url, "id": po_id})
    await db.commit()
    return {"invoice_image_url": url}


@router.post("/quick-add-product")
async def quick_add_product(data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Create a new product inline during purchase entry."""
    from app.models.product import Product
    from app.models.product import Subcategory
    # Get or create a default subcategory
    sub = (await db.execute(select(Subcategory).limit(1))).scalar_one_or_none()
    if not sub:
        from app.core.exceptions import BusinessError
        raise BusinessError("لا توجد تصنيفات — أضف تصنيف أولاً")
    p = Product(
        name=data["name"],
        unit=data.get("unit", "عدد"),
        cost_price=data.get("cost_price", 0),
        retail_price=data.get("retail_price", 0),
        wholesale_price=data.get("wholesale_price", 0),
        company=data.get("company", ""),
        subcategory_id=data.get("subcategory_id") or sub.id,
    )
    db.add(p)
    await db.commit()
    await db.refresh(p)
    return {"id": str(p.id), "name": p.name, "unit": p.unit, "cost_price": float(p.cost_price),
            "retail_price": float(p.retail_price), "barcode": p.barcode}
