"""Product Collections — packages of multiple products sold as one unit."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db.base import get_db
from app.dependencies import get_current_user
from app.models.user import User
import uuid

router = APIRouter(prefix="/collections", tags=["collections"])


@router.get("")
async def list_collections(db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    rows = await db.execute(text("""
        SELECT pc.*,
               json_agg(json_build_object(
                 'id', ci.id, 'product_id', ci.product_id,
                 'qty', ci.qty, 'product_name', p.name, 'unit', p.unit,
                 'retail_price', p.retail_price, 'cost_price', p.cost_price
               ) ORDER BY p.name) FILTER (WHERE ci.id IS NOT NULL) as items
        FROM product_collections pc
        LEFT JOIN collection_items ci ON ci.collection_id = pc.id
        LEFT JOIN products p ON p.id = ci.product_id
        WHERE pc.is_active = true
        GROUP BY pc.id ORDER BY pc.name
    """))
    return [dict(r._mapping) for r in rows.fetchall()]


@router.post("", status_code=201)
async def create_collection(data: dict, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    r = await db.execute(text("""
        INSERT INTO product_collections (name, description, retail_price, wholesale_price)
        VALUES (:name, :desc, :retail, :wholesale) RETURNING *
    """), {"name": data["name"], "desc": data.get("description", ""),
           "retail": data.get("retail_price", 0), "wholesale": data.get("wholesale_price", 0)})
    coll = dict(r.fetchone()._mapping)
    for item in data.get("items", []):
        await db.execute(text("""
            INSERT INTO collection_items (collection_id, product_id, qty)
            VALUES (:cid, :pid, :qty)
        """), {"cid": coll["id"], "pid": item["product_id"], "qty": item["qty"]})
    await db.commit()
    return coll


@router.put("/{cid}")
async def update_collection(cid: uuid.UUID, data: dict, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    await db.execute(text("""
        UPDATE product_collections SET name=:name, description=:desc,
        retail_price=:retail, wholesale_price=:wholesale WHERE id=:id
    """), {"name": data["name"], "desc": data.get("description", ""),
           "retail": data.get("retail_price", 0), "wholesale": data.get("wholesale_price", 0), "id": cid})
    # Replace items
    await db.execute(text("DELETE FROM collection_items WHERE collection_id=:id"), {"id": cid})
    for item in data.get("items", []):
        await db.execute(text("""
            INSERT INTO collection_items (collection_id, product_id, qty)
            VALUES (:cid, :pid, :qty)
        """), {"cid": cid, "pid": item["product_id"], "qty": item["qty"]})
    await db.commit()
    return {"ok": True}


@router.delete("/{cid}")
async def delete_collection(cid: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    await db.execute(text("UPDATE product_collections SET is_active=false WHERE id=:id"), {"id": cid})
    await db.commit()
    return {"ok": True}


@router.get("/{cid}/availability")
async def collection_availability(cid: uuid.UUID, warehouse_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    """How many of this collection can be assembled from current stock in warehouse."""
    items = await db.execute(text("""
        SELECT ci.product_id, ci.qty as needed, p.name, p.stock_status,
               COALESCE((
                 SELECT SUM(CASE WHEN sm.movement_type IN ('opening_stock','purchase','return_in','adjustment_in','transfer_in')
                                 THEN sm.qty ELSE -sm.qty END)
                 FROM stock_movements sm
                 WHERE sm.product_id = ci.product_id AND sm.warehouse_id = :wid
               ), 0) as available
        FROM collection_items ci
        JOIN products p ON p.id = ci.product_id
        WHERE ci.collection_id = :cid
    """), {"cid": cid, "wid": warehouse_id})
    rows = [dict(r._mapping) for r in items.fetchall()]
    if not rows:
        return {"can_make": 0, "items": []}
    # How many collections can we make?
    can_make = None
    for r in rows:
        if r["stock_status"] == "untracked":
            continue  # untracked = unlimited
        possible = int(float(r["available"]) / float(r["needed"])) if float(r["needed"]) > 0 else 0
        if can_make is None or possible < can_make:
            can_make = possible
    return {"can_make": can_make if can_make is not None else 999, "items": rows}
