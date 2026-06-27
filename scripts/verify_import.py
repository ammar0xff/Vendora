import asyncio, sys
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select
from app.models.product import Product, Subcategory

async def chk():
    engine = create_async_engine('postgresql+asyncpg://postgres:postgres@db:5432/inventory_db')
    SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as db:
        sr = await db.execute(select(Subcategory).where(Subcategory.name == 'جرد'))
        s = sr.scalar()
        r = await db.execute(select(Product).where(Product.subcategory_id == s.id).limit(3))
        for p in r.scalars():
            print('shelf:', repr(p.shelf_number), '| retail:', p.retail_price, '| wholesale:', p.wholesale_price, '| qty tracked:', p.stock_status)
    await engine.dispose()

asyncio.run(chk())
