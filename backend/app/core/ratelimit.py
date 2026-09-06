"""Rate limiter for brute-force protection.

Uses Redis when REDIS_URL is set (multi-worker safe), falls back to in-memory
for single-worker / development deployments."""
import logging
import os
import time

from fastapi import HTTPException, Request

logger = logging.getLogger(__name__)

_redis = None


def _get_redis():
    global _redis
    if _redis is not None:
        return _redis
    url = os.environ.get("REDIS_URL")
    if not url:
        return None
    try:
        import redis.asyncio as aioredis
        _redis = aioredis.from_url(url, decode_responses=True)
        logger.info("Redis rate limiter connected")
        return _redis
    except Exception as e:
        logger.warning(f"Redis connection failed, falling back to in-memory: {e}")
        return None


class RateLimiter:
    def __init__(self, max_requests: int = 5, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._attempts: dict[str, list[float]] = {}

    async def __call__(self, request: Request):
        key = f"rl:{request.client.host if request.client else 'unknown'}"
        r = _get_redis()

        if r:
            await self._check_redis(r, key)
        else:
            await self._check_memory(key)

    async def _check_redis(self, r, key: str):
        now = time.time()
        pipe = r.pipeline()
        pipe.zremrangebyscore(key, 0, now - self.window_seconds)
        pipe.zadd(key, {str(now): now})
        pipe.zcard(key)
        pipe.expire(key, self.window_seconds)
        results = await pipe.execute()
        count = results[2]
        if count > self.max_requests:
            retry_after = self.window_seconds
            raise HTTPException(
                status_code=429,
                detail=f"محاولات كثيرة جداً. حاول بعد {retry_after} ثانية",
                headers={"Retry-After": str(retry_after)},
            )

    async def _check_memory(self, key: str):
        now = time.time()
        window_start = now - self.window_seconds
        attempts = self._attempts.get(key, [])
        attempts = [t for t in attempts if t > window_start]
        self._attempts[key] = attempts
        if len(attempts) >= self.max_requests:
            retry_after = int(attempts[0] + self.window_seconds - now)
            raise HTTPException(
                status_code=429,
                detail=f"محاولات كثيرة جداً. حاول بعد {retry_after} ثانية",
                headers={"Retry-After": str(retry_after)},
            )
        attempts.append(now)
