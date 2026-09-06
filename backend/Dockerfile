# syntax=docker/dockerfile:1
# ─── Builder: install Python wheels (compile deps live only here) ──────
FROM python:3.12-slim-bookworm AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /build

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
      gcc g++ libpq-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# ─── Runtime: only what the app needs at run time (no gcc/toolchain) ───
FROM python:3.12-slim-bookworm

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH=/app

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
      libpango-1.0-0 libpangoft2-1.0-0 libpangocairo-1.0-0 \
      libcairo2 libgdk-pixbuf-2.0-0 shared-mime-info \
      fonts-noto-core && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install/ /usr/local/

COPY . .

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]