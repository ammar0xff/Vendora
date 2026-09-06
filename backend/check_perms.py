import asyncio

from sqlalchemy import text

from app.db.base import AsyncSessionLocal


async def check():
    async with AsyncSessionLocal() as db:
        r = await db.execute(text("SELECT username, permissions, is_manager FROM users"))
        for row in r:
            print(dict(row._mapping))

asyncio.run(check())
