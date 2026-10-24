import uuid
from decimal import Decimal

from sqlalchemy import case, func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError, NotFoundError
from app.models.product import Product
from app.models.stock import IN_TYPES, MovementType, StockMovement
from app.models.stock_balance import StockBalance


async def get_balance(db: AsyncSession, product_id: uuid.UUID, warehouse_id: uuid.UUID, for_update: bool = False) -> Decimal:
    """Get current stock balance — O(1) read from maintained stock_balances table."""
    if for_update:
        # Lock the stock_balances row for update (creates row if not exists)
        result = await db.execute(text("""
            INSERT INTO stock_balances (product_id, warehouse_id, qty)
            VALUES (:pid, :wid, 0)
            ON CONFLICT (product_id, warehouse_id) DO NOTHING
            RETURNING qty
        """), {"pid": product_id, "wid": warehouse_id})
        row = result.fetchone()
        if row:
            return row.qty
        # Fallback: row was just created by another transaction
        result = await db.execute(
            select(StockBalance.qty).where(
                StockBalance.product_id == product_id,
                StockBalance.warehouse_id == warehouse_id,
            ).with_for_update()
        )
        return result.scalar_one_or_none() or Decimal("0")
    else:
        # Simple read from maintained table
        result = await db.execute(
            select(StockBalance.qty).where(
                StockBalance.product_id == product_id,
                StockBalance.warehouse_id == warehouse_id,
            )
        )
        return result.scalar_one_or_none() or Decimal("0")


async def _update_stock_balance(db: AsyncSession, product_id: uuid.UUID, warehouse_id: uuid.UUID, delta: Decimal):
    """Atomically update stock_balances by delta (can be positive or negative)."""
    await db.execute(text("""
        INSERT INTO stock_balances (product_id, warehouse_id, qty, updated_at)
        VALUES (:pid, :wid, GREATEST(:delta, 0), now())
        ON CONFLICT (product_id, warehouse_id) DO UPDATE SET
            qty = GREATEST(stock_balances.qty + :delta, 0),
            updated_at = now()
    """), {"pid": product_id, "wid": warehouse_id, "delta": delta})


async def record_movement(db: AsyncSession, data, created_by: uuid.UUID, ref_id=None, ref_type=None,
                          sale_id: uuid.UUID = None, purchase_id: uuid.UUID = None) -> StockMovement:
    """Record a stock movement and update maintained balances atomically."""
    mv = StockMovement(
        product_id=data.product_id,
        warehouse_id=data.warehouse_id,
        movement_type=data.movement_type,
        qty=data.qty,
        unit_cost=data.unit_cost,
        unit_price=data.unit_price,
        note=data.note,
        created_by=created_by,
        ref_id=ref_id,
        ref_type=ref_type,
        sale_id=sale_id,
        purchase_id=purchase_id,
    )
    db.add(mv)

    # Determine if this movement increases or decreases stock
    mt = str(data.movement_type).split('.')[-1]
    is_in = mt in ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
    delta = data.qty if is_in else -data.qty

    # Update maintained balance atomically
    await _update_stock_balance(db, data.product_id, data.warehouse_id, delta)

    # Mark product as tracked in this specific warehouse when stock is recorded
    if is_in:
        await db.execute(text("""
            INSERT INTO warehouse_product_status (warehouse_id, product_id, status)
            VALUES (:wid, :pid, 'tracked')
            ON CONFLICT (warehouse_id, product_id) DO UPDATE SET status = 'tracked'
        """), {"wid": data.warehouse_id, "pid": data.product_id})
        # Also promote global product status so it shows as tracked in company view
        await db.execute(text("""
            UPDATE products SET stock_status = 'tracked' WHERE id = :pid AND stock_status = 'untracked'
        """), {"pid": data.product_id})

    return mv


async def transfer_stock(db: AsyncSession, data, created_by: uuid.UUID):
    """Transfer stock between warehouses — uses maintained balances for validation."""
    balance = await get_balance(db, data.product_id, data.from_warehouse_id, for_update=True)
    if balance < data.qty:
        raise BusinessError(f"Insufficient stock: available {balance}")

    from app.schemas.stock import StockMovementCreate
    out = StockMovementCreate(
        product_id=data.product_id, warehouse_id=data.from_warehouse_id,
        movement_type=MovementType.transfer_out, qty=data.qty, note=data.note,
    )
    in_ = StockMovementCreate(
        product_id=data.product_id, warehouse_id=data.to_warehouse_id,
        movement_type=MovementType.transfer_in, qty=data.qty, note=data.note,
    )
    await record_movement(db, out, created_by)
    await record_movement(db, in_, created_by)
    await db.commit()


async def get_low_stock(db: AsyncSession, warehouse_id: uuid.UUID, threshold: Decimal = Decimal("5")):
    """Get products with stock <= threshold — uses maintained balances for O(1) query."""
    result = await db.execute(
        select(Product, StockBalance.qty)
        .join(StockBalance, Product.id == StockBalance.product_id)
        .where(
            StockBalance.warehouse_id == warehouse_id,
            StockBalance.qty >= 0,
            StockBalance.qty <= threshold,
        )
    )
    return result.all()


async def get_valuation(db: AsyncSession, warehouse_id: uuid.UUID):
    """Get inventory valuation — uses maintained balances for O(n) query (n = products with stock)."""
    result = await db.execute(
        select(
            func.sum(StockBalance.qty * Product.cost_price).label("cost_value"),
            func.sum(StockBalance.qty * Product.retail_price).label("retail_value"),
            func.count(Product.id).label("product_count"),
        )
        .join(StockBalance, Product.id == StockBalance.product_id)
        .where(StockBalance.warehouse_id == warehouse_id, StockBalance.qty > 0)
    )
    return result.one()