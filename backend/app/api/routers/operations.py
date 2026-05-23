"""
operations.py — مستندات العمليات
- إذن صرف (dispatch): من مخزن → معرض
- استلام بضاعة (goods_receipt): من تاجر → مخزن
- طلب نواقص (stock_request): طلب توريد من مخزن
كل عملية تُسجَّل في stock_movements وتُحفَظ في archived_documents تلقائياً.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone
from decimal import Decimal
from typing import List
from pydantic import BaseModel, model_validator
from app.db.base import get_db
from app.models.stock import StockMovement, MovementType
from app.models.archive import ArchivedDocument, DocType
from app.models.warehouse import Warehouse
from app.models.product import Product
from app.models.settings import StoreSetting
from app.dependencies import get_current_user, require_perm
from app.models.user import User
from app.services.stock_service import get_balance
from app.services.audit_service import log as audit_log
import uuid

router = APIRouter(prefix="/operations", tags=["operations"])


class OperationItem(BaseModel):
    product_id: uuid.UUID
    qty: Decimal
    unit_cost: Decimal = Decimal("0")
    note: str = ""


class DispatchRequest(BaseModel):
    from_warehouse_id: uuid.UUID
    to_warehouse_id: uuid.UUID
    items: List[OperationItem]
    notes: str = ""

    @model_validator(mode='after')
    def check_warehouses(self):
        if self.from_warehouse_id == self.to_warehouse_id:
            raise ValueError('لا يمكن أن يكون مخزن المصدر والوجهة نفس المخزن')
        return self


class GoodsReceiptRequest(BaseModel):
    warehouse_id: uuid.UUID
    supplier_name: str = ""
    items: List[OperationItem]   # unit_cost = سعر التكلفة من التاجر
    notes: str = ""


class StockRequestRequest(BaseModel):
    from_warehouse_id: uuid.UUID
    to_warehouse_id: uuid.UUID
    items: List[OperationItem]
    notes: str = ""

    @model_validator(mode='after')
    def check_warehouses(self):
        if self.from_warehouse_id == self.to_warehouse_id:
            raise ValueError('لا يمكن أن يكون مخزن المصدر والوجهة نفس المخزن')
        return self


async def _get_settings(db: AsyncSession) -> dict:
    rows = (await db.execute(select(StoreSetting))).scalars().all()
    return {r.key: r.value for r in rows}


async def _archive(db: AsyncSession, doc_type: DocType, doc_number: str,
                   amount: Decimal, metadata: dict, created_by: uuid.UUID, ref_id: uuid.UUID = None):
    doc = ArchivedDocument(
        doc_number=doc_number,
        doc_type=doc_type,
        amount=amount,
        metadata_=metadata,
        ref_id=ref_id,
        created_by=created_by,
    )
    db.add(doc)
    return doc


@router.post("/dispatch")
async def dispatch_order(data: DispatchRequest, db: AsyncSession = Depends(get_db),
                         current_user: User = Depends(require_perm("operations"))):
    """إذن صرف — نقل بضاعة من مخزن إلى معرض."""
    doc_number = f"DSP-{datetime.now(timezone.utc).strftime('%m%d%H%M%S')}"
    ref_id = uuid.uuid4()
    total_qty = Decimal("0")

    from_wh = (await db.execute(select(Warehouse).where(Warehouse.id == data.from_warehouse_id))).scalar_one_or_none()
    to_wh   = (await db.execute(select(Warehouse).where(Warehouse.id == data.to_warehouse_id))).scalar_one_or_none()

    items_detail = []
    for item in data.items:
        prod = (await db.execute(select(Product).where(Product.id == item.product_id))).scalar_one_or_none()
        balance = await get_balance(db, item.product_id, data.from_warehouse_id)
        if balance < item.qty:
            raise HTTPException(400, f"رصيد غير كافٍ للمنتج {prod.name if prod else ''} — المتاح {balance}")
        db.add(StockMovement(product_id=item.product_id, warehouse_id=data.from_warehouse_id,
                             movement_type=MovementType.transfer_out, qty=item.qty,
                             ref_id=ref_id, ref_type="dispatch", note=item.note or data.notes,
                             created_by=current_user.id))
        db.add(StockMovement(product_id=item.product_id, warehouse_id=data.to_warehouse_id,
                             movement_type=MovementType.transfer_in, qty=item.qty,
                             ref_id=ref_id, ref_type="dispatch", note=item.note or data.notes,
                             created_by=current_user.id))
        total_qty += item.qty
        items_detail.append({"product_id": str(item.product_id), "name": prod.name if prod else "", "qty": float(item.qty)})

    await _archive(db, DocType.dispatch_order, doc_number, total_qty,
                   {"from": from_wh.name if from_wh else "", "to": to_wh.name if to_wh else "",
                    "items": items_detail, "notes": data.notes, "employee": current_user.full_name},
                   current_user.id, ref_id)
    await audit_log(db, "dispatch", "create", current_user.id, current_user.full_name, ref_id, {"from": from_wh.name, "to": to_wh.name, "items_count": len(data.items)}, f"إذن صرف {doc_number}")
    await db.commit()
    return {"doc_number": doc_number, "doc_type": "dispatch_order", "items_count": len(data.items)}


@router.post("/goods-receipt")
async def goods_receipt(data: GoodsReceiptRequest, db: AsyncSession = Depends(get_db),
                        current_user: User = Depends(require_perm("operations"))):
    """استلام بضاعة من تاجر — يُضاف للمخزن بأسعار التكلفة."""
    doc_number = f"GR-{datetime.now(timezone.utc).strftime('%m%d%H%M%S')}"
    ref_id = uuid.uuid4()
    total_cost = Decimal("0")

    wh = (await db.execute(select(Warehouse).where(Warehouse.id == data.warehouse_id))).scalar_one_or_none()

    items_detail = []
    for item in data.items:
        prod = (await db.execute(select(Product).where(Product.id == item.product_id))).scalar_one_or_none()
        db.add(StockMovement(product_id=item.product_id, warehouse_id=data.warehouse_id,
                             movement_type=MovementType.purchase, qty=item.qty,
                             unit_cost=item.unit_cost,
                             ref_id=ref_id, ref_type="goods_receipt", note=data.notes,
                             created_by=current_user.id))
        total_cost += item.qty * item.unit_cost
        items_detail.append({"product_id": str(item.product_id), "name": prod.name if prod else "",
                              "qty": float(item.qty), "unit_cost": float(item.unit_cost)})
        # Update product cost_price if provided
        if item.unit_cost > 0 and prod:
            prod.cost_price = item.unit_cost

    await _archive(db, DocType.goods_receipt, doc_number, total_cost,
                   {"warehouse": wh.name if wh else "", "supplier": data.supplier_name,
                    "items": items_detail, "notes": data.notes, "employee": current_user.full_name},
                   current_user.id, ref_id)
    await audit_log(db, "goods_receipt", "create", current_user.id, current_user.full_name, ref_id, {"warehouse": wh.name, "items_count": len(data.items)}, f"استلام بضاعة {doc_number}")
    await db.commit()
    return {"doc_number": doc_number, "doc_type": "goods_receipt", "total_cost": float(total_cost)}


@router.post("/stock-request")
async def stock_request(data: StockRequestRequest, db: AsyncSession = Depends(get_db),
                        current_user: User = Depends(require_perm("operations"))):
    """طلب نواقص — مستند طلب توريد بدون حركة مخزون فورية."""
    doc_number = f"REQ-{datetime.now(timezone.utc).strftime('%m%d%H%M%S')}"
    ref_id = uuid.uuid4()

    from_wh = (await db.execute(select(Warehouse).where(Warehouse.id == data.from_warehouse_id))).scalar_one_or_none()
    to_wh   = (await db.execute(select(Warehouse).where(Warehouse.id == data.to_warehouse_id))).scalar_one_or_none()

    items_detail = []
    for item in data.items:
        prod = (await db.execute(select(Product).where(Product.id == item.product_id))).scalar_one_or_none()
        items_detail.append({"product_id": str(item.product_id), "name": prod.name if prod else "", "qty": float(item.qty)})

    await _archive(db, DocType.stock_request, doc_number, Decimal("0"),
                   {"from": from_wh.name if from_wh else "", "to": to_wh.name if to_wh else "",
                    "items": items_detail, "notes": data.notes, "employee": current_user.full_name,
                    "status": "pending"},
                   current_user.id, ref_id)
    await db.commit()
    return {"doc_number": doc_number, "doc_type": "stock_request", "items_count": len(data.items)}


@router.get("/")
async def list_operations(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """قائمة بكل مستندات العمليات."""
    result = await db.execute(
        select(ArchivedDocument)
        .where(ArchivedDocument.doc_type.in_([
            DocType.dispatch_order, DocType.goods_receipt, DocType.stock_request
        ]))
        .order_by(ArchivedDocument.created_at.desc())
        .limit(200)
    )
    docs = result.scalars().all()
    return [{"id": str(d.id), "doc_number": d.doc_number, "doc_type": d.doc_type,
             "amount": float(d.amount or 0), "metadata": d.metadata_,
             "created_at": d.created_at.isoformat()} for d in docs]
# TODO: needs pagination — has limit but no offset
