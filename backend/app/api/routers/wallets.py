"""Payment wallets — محافظ إلكترونية."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user, require_role
import uuid

router = APIRouter(prefix="/wallets", tags=["wallets"])

TYPE_LABELS = {"cash": "نقدي", "vodafone_cash": "فودافون كاش", "instapay": "إنستا باي"}


@router.get("")
async def list_wallets(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("SELECT * FROM payment_wallets WHERE is_active=true ORDER BY type, name"))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("", status_code=201)
async def create_wallet(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    r = await db.execute(text(
        "INSERT INTO payment_wallets (name, type, phone) VALUES (:name, :type, :phone) RETURNING *"
    ), {"name": data["name"], "type": data["type"], "phone": data.get("phone")})
    await db.commit()
    return dict(r.fetchone()._mapping)


@router.put("/{wid}")
async def update_wallet(wid: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text(
        "UPDATE payment_wallets SET name=:name, phone=:phone WHERE id=:id"
    ), {"name": data["name"], "phone": data.get("phone"), "id": wid})
    await db.commit()
    return {"ok": True}


@router.delete("/{wid}", status_code=204)
async def delete_wallet(wid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    await db.execute(text("UPDATE payment_wallets SET is_active=false WHERE id=:id"), {"id": wid})
    await db.commit()


@router.get("/summary")
async def wallets_summary(
    from_date: str | None = None,
    to_date: str | None = None,
    warehouse_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user)
):
    """Summary of sales per payment method."""
    conditions = ["s.status = 'confirmed'"]
    params: dict = {}
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
            COALESCE(SUM(si.qty * si.unit_price - si.discount), 0) - COALESCE(MAX(s.discount_amount),0) as total
        FROM sales s
        LEFT JOIN payment_wallets pw ON pw.id = s.wallet_id
        LEFT JOIN sale_items si ON si.sale_id = s.id
        WHERE {' AND '.join(conditions)}
        GROUP BY s.payment_method, pw.name, pw.phone, pw.type
        ORDER BY total DESC
    """), params)
    return [dict(r._mapping) for r in rows.fetchall()]
