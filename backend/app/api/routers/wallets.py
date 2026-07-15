"""Payment wallets — محافظ إلكترونية."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user, require_perm, verify_warehouse_access
from app.models.user import User
from app.schemas.wallet import WalletCreate, WalletUpdate
import uuid

router = APIRouter(prefix="/wallets", tags=["wallets"])

@router.get("")
async def list_wallets(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("SELECT * FROM payment_wallets WHERE is_active=true ORDER BY type, name"))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("", status_code=201)
async def create_wallet(data: WalletCreate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("finance"))):
    r = await db.execute(text(
        "INSERT INTO payment_wallets (name, type, phone) VALUES (:name, :type, :phone) RETURNING *"
    ), {"name": data.name, "type": data.type, "phone": data.phone})
    await db.commit()
    return dict(r.fetchone()._mapping)


@router.put("/{wid}")
async def update_wallet(wid: uuid.UUID, data: WalletUpdate, db: AsyncSession = Depends(get_db), _=Depends(require_perm("finance"))):
    await db.execute(text(
        "UPDATE payment_wallets SET name=:name, phone=:phone WHERE id=:id"
    ), {"name": data.name, "phone": data.phone, "id": wid})
    await db.commit()
    return {"ok": True}


@router.delete("/{wid}", status_code=204)
async def delete_wallet(wid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_perm("finance"))):
    from app.core.exceptions import BusinessError
    row = await db.execute(text("SELECT balance FROM payment_wallets WHERE id=:id"), {"id": wid})
    balance = row.scalar_one_or_none()
    if balance and float(balance) != 0:
        raise BusinessError(f"لا يمكن حذف المحفظة — رصيدها {balance} ج.م. قم بتحويل الرصيد أولاً")
    await db.execute(text("UPDATE payment_wallets SET is_active=false WHERE id=:id"), {"id": wid})
    await db.commit()


@router.get("/summary")
async def wallets_summary(
    from_date: str | None = None,
    to_date: str | None = None,
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Summary of sales per payment method."""
    await verify_warehouse_access(db, current_user, uuid.UUID(warehouse_id) if warehouse_id else None)
    conditions = ["s.status = 'confirmed'"]
    params: dict = {}  # NOSONAR: values are parameterized
    if from_date:
        conditions.append("DATE(s.created_at) >= :fd")
        params["fd"] = from_date
    if to_date:
        conditions.append("DATE(s.created_at) <= :td")
        params["td"] = to_date
    if warehouse_id:
        conditions.append("s.warehouse_id = :wh")
        params["wh"] = warehouse_id

    rows = await db.execute(text(f"""
        SELECT
            COALESCE(s.payment_method, 'cash') as payment_method,
            pw.name as wallet_name,
            pw.phone as wallet_phone,
            pw.type as wallet_type,
            COUNT(s.id) as invoice_count,
            COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) - COALESCE(SUM(s.discount_amount),0) as total
        FROM sales s
        LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
        LEFT JOIN sale_items si ON si.sale_id = s.id
        WHERE {' AND '.join(conditions)}
        GROUP BY s.payment_method, pw.name, pw.phone, pw.type
        ORDER BY total DESC
    """), params)
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("/{wid}/reset-balance", status_code=204)
async def reset_wallet_balance(wid: uuid.UUID, db: AsyncSession = Depends(get_db), current_user: User = Depends(require_perm("finance"))):
    """Reset a wallet balance to 0."""
    row = await db.execute(text("SELECT balance FROM payment_wallets WHERE id=:id FOR UPDATE"), {"id": wid})
    old_balance = row.scalar_one_or_none()
    if old_balance and float(old_balance) != 0:
        await db.execute(text("""
            INSERT INTO wallet_transactions (wallet_id, amount, tx_type, note, created_by)
            VALUES (:wid, :amt, 'adjustment', 'تصفير الرصيد', :uid)
        """), {"wid": wid, "amt": -old_balance, "uid": current_user.id})
    await db.execute(text("UPDATE payment_wallets SET balance = 0 WHERE id = :id"), {"id": wid})
    await db.commit()


@router.get("/{wid}/history")
async def wallet_history(wid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    from app.services.wallet_service import get_wallet_history
    return await get_wallet_history(db, wid)
