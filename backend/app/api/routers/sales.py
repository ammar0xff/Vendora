from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from sqlalchemy.orm import selectinload
from datetime import datetime
from app.db.base import get_db
from app.schemas.sale import SaleCreate, SaleOut
from app.models.sale import Sale, SaleItem, SaleStatus
from app.services import sale_service
from app.dependencies import get_current_user, require_role
from app.models.user import User
from app.core.exceptions import NotFoundError, BusinessError
import uuid

router = APIRouter(prefix="/sales", tags=["sales"])


@router.post("", response_model=SaleOut)
async def create_sale(data: SaleCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    return await sale_service.create_sale(db, data, current_user.id)


@router.get("", response_model=list[SaleOut])
async def list_sales(
    from_date: str | None = None,
    to_date: str | None = None,
    cashier_id: uuid.UUID | None = None,
    status: str | None = None,
    limit: int = Query(50, le=200),
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    from app.models.party import Customer
    from sqlalchemy import text as sqlt
    q = select(Sale, Customer.name.label("customer_name")).outerjoin(Customer, Sale.customer_id == Customer.id)
    q = q.options(selectinload(Sale.items)).order_by(Sale.created_at.desc()).limit(limit)
    if from_date: q = q.where(Sale.created_at >= from_date)
    if to_date: q = q.where(Sale.created_at <= to_date)
    if cashier_id: q = q.where(Sale.cashier_id == cashier_id)
    if status: q = q.where(Sale.status == status)
    rows = (await db.execute(q)).all()
    # Get user names in one query
    user_ids = list({str(sale.created_by) for sale, _ in rows if sale.created_by})
    user_names: dict = {}
    if user_ids:
        urows = await db.execute(sqlt("SELECT id, full_name FROM users WHERE id = ANY(:ids)"), {"ids": user_ids})
        user_names = {str(r.id): r.full_name for r in urows.fetchall()}
    result = []
    for sale, cname in rows:
        d = SaleOut.model_validate(sale).model_dump()
        d['customer_name'] = cname
        d['created_by_name'] = user_names.get(str(sale.created_by), '')
        result.append(d)
    return result


@router.post("/quotations", response_model=SaleOut)
async def create_quotation(data: SaleCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """إنشاء عرض سعر — لا يُخصم من المخزون."""
    return await sale_service.create_quotation(db, data, current_user.id)


@router.post("/{sale_id}/confirm-quotation", response_model=SaleOut)
async def confirm_quotation(sale_id: uuid.UUID, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """تحويل عرض السعر إلى فاتورة مبيعات مؤكدة."""
    return await sale_service.confirm_quotation(db, sale_id, current_user.id)


@router.get("/{sale_id}/print")
async def print_sale(sale_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """بيانات الفاتورة/عرض السعر للطباعة — تشمل بيانات المتجر والعميل والمنتجات."""
    from sqlalchemy import select as sa_select
    from app.models.product import Product
    from app.models.party import Customer
    from app.models.settings import StoreSetting

    result = await db.execute(sa_select(Sale).options(selectinload(Sale.items)).where(Sale.id == sale_id))
    sale = result.scalar_one_or_none()
    if not sale:
        raise NotFoundError("Sale not found")

    # Enrich items with product names
    items_out = []
    for item in sale.items:
        prod = (await db.execute(sa_select(Product).where(Product.id == item.product_id))).scalar_one_or_none()
        items_out.append({
            "product_name": prod.name if prod else str(item.product_id),
            "unit": prod.unit if prod else "",
            "qty": float(item.qty),
            "unit_price": float(item.unit_price),
            "discount": float(item.discount),
            "total": float(item.qty) * float(item.unit_price) - float(item.discount),
        })

    customer = None
    if sale.customer_id:
        customer = (await db.execute(sa_select(Customer).where(Customer.id == sale.customer_id))).scalar_one_or_none()

    settings_rows = (await db.execute(sa_select(StoreSetting))).scalars().all()
    settings = {r.key: r.value for r in settings_rows}

    subtotal = sum(i["total"] for i in items_out)
    total = subtotal - float(sale.discount_amount)

    return {
        "store": {"name": settings.get("store_name", ""), "address": settings.get("store_address", ""), "phone": settings.get("store_phone", ""), "logo_url": settings.get("logo_url", "")},
        "document_type": "عرض سعر" if sale.status == "quotation" else "فاتورة مبيعات",
        "invoice_number": sale.invoice_number,
        "date": sale.created_at.isoformat(),
        "sale_mode": sale.sale_mode,
        "status": sale.status,
        "customer": {"name": customer.name if customer else "عميل عادي", "phone": customer.phone if customer else ""},
        "items": items_out,
        "subtotal": subtotal,
        "discount": float(sale.discount_amount),
        "total": total,
        "notes": sale.notes or "",
        "created_by_name": (await db.execute(text("SELECT full_name FROM users WHERE id=:id"), {"id": sale.created_by})).scalar() if sale.created_by else "",
    }
@router.get("/{sale_id}")
async def get_sale(sale_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    from sqlalchemy import text as sqlt
    row = await db.execute(sqlt("""
        SELECT s.*, c.name as customer_name,
               json_agg(json_build_object(
                 'id', si.id, 'product_id', si.product_id, 'product_name', p.name,
                 'qty', si.qty, 'unit_price', si.unit_price, 'unit_cost', si.unit_cost
               )) as items
        FROM sales s
        LEFT JOIN customers c ON c.id = s.customer_id
        LEFT JOIN sale_items si ON si.sale_id = s.id
        LEFT JOIN products p ON p.id = si.product_id
        WHERE s.id = :id
        GROUP BY s.id, c.name
    """), {"id": sale_id})
    sale = row.fetchone()
    if not sale:
        raise NotFoundError("Sale not found")
    return dict(sale._mapping)


@router.put("/{sale_id}")
async def update_sale(sale_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Edit a quotation (status=quotation only)."""
    from sqlalchemy import text as sqlt
    sale_row = await db.execute(sqlt("SELECT status FROM sales WHERE id=:id"), {"id": sale_id})
    sale = sale_row.fetchone()
    if not sale:
        raise NotFoundError()
    if sale.status != "quotation":
        raise BusinessError("Only quotations can be edited")
    # Update items + recalculate total
    await db.execute(sqlt("DELETE FROM sale_items WHERE sale_id=:id"), {"id": sale_id})
    total = 0.0
    for item in data.get("items", []):
        line = float(item["qty"]) * float(item["unit_price"])
        total += line
        await db.execute(sqlt("""
            INSERT INTO sale_items (sale_id, product_id, qty, unit_price, unit_cost, discount)
            VALUES (:sid, :pid, :qty, :price, :cost, 0)
        """), {"sid": sale_id, "pid": item["product_id"], "qty": item["qty"],
               "price": item["unit_price"], "cost": item.get("unit_cost", 0)})
    updates = {"total": total, "id": sale_id}
    await db.execute(sqlt("UPDATE sales SET total_amount=:total WHERE id=:id"), updates)
    if "notes" in data:
        await db.execute(sqlt("UPDATE sales SET notes=:notes WHERE id=:id"), {"notes": data["notes"], "id": sale_id})
    if "customer_id" in data:
        await db.execute(sqlt("UPDATE sales SET customer_id=:cid WHERE id=:id"), {"cid": data.get("customer_id"), "id": sale_id})
    await db.commit()
    return {"id": str(sale_id)}


@router.put("/{sale_id}/cancel")
async def cancel_sale(sale_id: uuid.UUID, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    sale = await sale_service.cancel_sale(db, sale_id, current_user.id)
    return {"detail": "Cancelled", "invoice_number": sale.invoice_number}


@router.post("/{sale_id}/return")
async def return_sale(sale_id: uuid.UUID, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Full return of a confirmed sale."""
    return await sale_service.return_sale(db, sale_id, current_user.id)


@router.post("/{sale_id}/partial-return")
async def partial_return(sale_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """مرتجع جزئي — body: {items:[{product_id,qty}], shift_id?}"""
    from sqlalchemy.orm import selectinload as sil
    from app.models.stock import MovementType
    from app.schemas.stock import StockMovementCreate
    from app.services.stock_service import record_movement
    from app.models.archive import ArchivedDocument, DocType
    from app.models.shift import DrawerTransaction, DrawerTxType
    from decimal import Decimal

    orig = (await db.execute(select(Sale).options(sil(Sale.items)).where(Sale.id == sale_id))).scalar_one_or_none()
    if not orig:
        raise NotFoundError("Sale not found")

    return_map = {str(i["product_id"]): Decimal(str(i["qty"])) for i in data.get("items", [])}
    if not return_map:
        from app.core.exceptions import BusinessError; raise BusinessError("No items")

    ret = Sale(invoice_number="RET-" + datetime.utcnow().strftime('%m%d%H%M%S'),
               customer_id=orig.customer_id, warehouse_id=orig.warehouse_id,
               cashier_id=current_user.id, shift_id=data.get("shift_id") or orig.shift_id,
               sale_mode=orig.sale_mode, status=SaleStatus.returned,
               notes=f"مرتجع جزئي من {orig.invoice_number}")
    db.add(ret); await db.flush()

    total = Decimal("0")
    for oi in orig.items:
        pid = str(oi.product_id)
        if pid not in return_map: continue
        qty = return_map[pid]
        db.add(SaleItem(sale_id=ret.id, product_id=oi.product_id, qty=qty,
                        unit_price=oi.unit_price, unit_cost=oi.unit_cost, discount=Decimal("0")))
        total += qty * oi.unit_price
        await record_movement(db, StockMovementCreate(product_id=oi.product_id, warehouse_id=orig.warehouse_id,
            movement_type=MovementType.return_in, qty=qty, unit_cost=oi.unit_cost, unit_price=oi.unit_price),
            current_user.id, ref_id=ret.id, ref_type="partial_return")

    if ret.shift_id:
        db.add(DrawerTransaction(shift_id=ret.shift_id, type=DrawerTxType.return_,
                                  amount=total, ref_id=ret.id, created_by=current_user.id))
    db.add(ArchivedDocument(doc_number=ret.invoice_number, doc_type=DocType.sale_invoice,
                             amount=total, ref_id=ret.id, created_by=current_user.id,
                             metadata_={"original_invoice": orig.invoice_number, "type": "partial_return"}))
    await db.commit()
    return {"doc_number": ret.invoice_number, "total": float(total), "original": orig.invoice_number}


@router.put("/{sale_id}/items/{item_id}")
async def update_sale_item_qty(
    sale_id: uuid.UUID,
    item_id: uuid.UUID,
    data: dict,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("admin", "manager"))
):
    """Adjust qty of a sale item. Updates stock movements and drawer balance."""
    from sqlalchemy import text as sqlt
    from app.models.shift import DrawerTransaction, DrawerTxType

    new_qty = Decimal(str(data["qty"]))
    if new_qty <= 0:
        raise HTTPException(400, "الكمية يجب أن تكون أكبر من صفر")

    # Get current item
    item_row = await db.execute(sqlt(
        "SELECT si.*, s.warehouse_id, s.shift_id, p.stock_status FROM sale_items si "
        "JOIN sales s ON s.id = si.sale_id "
        "JOIN products p ON p.id = si.product_id "
        "WHERE si.id = :iid AND si.sale_id = :sid"
    ), {"iid": item_id, "sid": sale_id})
    item = item_row.fetchone()
    if not item:
        raise HTTPException(404, "البند غير موجود")

    old_qty = Decimal(str(item.qty))
    diff_qty = new_qty - old_qty
    diff_amount = diff_qty * Decimal(str(item.unit_price))

    # Update sale_item qty
    await db.execute(sqlt("UPDATE sale_items SET qty=:q WHERE id=:id"), {"q": new_qty, "id": item_id})

    # Update stock movement if tracked
    if item.stock_status == "tracked":
        if diff_qty > 0:
            # More sold → sale_out more
            await db.execute(sqlt("""
                INSERT INTO stock_movements (product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_id, ref_type, created_by)
                VALUES (:pid, :wid, 'sale_out', :qty, :cost, :price, :sid, 'sale_adjustment', :uid)
            """), {"pid": item.product_id, "wid": item.warehouse_id, "qty": diff_qty,
                   "cost": item.unit_cost, "price": item.unit_price, "sid": sale_id, "uid": current_user.id})
        elif diff_qty < 0:
            # Less sold → return stock
            await db.execute(sqlt("""
                INSERT INTO stock_movements (product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_id, ref_type, created_by)
                VALUES (:pid, :wid, 'return_in', :qty, :cost, :price, :sid, 'sale_adjustment', :uid)
            """), {"pid": item.product_id, "wid": item.warehouse_id, "qty": abs(diff_qty),
                   "cost": item.unit_cost, "price": item.unit_price, "sid": sale_id, "uid": current_user.id})

    # Update drawer if shift exists
    if item.shift_id and diff_amount != 0:
        tx_type = DrawerTxType.sale if diff_amount > 0 else DrawerTxType.return_
        db.add(DrawerTransaction(
            shift_id=item.shift_id,
            type=tx_type,
            amount=abs(diff_amount),
            ref_id=sale_id,
            note=f"تعديل كمية — {item.product_id}",
            created_by=current_user.id
        ))

    await db.commit()
    return {"ok": True, "old_qty": float(old_qty), "new_qty": float(new_qty), "diff_amount": float(diff_amount)}
