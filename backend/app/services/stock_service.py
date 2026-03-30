from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, case
from app.models.stock import StockMovement, MovementType
from app.models.product import Product
from app.core.exceptions import BusinessError, NotFoundError
import uuid


IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
OUT_TYPES = ("sale", "damage", "adjustment_out", "transfer_out")


async def get_balance(db: AsyncSession, product_id: uuid.UUID, warehouse_id: uuid.UUID) -> Decimal:
    result = await db.execute(
        select(
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
    )
    return result.scalar_one() or Decimal("0")


async def record_movement(db: AsyncSession, data, created_by: uuid.UUID, ref_id=None, ref_type=None) -> StockMovement:
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
    )
    db.add(mv)
    return mv


async def transfer_stock(db: AsyncSession, data, created_by: uuid.UUID):
    balance = await get_balance(db, data.product_id, data.from_warehouse_id)
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
        .where(balance_subq.c.qty <= threshold)
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
