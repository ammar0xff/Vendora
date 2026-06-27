import asyncio
from datetime import datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import text

async def test():
    engine = create_async_engine('postgresql+asyncpg://postgres:postgres@db:5432/inventory_db')
    SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as db:
        start = datetime(2026, 6, 24, 0, 0, 0)
        end = datetime(2026, 6, 24, 23, 59, 59)
        
        # Test WITHOUT warehouse filter (this was the bug)
        params = {"start": start, "end": end}
        items = (await db.execute(text("""
            SELECT p.name, p.unit, si.unit_price as price,
                   SUM(si.qty) as qty,
                   SUM(si.qty * si.unit_price - si.discount) as total
            FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            JOIN products p ON p.id = si.product_id
            WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
            GROUP BY p.name, p.unit, si.unit_price
            ORDER BY total DESC
        """), params)).fetchall()
        print(f'All warehouses: {len(items)} items')
        for r in items[:2]:
            print(f'  {r.name}: {r.qty} x {r.price} = {r.total}')

        # Test WITH warehouse filter
        params2 = {"start": start, "end": end, "wh_id": "122f5b3b-9519-5b1e-a3fd-0ddacba7e157"}
        items2 = (await db.execute(text("""
            SELECT p.name, COUNT(*) as cnt
            FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            WHERE s.status = 'confirmed' AND s.created_at BETWEEN :start AND :end
              AND s.warehouse_id = :wh_id::uuid
            GROUP BY p.name
        """), params2)).fetchall()
        print(f'Warehouse filter: {len(items2)} items')

    await engine.dispose()
    print('OK - no errors')

asyncio.run(test())
