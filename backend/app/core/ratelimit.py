"""Simple in-memory rate limiter for brute-force protection.

⚠️ In-memory only — does NOT work correctly across multiple workers/processes.
   For multi-worker deployments, replace with Redis-backed rate limiting."""
from collections import defaultdict
import time
from fastapi import HTTPException, Request


class RateLimiter:
    def __init__(self, max_requests: int = 5, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._attempts: dict[str, list[float]] = defaultdict(list)

    async def __call__(self, request: Request):
        key = request.client.host if request.client else "unknown"
        now = time.time()
        window_start = now - self.window_seconds
        self._attempts[key] = [t for t in self._attempts[key] if t > window_start]
        if len(self._attempts[key]) >= self.max_requests:
            retry_after = int(self._attempts[key][0] + self.window_seconds - now)
            raise HTTPException(
                status_code=429,
                detail=f"محاولات كثيرة جداً. حاول بعد {retry_after} ثانية",
                headers={"Retry-After": str(retry_after)},
            )
        self._attempts[key].append(now)
