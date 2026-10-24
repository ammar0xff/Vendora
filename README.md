# Vendora

[![CI/CD](https://github.com/ammar0xff/Vendora/actions/workflows/build.yml/badge.svg)](https://github.com/ammar0xff/Vendora/actions/workflows/build.yml)

Multi-branch ERP backend for a plumbing and building-supplies business: point of sale, inventory, sales and quotations,
purchasing, accounting, HR/payroll, and per-branch shift management.

> نظام إدارة متجر سباكة ومواد بناء متعدد الفروع

**This repository is currently backend-only.** The previous React frontend (web + Capacitor + Tauri) was removed while
the production refactoring plan ([docs/REFACTOR_PLAN.md](docs/REFACTOR_PLAN.md)) is executed; its history is preserved
in git and a rebuild is planned as Phase 7. Everything below describes the FastAPI backend and its live e2e suite.

---

## Features

| Area | Capabilities |
|------|--------------|
| **POS** | Multiple barcodes per product, discounts, credit sales, partial/full returns, split payments |
| **Sales & quotations** | Profit tracking, custom pricing, quotation-to-invoice conversion with drawer or safe destination |
| **Inventory** | O(1) balance reads from the maintained `stock_balances` table, per-warehouse isolation, inter-warehouse transfers, stocktaking, adjustments, reorder suggestions |
| **Purchasing** | Supplier invoices, purchase orders with receiving, price history per product, supplier price comparison |
| **Customers & suppliers** | Ledgers, balances and debts, per-invoice payments, credit limits, collections, aging reports |
| **Finance & accounting** | Profit & loss with expenses, general ledger, safes, customer wallets, cash flow, accounting periods with monthly closing |
| **HR & payroll** | Attendance (CSV import, ZK fingerprint device sync), payroll engine, approval workflow (draft → review → approve → pay), HTML payslips |
| **Shifts** | Per-branch shifts with opening/closing cash balances, manager sign-off, custodian (عهدة) handover, revenue delivery |
| **Archive & printing** | Every document archived automatically; HTML print templates for sales, purchases, inventory, shifts, dispatch, HR reports |
| **Multi-branch isolation** | Each branch sees only its own data; managers and admins see everything |
| **Permissions** | Role-based access plus per-feature permissions for every module |

## Tech stack

| Layer | Technology |
|-------|-----------|
| API | Python 3.12 (Docker image) / 3.13 (CI) - FastAPI - SQLAlchemy 2.0 (async) - Pydantic v2 |
| Database | PostgreSQL 16 |
| Infra | Docker Compose (db + backend) - Vercel deployment option (`backend/vercel.json`, `/api` rewrite) |
| Quality | Ruff - live-API e2e suite (pytest + httpx, 107 tests) - GitHub Actions CI |

## Getting started

Requirements: Docker with the Compose plugin.

```bash
git clone https://github.com/ammar0xff/Vendora.git
cd Vendora

docker compose up -d --build    # db (host :5433) + backend (host :8000)
python scripts/migrate.py       # apply tracked SQL migrations (idempotent)

curl http://localhost:8000/health
open http://localhost:8000/docs # interactive OpenAPI docs
```

On first boot PostgreSQL runs `data/sql/init_data.sql`, which seeds the default users, roles, and categories.

### Default login

| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Accountant (full permissions, `is_manager`) |

> Change the default passwords before any real use. Note the seeded admin intentionally does **not** carry the
> `finance` permission (separation of duties); grant it per-user if needed.

### Roles

| Role | Access |
|------|--------|
| Admin | Everything (except finance, unless granted) |
| Manager | Sales, inventory, reports, shifts, finance |
| Cashier | POS, sales, quotations |
| Storekeeper | Inventory, operations, purchasing |
| Accountant | Reports, finance, payroll |

## API notes for client developers

- **Auth** — JWT access tokens delivered as `HttpOnly` cookies (`access_token`) after `POST /auth/login`. Bearer
  headers also work for non-browser clients.
- **CSRF** — double-submit cookies: a readable `csrf_token` cookie is issued at login; mutating requests
  (POST/PUT/PATCH/DELETE) authenticated by cookie must echo it in an `X-CSRF-Token` header. Bearer-authenticated
  requests are exempt.
- **Errors** — business errors return Arabic `detail` messages with proper 4xx codes; validation errors are standard
  FastAPI 422 payloads.
- **Docs** — full endpoint inventory at `/docs` (OpenAPI).

## Testing

The e2e suite exercises the **live API** end to end (auth, POS sales, returns, purchases, inventory, payroll approval
flow, shifts/safes, permissions, print documents) and cleans up every row it creates via direct DB access.

```bash
cd e2e
python -m venv .venv && .venv/bin/pip install -r requirements.txt

E2E_API_BASE=http://localhost:8000 \
E2E_DATABASE_URL=postgresql://postgres:postgres@localhost:5433/inventory_db \
.venv/bin/python -m pytest -q
```

Both environment variables must point at the **same server** — the harness fails fast on a mismatch, and cleanup
deletes rows by id straight from the database. CI runs this suite against a fresh compose stack on every push.

## Repository structure

```
Vendora/
├── backend/                 # FastAPI service
│   ├── app/
│   │   ├── api/routers/     # 27 API routers + print/ sub-package
│   │   ├── core/            # config, security, roles, rate limiting
│   │   ├── models/          # SQLAlchemy ORM (all 52 tables)
│   │   ├── schemas/         # Pydantic v2 request/response schemas
│   │   ├── services/        # business logic (sale, stock, payroll, reports, ...)
│   │   └── middleware.py    # CSRF double-submit middleware
│   ├── migrations/          # SQL fragments referenced by scripts/migrate.py
│   ├── main.py              # FastAPI entry point
│   └── tests/               # unit tests
├── e2e/                     # live-API end-to-end suite (107 tests)
│   ├── api/                 # one file per domain
│   ├── tools/schema_drift.py# model ↔ live-DB drift checker
│   └── helpers.py           # httpx client, DB cleanup, CSRF echo
├── data/sql/                # init_data.sql seed, prod dumps
├── scripts/                 # migrate.py (28 tracked migrations), ZK sync, imports
├── docs/                    # REFACTOR_PLAN.md, audits
├── manage.py                # ops CLI (setup, deploy, backup, migrate, builds)
├── install.sh / deploy.sh   # fresh-server setup / SSH production deploy
├── docker-compose.yml       # db + backend
├── AGENTS.md                # AI-agent persistent memory / context
├── SYSTEM.md                # full system architecture reference
└── TASKS.md                 # features & bugs tracking
```

## Backend architecture

A single FastAPI app with **239 endpoints across 27 routers**, organized as thin routers → services → models.

- **Auth & security** — JWT `HttpOnly` cookies, CSRF double-submit, bcrypt, login rate limiting (proxy-aware),
  short-lived scoped print tokens for document views, sanitized `/health`.
- **Permissions** — `require_perm()` feature guards on every module; warehouse-level access checks.
- **Concurrency** — hot read-then-write paths (stock balances, safes, wallets, shifts) use `SELECT ... FOR UPDATE` +
  advisory locks; `stock_balances` rows update atomically in each movement's transaction.
- **Services** — `sale_service`, `stock_service`, `purchase_service`, `product_service`, `ledger_service`,
  `payroll_engine`/`payroll_service`, `shift_service`, `report_service`, `hr_reports`.
- **Migrations** — schema bootstrap via `Base.metadata.create_all` on startup, then tracked idempotent SQL migrations
  in `scripts/migrate.py` (recorded in `schema_migrations`, safe to re-run).
- **Monitoring** — audit log records every mutating action with old/new values.

## Operations

### manage.py

| Command | What it does |
|---------|--------------|
| `setup` | First-time setup (check Docker, build, start) |
| `deploy` | Update code, backup, migrate DB (safe) |
| `build` | Build Docker images without deploying |
| `deploy-fresh` | Wipe data and load `init_data.sql` |
| `stop` / `restart` / `status` | Service lifecycle + health |
| `backup` / `restore` | pg_dump backup to `backups/`, restore from file |
| `migrate` | Apply incremental SQL migrations (idempotent) |
| `logs` / `list-backups` | Tail logs, list backups |

### Fresh server setup

```bash
bash install.sh
python scripts/setup.py --domain your.domain.com
```

### Deployments

- **Docker Compose** (self-host): `db` + `backend` containers; `deploy.sh` pushes `master`, SSHes in, migrates,
  rebuilds, and health-checks.
- **Vercel** (serverless preview): `backend/vercel.json` rewrites `/api/*` → backend routes.

## CI/CD

`.github/workflows/build.yml` on every push/PR:

1. **Backend CI** — dependency install, app import check, ruff lint.
2. **E2E** — boots the real compose stack, applies migrations, runs the 107-test live-API suite.
3. **Manage check** — `manage.py` compiles and `--help` renders.
4. On **master/main push**: builds `vendora-backend:beta` and pushes to `ghcr.io`.
5. On **`v*` tags**: stable backend image to Docker Hub (when secrets are configured).

## Configuration

| Variable | Where | Purpose |
|----------|-------|---------|
| `DATABASE_URL` | `backend/.env` / compose | asyncpg connection string |
| `SECRET_KEY` | `backend/.env` / compose | JWT signing (must be random in production) |
| `APP_ENV` | `backend/.env` / compose | `production` enforces a real `SECRET_KEY` |
| `FIREBASE_CREDENTIALS` | compose | optional FCM service account (push) |

## Documentation

| File | Purpose |
|------|---------|
| `SYSTEM.md` | Full architecture: roles, tables, API, workflows |
| `TASKS.md` | Features and bug-fixing status |
| `AGENTS.md` | AI-agent persistent memory / session context |
| `docs/REFACTOR_PLAN.md` | Production refactoring plan (phases P0-P8) and progress |
| `docs/AUDIT.md` | Backend audit log |

## License

Proprietary - all rights reserved. No open-source license is granted.
