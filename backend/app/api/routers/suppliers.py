from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.dependencies import get_db, get_current_user, require_role
from pydantic import BaseModel
from typing import Optional
import uuid

router = APIRouter(prefix="/suppliers", tags=["suppliers"])

class SupplierIn(BaseModel):
    name: str
    phone: Optional[str] = None
    address: Optional[str] = None
    type: str = "supplier"
    notes: Optional[str] = None

class TxIn(BaseModel):
    amount: float
    type: str  # debit / credit
    reference_doc: Optional[str] = None
    notes: Optional[str] = None

@router.get("")
async def list_suppliers(type: Optional[str] = None, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    q = "SELECT * FROM suppliers"
    params = {}
    if type:
        q += " WHERE type=:type"
        params["type"] = type
    q += " ORDER BY name"
    r = await db.execute(text(q), params)
    return [dict(row._mapping) for row in r.fetchall()]

@router.post("", status_code=201)
async def create_supplier(data: SupplierIn, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text(
        "INSERT INTO suppliers (name,phone,address,type,notes,balance) VALUES (:name,:phone,:address,:type,:notes,0) RETURNING id,name,phone,address,type,balance,notes,created_at"
    ), data.model_dump())
    await db.commit()
    return dict(r.fetchone()._mapping)

@router.put("/{sid}")
async def update_supplier(sid: uuid.UUID, data: SupplierIn, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text(
        "UPDATE suppliers SET name=:name,phone=:phone,address=:address,type=:type,notes=:notes WHERE id=:id RETURNING *"
    ), {**data.model_dump(), "id": sid})
    await db.commit()
    row = r.fetchone()
    if not row: raise HTTPException(404)
    return dict(row._mapping)

@router.delete("/{sid}", status_code=204)
async def delete_supplier(sid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text("DELETE FROM suppliers WHERE id=:id"), {"id": sid})
    await db.commit()

@router.get("/{sid}/ledger")
async def supplier_ledger(sid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    sup = await db.execute(text("SELECT * FROM suppliers WHERE id=:id"), {"id": sid})
    sup_row = sup.fetchone()
    if not sup_row: raise HTTPException(404)
    txs = await db.execute(text(
        "SELECT * FROM supplier_transactions WHERE supplier_id=:id ORDER BY created_at DESC"
    ), {"id": sid})
    return {
        "supplier": dict(sup_row._mapping),
        "transactions": [dict(r._mapping) for r in txs.fetchall()]
    }

@router.post("/{sid}/transactions", status_code=201)
async def add_transaction(sid: uuid.UUID, data: TxIn, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    # Insert transaction
    await db.execute(text(
        "INSERT INTO supplier_transactions (supplier_id,amount,type,reference_doc,notes) VALUES (:sid,:amount,:type,:ref,:notes)"
    ), {"sid": sid, "amount": data.amount, "type": data.type, "ref": data.reference_doc, "notes": data.notes})
    # Update balance: debit = we owe them (+), credit = they owe us / payment (-)
    delta = data.amount if data.type == "debit" else -data.amount
    await db.execute(text("UPDATE suppliers SET balance=balance+:delta WHERE id=:id"), {"delta": delta, "id": sid})
    await db.commit()
    return {"ok": True}
