"""Wallet service — all wallet balance changes go through here."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from decimal import Decimal
import uuid


async def record_wallet_tx(
    db: AsyncSession,
    wallet_id: uuid.UUID,
    amount: Decimal,  # positive = money in, negative = money out
    tx_type: str,
    ref_id: uuid.UUID = None,
    note: str = None,
    created_by: uuid.UUID = None,
):
    """Record a wallet transaction and update balance atomically."""
    if amount < 0:
        # Lock the wallet row to prevent concurrent overdraft
        row = await db.execute(text(
            "SELECT balance FROM payment_wallets WHERE id = :wid FOR UPDATE"
        ), {"wid": wallet_id})
        current = row.scalar() or Decimal("0")
        if current + amount < 0:
            from app.core.exceptions import BusinessError
            raise BusinessError(f"Wallet balance insufficient: {current} available, {abs(amount)} requested")

    await db.execute(text("""
        INSERT INTO wallet_transactions (wallet_id, amount, tx_type, ref_id, note, created_by)
        VALUES (:wid, :amt, :type, :ref, :note, :uid)
    """), {"wid": wallet_id, "amt": amount, "type": tx_type,
           "ref": ref_id, "note": note, "uid": created_by})
    await db.execute(text(
        "UPDATE payment_wallets SET balance = balance + :amt WHERE id = :wid"
    ), {"amt": amount, "wid": wallet_id})


async def get_wallet_balance(db: AsyncSession, wallet_id: uuid.UUID) -> Decimal:
    """Compute balance from transactions (source of truth)."""
    row = await db.execute(text(
        "SELECT COALESCE(SUM(amount), 0) FROM wallet_transactions WHERE wallet_id = :wid"
    ), {"wid": wallet_id})
    return row.scalar() or Decimal("0")


async def get_wallet_history(db: AsyncSession, wallet_id: uuid.UUID, limit: int = 100):
    rows = await db.execute(text("""
        SELECT wt.*, u.full_name as user_name
        FROM wallet_transactions wt
        LEFT JOIN users u ON u.id = wt.created_by
        WHERE wt.wallet_id = :wid
        ORDER BY wt.created_at DESC LIMIT :lim
    """), {"wid": wallet_id, "lim": limit})
    return [dict(r._mapping) for r in rows.fetchall()]
