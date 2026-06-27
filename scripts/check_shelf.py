import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select
from app.models.product import Product
from app.schemas.product import ProductOut

async def main():
    engine = create_async_engine('postgresql+asyncpg://postgres:postgres@db:5432/inventory_db')
    SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as db:
        r = await db.execute(select(Product).limit(1))
        p = r.scalar()
        out = ProductOut.model_validate(p)
        print('model:', repr(p.shelf_number))
        print('schema:', repr(out.shelf_number))
    await engine.dispose()

asyncio.run(main())
