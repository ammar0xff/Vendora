import asyncio, uuid
from datetime import datetime, date
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import text

async def test():
    engine = create_async_engine('postgresql+asyncpg://postgres:postgres@db:5432/inventory_db')
    SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as db:
        start = datetime(2026, 6, 24, 0, 0, 0)
        end   = datetime(2026, 6, 24, 23, 59, 59)
        params = {"start": start, "end": end, "wh_id": None}
        
        items = (await db.execute(text("""
            SELECT p.name, p.unit, si.unit_price as price,
                   SUM(si.qty) as qty,
                   SUM(si.qty * si.unit_price - si.discount) as total
            FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            JOIN products p ON p.id = si.product_id
            WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
              AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
            GROUP BY p.name, p.unit, si.unit_price
            ORDER BY total DESC
        """), params)).fetchall()
        
        print(f'Today [{start.date()}]: {len(items)} items')
        for r in items[:3]:
            print(f'  {r.name}: qty={r.qty}, price={r.price}, total={r.total}')

        # Also test with a specific warehouse
        params2 = {"start": start, "end": end, "wh_id": uuid.UUID('122f5b3b-9519-5b1e-a3fd-0ddacba7e157')}
        items2 = (await db.execute(text("""
            SELECT COUNT(*) as cnt FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
              AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        """), params2)).fetchone()
        print(f'Sales at معرض المؤمن today: {items2.cnt}')
        
        params3 = {"start": start, "end": end, "wh_id": uuid.UUID('895019af-e233-4d66-93d4-36d0f5079f38')}
        items3 = (await db.execute(text("""
            SELECT COUNT(*) as cnt FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
              AND (:wh_id IS NULL OR s.warehouse_id = :wh_id)
        """), params3)).fetchone()
        print(f'Sales at مخزن الحديد today: {items3.cnt}')
        
    await engine.dispose()

asyncio.run(test())
