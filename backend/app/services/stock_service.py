import uuid
from decimal import Decimal

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessError
from app.models.product import Product
from app.models.stock import IN_TYPES, MovementType, StockMovement


async def get_balance(db: AsyncSession, product_id: uuid.UUID, warehouse_id: uuid.UUID, for_update: bool = False) -> Decimal:
    if for_update:
        from sqlalchemy import text as sqlt
        exists = await db.execute(sqlt("SELECT 1 FROM products WHERE id=:pid FOR UPDATE"), {"pid": product_id})
        if not exists.scalar_one_or_none():
            from app.core.exceptions import NotFoundError
            raise NotFoundError(f"Product {product_id} not found")
    q = select(
        func.sum(
            case(
                (StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty),
                else_=-StockMovement.qty,
            )
        )
    ).where(
        StockMovement.product_id == product_id,
        StockMovement.warehouse_id == warehouse_id,
    )
    result = await db.execute(q)
    return result.scalar_one() or Decimal("0")


async def record_movement(db: AsyncSession, data, created_by: uuid.UUID, ref_id=None, ref_type=None,
                          sale_id: uuid.UUID = None, purchase_id: uuid.UUID = None,
                          operation_id: uuid.UUID = None) -> StockMovement:
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
        operation_id=operation_id,
    )
    db.add(mv)
    # Mark product as tracked in this specific warehouse when stock is recorded
    mt = str(data.movement_type).split('.')[-1]
    if mt in ("opening_stock", "purchase", "adjustment_in", "transfer_in", "return_in"):
        from sqlalchemy import text as sqlt
        await db.execute(sqlt("""
            INSERT INTO warehouse_product_status (warehouse_id, product_id, status)
            VALUES (:wid, :pid, 'tracked')
            ON CONFLICT (warehouse_id, product_id) DO UPDATE SET status = 'tracked'
        """), {"wid": data.warehouse_id, "pid": data.product_id})
        # Also promote global product status so it shows as tracked in company view
        await db.execute(sqlt("""
            UPDATE products SET stock_status = 'tracked' WHERE id = :pid AND stock_status = 'untracked'
        """), {"pid": data.product_id})
    return mv


async def transfer_stock(db: AsyncSession, data, created_by: uuid.UUID):
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
    balance_subq = (
        select(
            StockMovement.product_id,
            func.sum(
                case((StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty), else_=-StockMovement.qty)
            ).label("qty"),
        )
        .where(StockMovement.warehouse_id == warehouse_id)
        .group_by(StockMovement.product_id)
        .subquery()
    )
    result = await db.execute(
        select(Product, balance_subq.c.qty)
        .join(balance_subq, Product.id == balance_subq.c.product_id)
        .where(balance_subq.c.qty >= 0, balance_subq.c.qty <= threshold)
    )
    return result.all()


async def get_valuation(db: AsyncSession, warehouse_id: uuid.UUID):
    balance_subq = (
        select(
            StockMovement.product_id,
            func.sum(
                case((StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty), else_=-StockMovement.qty)
            ).label("qty"),
        )
        .where(StockMovement.warehouse_id == warehouse_id)
        .group_by(StockMovement.product_id)
        .subquery()
    )
    result = await db.execute(
        select(
            func.sum(balance_subq.c.qty * Product.cost_price).label("cost_value"),
            func.sum(balance_subq.c.qty * Product.retail_price).label("retail_value"),
            func.count(Product.id).label("product_count"),
        ).join(balance_subq, Product.id == balance_subq.c.product_id)
    )
    return result.one()
