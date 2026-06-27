import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select
from app.models.product import Product
from app.schemas.product import ProductOut

async def main():
    engine = create_async_engine('postgresql+asyncpg://postgres:postgres@db:5432/inventory_db')
    SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as db:
        # Find a product that has shelf_number
        r = await db.execute(select(Product).where(Product.shelf_number.isnot(None)).limit(3))
        ps = r.scalars().all()
        for p in ps:
            out = ProductOut.model_validate(p)
            print('name:', p.name, '| model shelf:', repr(p.shelf_number), '| schema shelf:', repr(out.shelf_number))
    await engine.dispose()

asyncio.run(main())
