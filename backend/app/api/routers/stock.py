from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from decimal import Decimal
from app.db.base import get_db
from app.schemas.stock import StockMovementCreate, StockMovementOut, StockBalance, TransferRequest
from app.models.stock import StockMovement
from app.models.warehouse import Warehouse
from app.services import stock_service
from app.dependencies import get_current_user, require_role
from app.models.user import User
import uuid

router = APIRouter(prefix="/stock", tags=["stock"])


@router.get("/warehouses", response_model=list[dict])
async def list_warehouses(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(select(Warehouse).where(Warehouse.is_active == True))
    return [{"id": str(w.id), "code": w.code, "name": w.name, "warehouse_type": w.warehouse_type} for w in result.scalars().all()]


@router.post("/warehouses")
async def create_warehouse(data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    w = Warehouse(code=data["code"], name=data["name"], warehouse_type=data.get("warehouse_type", "warehouse"))
    db.add(w)
    await db.commit()
    await db.refresh(w)
    return {"id": str(w.id), "code": w.code, "name": w.name, "warehouse_type": w.warehouse_type}


@router.put("/warehouses/{wh_id}")
async def update_warehouse(wh_id: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Warehouse).where(Warehouse.id == wh_id))
    w = result.scalar_one_or_none()
    if not w:
        from app.core.exceptions import NotFoundError
        raise NotFoundError()
    for k, v in data.items():
        setattr(w, k, v)
    await db.commit()
    return {"id": str(w.id), "code": w.code, "name": w.name}


@router.delete("/warehouses/{wh_id}", status_code=204)
async def delete_warehouse(wh_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(Warehouse).where(Warehouse.id == wh_id))
    w = result.scalar_one_or_none()
    if w:
        w.is_active = False
        await db.commit()


@router.post("/balance/bulk")
async def get_balance_bulk(warehouse_id: uuid.UUID, product_ids: list[uuid.UUID], db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """POST body: list of product UUIDs. Returns {product_id: qty}."""
    from sqlalchemy import func, case as sa_case
    if not product_ids:
        return {}
    IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
    result = await db.execute(
        select(
            StockMovement.product_id,
            func.coalesce(func.sum(sa_case(
                (StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty), else_=-StockMovement.qty
            )), 0).label("qty")
        )
        .where(StockMovement.warehouse_id == warehouse_id, StockMovement.product_id.in_(product_ids))
        .group_by(StockMovement.product_id)
    )
    return {str(row.product_id): float(row.qty) for row in result.all()}


@router.post("/balance/total")
async def get_total_balance_bulk(product_ids: list[uuid.UUID], db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Total stock across ALL warehouses. POST body: list of product UUIDs."""
    from sqlalchemy import func, case as sa_case
    if not product_ids:
        return {}
    IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
    result = await db.execute(
        select(
            StockMovement.product_id,
            func.coalesce(func.sum(sa_case(
                (StockMovement.movement_type.in_(IN_TYPES), StockMovement.qty), else_=-StockMovement.qty
            )), 0).label("qty")
        )
        .where(StockMovement.product_id.in_(product_ids))
        .group_by(StockMovement.product_id)
    )
    return {str(row.product_id): float(row.qty) for row in result.all()}


@router.get("/balance/breakdown/{product_id}")
async def get_balance_breakdown(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """Stock per warehouse for a single product."""
    from sqlalchemy import func, case as sa_case, text as sqlt
    IN_TYPES = ("opening_stock", "purchase", "return_in", "adjustment_in", "transfer_in")
    rows = await db.execute(sqlt("""
        SELECT w.name as warehouse_name, w.warehouse_type,
               COALESCE(SUM(CASE WHEN sm.movement_type IN ('opening_stock','purchase','return_in','adjustment_in','transfer_in')
                                 THEN sm.qty ELSE -sm.qty END), 0) as qty
        FROM warehouses w
        LEFT JOIN stock_movements sm ON sm.warehouse_id = w.id AND sm.product_id = :pid
        GROUP BY w.id, w.name, w.warehouse_type
        ORDER BY w.name
    """), {"pid": product_id})
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("/movements", response_model=StockMovementOut)
async def add_movement(data: StockMovementCreate, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    mv = await stock_service.record_movement(db, data, current_user.id)
    await db.commit()
    await db.refresh(mv)
    return mv


@router.delete("/movements", status_code=204)
async def reset_warehouse_stock(
    warehouse_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _=Depends(require_role("admin")),
):
    """Delete all stock movements for a warehouse (reset inventory)."""
    from sqlalchemy import text as sqlt
    await db.execute(sqlt("DELETE FROM stock_movements WHERE warehouse_id = :wid"), {"wid": warehouse_id})
    await db.execute(sqlt("DELETE FROM warehouse_product_status WHERE warehouse_id = :wid"), {"wid": warehouse_id})
    # Reset products that now have no movements anywhere back to untracked
    await db.execute(sqlt("""
        UPDATE products SET stock_status = 'untracked'
        WHERE id NOT IN (SELECT DISTINCT product_id FROM stock_movements)
    """))
    await db.commit()


@router.get("/movements")
async def list_movements(
    product_id: uuid.UUID | None = None,
    warehouse_id: uuid.UUID | None = None,
    limit: int = Query(100, le=500),
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    from sqlalchemy import text as sqlt
    conditions = ["1=1"]
    params: dict = {"limit": limit}
    if product_id:
        conditions.append("sm.product_id = :product_id")
        params["product_id"] = product_id
    if warehouse_id:
        conditions.append("sm.warehouse_id = :warehouse_id")
        params["warehouse_id"] = warehouse_id
    rows = await db.execute(sqlt(f"""
        SELECT sm.*, p.name as product_name, w.name as warehouse_name
        FROM stock_movements sm
        LEFT JOIN products p ON p.id = sm.product_id
        LEFT JOIN warehouses w ON w.id = sm.warehouse_id
        WHERE {' AND '.join(conditions)}
        ORDER BY sm.created_at DESC LIMIT :limit
    """), params)
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("/adjustment/bulk")
async def bulk_adjustment(data: list[StockMovementCreate], db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Bulk stock adjustment — equivalent to Qt's AddStockDialog / bulk_add_stock().
    Body: [{"product_id": "...", "warehouse_id": "...", "movement_type": "adjustment_in", "qty": 10, "note": "..."}]
    """
    for item in data:
        await stock_service.record_movement(db, item, current_user.id)
    await db.commit()
    return {"detail": f"{len(data)} movements recorded"}
async def transfer(data: TransferRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    await stock_service.transfer_stock(db, data, current_user.id)
    return {"detail": "Transfer completed"}


@router.get("/low-stock")
async def low_stock(warehouse_id: uuid.UUID, threshold: Decimal = Decimal("5"), db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await stock_service.get_low_stock(db, warehouse_id, threshold)
    return [{"product_id": str(p.id), "product_name": p.name, "current_qty": qty, "unit": p.unit} for p, qty in rows]


@router.get("/valuation")
async def valuation(warehouse_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    row = await stock_service.get_valuation(db, warehouse_id)
    return {"total_cost_value": row.cost_value or 0, "total_retail_value": row.retail_value or 0, "product_count": row.product_count or 0}
