from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings


def _async_url(url: str) -> str:
    if url.startswith(("postgresql://", "postgres://")) and "+asyncpg" not in url:
        return url.replace("postgres://", "postgresql+asyncpg://", 1).replace(
            "postgresql://", "postgresql+asyncpg://", 1
        )
    return url


def _async_engine_settings(url: str) -> tuple[str, dict]:
    """Return (async url, connect_args) sanitizing libpq-only query params
    that asyncpg rejects (sslmode, sslrootcert, sslcert, sslkey, channel_binding)."""
    connect_args: dict = {}
    parts = urlsplit(url)
    if parts.query:
        query = parse_qsl(parts.query)
        sslmode = next((v for k, v in query if k == "sslmode"), None)
        if sslmode and sslmode not in ("disable", "allow", "prefer"):
            connect_args["ssl"] = "require"
        kept = [q for q in query if q[0] not in ("sslmode", "sslrootcert", "sslcert", "sslkey", "channel_binding")]
        url = urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(kept), parts.fragment))
    return url, connect_args


_async_url, _connect_args = _async_engine_settings(_async_url(settings.DATABASE_URL))
engine = create_async_engine(_async_url, connect_args=_connect_args, echo=False, pool_pre_ping=True)
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
