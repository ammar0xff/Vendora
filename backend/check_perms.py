import asyncio
from app.db.base import AsyncSessionLocal
from sqlalchemy import text

async def check():
    async with AsyncSessionLocal() as db:
        r = await db.execute(text("SELECT username, permissions, is_manager FROM users"))
        for row in r:
            print(dict(row._mapping))

asyncio.run(check())
