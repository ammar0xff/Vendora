FROM python:3.11-slim

WORKDIR /app

# Install system deps with retries and fallback to --fix-missing
RUN for i in 1 2 3; do \
      apt-get update --fix-missing && \
      apt-get install -y --fix-missing --no-install-recommends \
        gcc libpq-dev \
        libpango-1.0-0 libpangoft2-1.0-0 libpangocairo-1.0-0 \
        libcairo2 libgdk-pixbuf-2.0-0 libffi-dev shared-mime-info \
        fonts-noto fonts-noto-core && \
      break || sleep 10; \
    done && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
