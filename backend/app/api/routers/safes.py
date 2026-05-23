"""Safes (خزنات) — treasury management."""
import json
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user, require_role, require_perm
from app.models.user import User
from app.schemas.safe import SafeCreate, SafeUpdate, SafeTransferCreate, SafeDepositCreate, SafeWithdrawCreate

router = APIRouter(prefix="/safes", tags=["safes"])


@router.get("")
async def list_safes(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("SELECT * FROM safes WHERE is_active=true ORDER BY name"))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("", status_code=201)
async def create_safe(data: SafeCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("finance"))):
    r = await db.execute(text(
        "INSERT INTO safes (name, location) VALUES (:name, :loc) RETURNING *"
    ), {"name": data.name, "loc": data.location or ""})
    await db.commit()
    return dict(r.fetchone()._mapping)


@router.put("/{safe_id}")
async def update_safe(safe_id: uuid.UUID, data: SafeUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("finance"))):
    await db.execute(text(
        "UPDATE safes SET name=:name, location=:loc WHERE id=:id"
    ), {"name": data.name, "loc": data.location or "", "id": safe_id})
    await db.commit()
    r = await db.execute(text("SELECT * FROM safes WHERE id=:id"), {"id": safe_id})
    return dict(r.fetchone()._mapping)


@router.post("/transfer")
async def transfer_to_safe(data: SafeTransferCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("finance"))):
    """Transfer balance from a payment wallet to a permanent safe."""
    wallet_id = data.from_wallet_id
    safe_id = data.to_safe_id
    amt = float(data.amount)

    wallet = (await db.execute(text("SELECT * FROM payment_wallets WHERE id=:id FOR UPDATE"), {"id": wallet_id})).mappings().fetchone()
    if not wallet:
        raise HTTPException(404, "Wallet not found")
    if float(wallet["balance"]) < amt:
        raise HTTPException(400, f"رصيد المحفظة غير كافٍ ({wallet['balance']} ج.م)")

    # Deduct from wallet
    await db.execute(text("UPDATE payment_wallets SET balance = balance - :amt WHERE id=:id"), {"amt": amt, "id": wallet_id})
    # Add to safe
    await db.execute(text("UPDATE safes SET balance = balance + :amt WHERE id=:id"), {"amt": amt, "id": safe_id})
    # Log transaction
    new_balance = (await db.execute(text("SELECT balance FROM safes WHERE id=:id"), {"id": safe_id})).scalar()
    await db.execute(text("""
        INSERT INTO safe_transactions (safe_id, tx_type, amount, balance_after, note, created_by)
        VALUES (:sid, 'deposit', :amt, :bal, :note, :uid)
    """), {"sid": safe_id, "amt": amt, "bal": new_balance,
           "note": data.note or f"تحويل من {wallet['name']}", "uid": current_user.id})
    await db.commit()
    return {"ok": True}


@router.post("/{safe_id}/deposit")
async def deposit_to_safe(
    safe_id: uuid.UUID,
    data: SafeDepositCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_perm("finance"))
):
    """Record a cash deposit to a safe."""
    seq = (await db.execute(text("SELECT nextval('invoice_seq')"))).scalar()
    doc_number = f"DEP-{seq:06d}"

    received_by_name = ""
    if data.received_by_id:
        row = await db.execute(text("SELECT full_name FROM users WHERE id=:id"), {"id": data.received_by_id})
        received_by_name = row.scalar() or ""

    await db.execute(text("""
        INSERT INTO safe_deposits
            (safe_id, shift_id, warehouse_id, amount, received_by, received_by_name,
             deposited_by, deposited_by_name, notes, doc_number)
        VALUES (:sid, :shift, :wh, :amt, :recv, :recv_name, :dep, :dep_name, :notes, :doc)
    """), {
        "sid": safe_id,
        "shift": data.shift_id,
        "wh": data.warehouse_id,
        "amt": float(data.amount),
        "recv": data.received_by_id,
        "recv_name": received_by_name,
        "dep": current_user.id,
        "dep_name": current_user.full_name,
        "notes": data.notes or "",
        "doc": doc_number,
    })

    await db.execute(text(
        "UPDATE safes SET balance = balance + :amt WHERE id = :id"
    ), {"amt": float(data.amount), "id": safe_id})

    new_balance = (await db.execute(text("SELECT balance FROM safes WHERE id=:id"), {"id": safe_id})).scalar()
    await db.execute(text("""
        INSERT INTO safe_transactions (safe_id, tx_type, amount, balance_after, note, created_by)
        VALUES (:sid, 'deposit', :amt, :bal, :note, :uid)
    """), {"sid": safe_id, "amt": float(data.amount), "bal": new_balance, "note": data.notes or "", "uid": current_user.id})

    safe_name = (await db.execute(text("SELECT name FROM safes WHERE id=:id"), {"id": safe_id})).scalar()
    wh_name = ""
    if data.warehouse_id:
        wh_name = (await db.execute(text("SELECT name FROM warehouses WHERE id=:id"), {"id": data.warehouse_id})).scalar() or ""

    await db.execute(text("""
        INSERT INTO archived_documents (id, doc_number, doc_type, amount, created_by, metadata)
        VALUES (gen_random_uuid(), :doc, 'safe_deposit', :amt, :uid, cast(:meta as jsonb))
    """), {
        "doc": doc_number,
        "amt": float(data.amount),
        "uid": current_user.id,
        "meta": json.dumps({
            "safe_name": safe_name or "",
            "warehouse": wh_name,
            "received_by": received_by_name,
            "deposited_by": current_user.full_name,
            "notes": data.notes or "",
        })
    })

    await db.commit()
    return {
        "doc_number": doc_number,
        "amount": float(data.amount),
        "safe": safe_name,
        "received_by": received_by_name,
    }


@router.post("/{safe_id}/withdraw")
async def withdraw_from_safe(
    safe_id: uuid.UUID,
    data: SafeWithdrawCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("admin", "manager"))
):
    safe = (await db.execute(text("SELECT * FROM safes WHERE id=:id FOR UPDATE"), {"id": safe_id})).mappings().fetchone()
    if not safe:
        raise HTTPException(404, "Safe not found")
    if float(safe["balance"]) < float(data.amount):
        raise HTTPException(400, f"رصيد الخزنة غير كافٍ ({safe['balance']} ج.م)")

    await db.execute(text("UPDATE safes SET balance = balance - :amt WHERE id = :id"),
                     {"amt": float(data.amount), "id": safe_id})
    new_balance = (await db.execute(text("SELECT balance FROM safes WHERE id=:id"), {"id": safe_id})).scalar()
    await db.execute(text("""
        INSERT INTO safe_transactions (safe_id, tx_type, amount, balance_after, note, created_by)
        VALUES (:sid, 'withdraw', :amt, :bal, :note, :uid)
    """), {"sid": safe_id, "amt": float(data.amount), "bal": new_balance, "note": data.note or "", "uid": current_user.id})
    await db.commit()
    return {"balance": new_balance}


@router.get("/{safe_id}/history")
async def safe_history(safe_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("""
        SELECT * FROM safe_transactions WHERE safe_id = :id ORDER BY created_at DESC LIMIT 100
    """), {"id": safe_id})
    return [dict(r._mapping) for r in rows.fetchall()]
