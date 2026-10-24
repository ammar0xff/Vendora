"""Smoke test: /health reports liveness against DATABASE_URL.

Requires a reachable database (the compose stack or the CI service); there is
no in-memory fallback because the models use PostgreSQL-specific types.
"""
import os

import pytest
from httpx import ASGITransport, AsyncClient

from main import app

pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"), reason="DATABASE_URL not set"
)


@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        r = await c.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
