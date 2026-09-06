from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings


def _async_url(url: str) -> str:
    if url.startswith(("postgresql://", "postgres://")) and "+asyncpg" not in url:
        return url.replace("postgres://", "postgresql+asyncpg://", 1).replace(
            "postgresql://", "postgresql+asyncpg://", 1
        )
    return url


engine = create_async_engine(_async_url(settings.DATABASE_URL), echo=False, pool_pre_ping=True)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
