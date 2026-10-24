"""CSRF protection middleware."""
import uuid
from typing import Callable

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.status import HTTP_403_FORBIDDEN

# Paths that don't require CSRF protection
CSRF_EXEMPT_PATHS = {
    "/health",
    "/",
    "/docs",
    "/openapi.json",
    "/auth/login",
    "/auth/reauthenticate",
    "/auth/print-token",
    "/financial-categories",
    "/hr/payroll/calculate",
    "/products",
    "/products/",
    "/categories",
    "/subcategories",
    "/barcodes",
}


class CSRFMiddleware(BaseHTTPMiddleware):
    def __init__(self, app: FastAPI):
        super().__init__(app)
        self._tokens: dict[str, str] = {}

    def _get_token(self, request: Request) -> str:
        """Get or generate CSRF token for session."""
        session_id = request.cookies.get("csrf_session")
        if not session_id:
            session_id = str(uuid.uuid4())
        token = self._tokens.get(session_id)
        if not token:
            token = str(uuid.uuid4())
            self._tokens[session_id] = token
        return token

    def _validate_token(self, request: Request) -> bool:
        """Validate CSRF token from header against cookie."""
        # Check header
        header_token = request.headers.get("X-CSRF-Token")
        if not header_token:
            return False
        # Check cookie
        cookie_token = request.cookies.get("csrf_token")
        if not cookie_token:
            return False
        return header_token == cookie_token

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Skip CSRF for exempt paths (exact or prefix match)
        for exempt_path in CSRF_EXEMPT_PATHS:
            if request.url.path == exempt_path or request.url.path.startswith(exempt_path.rstrip('/') + '/'):
                response = await call_next(request)
                return response

        # Skip CSRF for safe methods
        if request.method in ("GET", "HEAD", "OPTIONS"):
            response = await call_next(request)
            return response

        # Validate CSRF token for mutating methods
        if not self._validate_token(request):
            return JSONResponse(
                status_code=HTTP_403_FORBIDDEN,
                content={"detail": "CSRF token missing or invalid"}
            )

        # Generate/refresh CSRF token for this session
        response = await call_next(request)
        
        # Set CSRF token cookie for next request
        session_id = request.cookies.get("csrf_session")
        if not session_id:
            session_id = str(uuid.uuid4())
        token = self._tokens.get(session_id)
        if not token:
            token = str(uuid.uuid4())
            self._tokens[session_id] = token

        response.set_cookie(
            key="csrf_token",
            value=token,
            httponly=True,
            secure=True,  # only over HTTPS
            samesite="strict",
            max_age=3600,
            path="/",
        )
        response.set_cookie(
            key="csrf_session",
            value=session_id,
            httponly=True,
            secure=True,
            samesite="strict",
            max_age=3600,
            path="/",
        )
        return response


def add_csrf_middleware(app: FastAPI):
    """Add CSRF middleware to FastAPI app."""
    app.add_middleware(CSRFMiddleware)