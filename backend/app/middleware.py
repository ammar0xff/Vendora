"""CSRF protection middleware — validates Origin/Referer for all mutating requests."""
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.config import settings


class CSRFSecurityMiddleware(BaseHTTPMiddleware):
    """Validates Origin or Referer header on POST/PUT/PATCH/DELETE requests."""

    ALLOWED_ORIGINS: set[str] = set()

    async def dispatch(self, request: Request, call_next):
        if request.method in ("POST", "PUT", "PATCH", "DELETE"):
            origin = request.headers.get("origin") or ""
            referer = request.headers.get("referer") or ""

            # Build allowed list on first call
            if not self.ALLOWED_ORIGINS:
                self.ALLOWED_ORIGINS = set(settings.CORS_ORIGINS) | {
                    "capacitor://localhost",
                    "ionic://localhost",
                    "tauri://localhost",
                }

            # Allow if matched
            def _matches(allowed: str, value: str) -> bool:
                return allowed == "*" or value.startswith(allowed)

            if not any(_matches(o, origin) for o in self.ALLOWED_ORIGINS) and \
               not any(_matches(o, referer) for o in self.ALLOWED_ORIGINS):
                # Allow if no origin/referer (CLI tools, curl)
                if origin or referer:
                    raise HTTPException(
                        status_code=403,
                        detail="CSRF validation failed: invalid origin",
                    )

        return await call_next(request)
