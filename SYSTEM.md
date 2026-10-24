# Vendora — System Blueprint

> Updated: 2026-10-24  
> Stack: FastAPI (Python 3.12 / CI 3.13) · SQLAlchemy 2.0 async · PostgreSQL 16 · Docker  
> Status: Backend-only (frontend removed; rebuild planned — see docs/REFACTOR_PLAN.md P7)

---

## Table of contents

1. [Overview](#1-overview)
2. [Directory layout](#2-directory-layout)
3. [Database](#3-database)
4. [Backend — FastAPI](#4-backend--fastapi)
5. [API client integration](#5-api-client-integration)
6. [Infrastructure](#6-infrastructure)
7. [Core workflows](#7-core-workflows)

---

## 1. Overview

A multi-branch ERP for a plumbing and building-supplies store. Arabic RTL UI throughout.

- **Backend** - FastAPI, SQLAlchemy 2.0 (async), tracked idempotent SQL migrations
- **Database** - PostgreSQL 16
- **Testing** - live-API e2e suite (107 tests, pytest + httpx) with per-run DB cleanup
- **Clients** - any HTTP client; cookie auth with CSRF double-submit, or Bearer tokens

### Default seeds

Seeded from `data/sql/init_data.sql` on first database boot.

| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | `admin`, `is_manager=true`, all feature permissions |
| `nada` | `changeme` | `accountant`, `is_manager=true`, all feature permissions |

### Roles

| Role | Access |
|------|--------|
| Admin | Everything |
| Manager | Sales, inventory, reports, shifts |
| Cashier | POS, sales, quotations |
| Storekeeper | Inventory, operations, purchasing |
| Accountant | Reports, finance, payroll |

Permission enforcement is two-layered: a `role` column plus a per-user `permissions` array (feature list) and an
`is_manager` flag. `verify_warehouse_access` treats `is_manager` or `role in ('admin', 'manager')` as full access.

---

## 2. Directory layout

```
Vendora/
├── backend/                    # FastAPI server
│   ├── app/
│   │   ├── api/
│   │   │   ├── router.py       # registers all 27 feature routers
│   │   │   ├── deps.py         # get_db, get_current_user, pagination deps
│   │   │   ├── errors.py       # BusinessError + exception handlers
│   │   │   └── routers/        # 27 API routers + print/ sub-package
│   │   ├── core/               # config, security, roles, ratelimit, pagination, exceptions
│   │   ├── db/                 # engine + Base
│   │   ├── models/             # SQLAlchemy ORM models (20 files)
│   │   ├── schemas/            # Pydantic v2 schemas (17 files)
│   │   └── services/           # business-logic layer (8 services)
│   ├── alembic/                # Alembic scaffold (schema is `create_all` +
│   │                           #   idempotent SQL in scripts/migrate.py)
│   ├── migrations/             # idempotent SQL migrations
│   ├── tests/                  # backend tests
│   ├── main.py                 # FastAPI entry point
│   └── Dockerfile              # python:3.12-slim
├── e2e/                        # live-API e2e suite (pytest + httpx)
│   ├── api/                    # one test file per domain (20 files, 107 tests)
│   ├── helpers.py              # Api client (CSRF echo), DB cleanup, Registry
│   └── tools/schema_drift.py   # model ↔ live-DB drift checker
├── data/sql/                   # init_data.sql, prod_db.sql, dump
├── scripts/                    # migrate.py (28 tracked migrations), setup.py, zk_sync.py
├── docs/                       # REFACTOR_PLAN.md, audits
├── manage.py                   # ops CLI
├── install.sh                  # fresh-server setup
├── deploy.sh                   # push + SSH production deploy
├── docker-compose.yml          # 2 services: db, backend
├── AGENTS.md                   # AI-agent persistent memory
├── SYSTEM.md                   # this file
└── TASKS.md                    # features & bugs tracking
```

---

## 3. Database

All tables are SQLAlchemy `DeclarativeBase` models. The authoritative table list (from `backend/app/models/`):

| Table | Model file |
|-------|-----------|
| `users` | `models/user.py` |
| `warehouses` | `models/warehouse.py` |
| `categories`, `subcategories`, `products`, `product_barcodes` | `models/product.py` |
| `stock_movements` | `models/stock.py` |
| `supplier_prices` | `models/supplier_price.py` |
| `customers`, `suppliers` | `models/party.py` |
| `sales`, `sale_items` | `models/sale.py` |
| `sale_payments` | `models/sale_payment.py` |
| `customer_payments` | `models/customer_payment.py` |
| `purchase_orders`, `purchase_order_items` | `models/purchase.py` |
| `shifts`, `drawer_transactions` | `models/shift.py` |
| `expenses`, `expense_vendors` | `models/expense.py` |
| `financial_categories` | `models/financial_category.py` |
| `safes` | `models/safe.py` |
| `payment_wallets` | `models/payment_wallet.py` |
| `accounting_periods` | `models/period.py` |
| `hr_employees`, `hr_payroll_periods`, `hr_payroll_entries` | `models/payroll.py` |
| `archived_documents` | `models/archive.py` |
| `store_settings` | `models/settings.py` |
| `device_tokens` | `models/device_token.py` |

### Key design notes

- **Users & permissions** - `users` carries `role` (admin/manager/cashier/storekeeper/accountant), a `permissions`
  array (feature list), and `is_manager`. There is no `roles_permissions` table; feature access is enforced from the
  `permissions` array via `require_perm(feature)`, warehouse access via `verify_warehouse_access` (admins/managers
  pass everything).
- **Inventory** - balances are computed (query-driven) from `stock_movements`, not stored. Every movement
  (sale, purchase receipt, transfer, adjustment, stocktaking) is a `stock_movements` row. There are no separate
  `stock`, `stocktaking` or `stock_transfers` tables. `stock_movements.type` includes transfer/stocktaking/adjustment;
  typed FK columns (`sale_id`, `purchase_id`, `operation_id`) exist alongside `ref_id`/`ref_type`.
- **Products** - multiple barcodes per product (`product_barcodes`); a nullable manual `code` (SKU) used for ordering
  and search; `subcategory_id` is nullable so soft-deleted products can be detached before subcategory/category
  deletion.
- **Sales & quotations** - quotations live in `sales` with `status = quotation`; confirming turns them into
  `status = confirmed` and records where the cash lands. `SaleStatus`: `draft`, `quotation`, `confirmed`, `returned`,
  `cancelled`. Returns track `returns_total`; payments update `sales.paid_amount`, enabling
  `remaining = net_total - returns_total - paid_amount`.
  Note: the return value of the `drawer_tx_type` enum is `return_` (not `return`).
- **Money flows** - cash drawer transactions (`drawer_transactions`, keyed by `shift_id`), safe balances on `safes`
  (deposits/withdrawals update `safes.balance`; deposits also archive a `safe_deposit` document), and customer wallet
  balances on `payment_wallets` (sale payments can reference `wallet_id`).
- **Exact money** - all monetary columns are `Numeric(14, 2)` and every calculation uses `Decimal`.
- **HR & payroll** - attendance sources are ZKTeco badge devices (`scripts/zk_sync.py`) or CSV import with Jibble
  export support. Payroll is normalized into periods + entries (the old flat `hr_payroll` table was migrated out).
- **Archives** - every printable document is stored as HTML in `archived_documents`; `doc_type_enum` includes
  `sale_invoice`, `purchase_order`, `shift_report`, `inventory_report`, `safe_deposit`, `shift_handover`, `other`.

---

## 4. Backend — FastAPI

### Entry point (`backend/main.py`)

Creates the `FastAPI` app, runs `Base.metadata.create_all` at startup (schema is created in code, then extended with
idempotent SQL migrations from `scripts/migrate.py`/`backend/migrations/`), appends the `safe_deposit` enum value if
missing, mounts `/uploads` (and `/updates`), and registers the aggregated `router`. `/health` returns liveness.

### Core (`backend/app/core/`)

| File | Purpose |
|------|---------|
| `config.py` | `Settings` (pydantic-settings): `DATABASE_URL`, `SECRET_KEY`, CORS, upload dir |
| `security.py` | JWT (access + short-lived print tokens), bcrypt password hashing, CSRF header validation |
| `roles.py` | `require_role`, `require_perm(feature)`, `get_current_user` |
| `ratelimit.py` | login rate limiting (slowapi; falls back to in-memory without Redis) |
| `pagination.py` | shared pagination helpers |
| `exceptions.py` | `BusinessError`, `NotFoundError`, handler wiring |

### Routers (`backend/app/api/routers/`, 27 + `print/`)

| Router | Prefix | Scope |
|--------|--------|-------|
| `auth.py` | `/auth` | login/logout/refresh, `/me`, change password, roles, print-token, reauthenticate |
| `users.py` | `/users` | user CRUD, password reset |
| `products.py` | `/products` | product/category/subcategory CRUD, search, barcodes |
| `stock.py` | `/stock` | balances, movements, adjustments, stocktaking |
| `sales.py` | `/sales` | sale CRUD, returns, payments, quotation confirm |
| `shifts.py` | `/shifts` | shift lifecycle + per-shift transaction reports |
| `reports.py` | `/reports` | profit/loss, stock reports, aging |
| `ledger.py` | `/reports/ledger` | daily ledger (from/to, warehouse) |
| `parties.py` | `/customers`, `/suppliers` | customer & supplier CRUD, ledgers, balances, payments |
| `purchases.py` | `/purchases` | purchase orders, receiving, supplier invoices |
| `operations.py` | `/operations` | dispatch orders, goods receipts, stock requests |
| `finance.py` | `/financial-categories`, `/financial-ledger`, `/audit-log`, `/permissions` | financial categories, ledger, audit log, user permission grants |
| `expenses.py` | (no prefix) | expense CRUD + approval |
| `safes.py` | `/safes` | safe CRUD, deposits/withdrawals |
| `wallets.py` | `/wallets` | customer wallets + transactions |
| `payroll.py` | `/payroll` | payroll periods/entries, approval, payslips |
| `hr.py` | `/hr` | employees, attendance (CSV import incl. Jibble), devices |
| `periods.py` | `/periods` | accounting periods + closing |
| `archive.py` | `/archive` | archived documents, print/view |
| `settings.py` | `/settings` | store settings, logo upload, PWA manifest, product options |
| `admin_overview.py` | `/admin` | admin dashboard aggregate |
| `collections.py` | `/collections` | debt collections |
| `suppliers.py` | `/suppliers` | supplier CRUD |
| `export.py` | `/export` | Excel export for all tables |
| `notifications.py` | `/notifications` | FCM device tokens + push dispatch |
| `updater.py` | `/updater` | desktop updater feed + `/updates` download |
| `print_router.py` | (re-export) | historical alias into `print/` |

### Print sub-package (`backend/app/api/routers/print/`)

The former 1329-line `print_router.py` was split into a modular sub-package mounted at `/print`:

| File | Scope |
|------|-------|
| `__init__.py` | shared print CSS + sub-router registration |
| `sale.py` | sale invoice, quotation, return |
| `purchase.py` | purchase order, supplier invoice |
| `archive.py` | archived documents |
| `inventory.py` | stocktaking, balance sheet |
| `shift.py` | shift report, handover (عهدة) |
| `dispatch.py` | dispatch-order documents |

### Models, schemas, services

- 20 model files, 17 schema files, 8 service files (`stock_service`, `sale_service`, `wallet_service`,
  `shift_service`, `payroll_engine`, `report_service`, `audit_service`, `auth_service`).
- Backend tests live in `backend/tests/`.

---

## 5. API client integration

The previous React frontend was removed (history preserved in git; rebuild planned as
[REFACTOR_PLAN](docs/REFACTOR_PLAN.md) P7). Any HTTP client integrates as follows:

- **Base URL** — direct `http://host:8000` (compose) or `https://<app>/api/*` (Vercel rewrite strips `/api`).
- **Auth** — `POST /auth/login {username, password}` sets an `HttpOnly` `access_token` cookie and returns the JWT.
  Cookie-based clients must send **CSRF double-submit**: echo the readable `csrf_token` cookie in an `X-CSRF-Token`
  header on every POST/PUT/PATCH/DELETE. Bearer-token clients (`Authorization: Bearer <jwt>`) are CSRF-exempt.
- **OpenAPI** — `/docs` renders the live endpoint inventory (239 endpoints, 27 routers).
- **Errors** — business errors are 4xx with Arabic `detail`; validation errors are FastAPI 422 payloads.
- **Printing** — `/print/*` endpoints return self-contained HTML documents; short-lived scoped print tokens
  (`/auth/print-token`) allow unauthenticated document views.
- **Reference client** — `e2e/helpers.py::Api` is a minimal working example (login, cookie jar, CSRF echo).

---

## 6. Infrastructure

### Docker Compose (`docker-compose.yml`) — 2 services

| Service | Image | Host ports | Resource limits |
|---------|-------|-----------|-----------------|
| `db` | `postgres:16-alpine` | `5433 → 5432` | 1 CPU, 512M |
| `backend` | built from `./backend` | `8000` | 1 CPU, 1G |

Backend connects via `DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/inventory_db`. `SECRET_KEY` is set
from compose. Optional `firebase-service-account.json` mounted when FCM push is used. Volumes: `pgdata`, `uploads_data`.
`data/sql/init_data.sql` seeds the DB on first boot. In production, put the backend behind your own reverse proxy for
TLS (the login rate limiter honors `X-Forwarded-For`).

### Backend Dockerfile

`python:3.12-slim` + gcc/libpq for asyncpg + Pango/Cairo (WeasyPrint PDFs) + Noto fonts; runs as non-root `appuser`;
serves on `8000`.

### manage.py

CLI commmands: `setup`, `deploy`, `build`, `deploy-fresh`, `stop`, `restart`, `status`, `backup`, `restore`,
`restore-append`, `migrate`, `update-init`, `export-clean`, `logs`, `list-backups`.

### install.sh / deploy.sh

`install.sh` — one-time setup on Ubuntu 20.04/22.04/24.04 or Debian 11/12: installs Docker + Compose plugin, builds
images, creates an `erp` systemd service (`erp status | backup | restore | restart | logs`).

`deploy.sh` — push local `master`, SSH to production, back up + migrate, rebuild, health-check.

### CI/CD (`.github/workflows/build.yml`)

| Job | Runs on | Gates |
|-----|---------|-------|
| `ci-backend` | push/PR | deps install, app import check, `ruff` lint |
| `ci-e2e` | push/PR | boots the compose stack, runs migrations, live-API suite (107 tests) + unit smoke |
| `ci-manage` | push/PR | `manage.py --help` renders |
| `beta-docker` | master/main push | `vendora-backend:beta` → ghcr.io |
| `build-docker` | `v*` tags only | backend image → Docker Hub (when secrets configured) |

### Live-API e2e (`e2e/`)

20 test files covering auth, POS sales, returns, quotations, purchases, inventory, payroll approval flow, shifts and
safes, expenses, finance, permissions, print documents, and security. Every run registers created ids and deletes them
from the DB at teardown. Run with `E2E_API_BASE` + `E2E_DATABASE_URL` (both must point at the same server).

---

## 7. Core workflows

### POS sale cycle

1. Cashier opens a shift → `shifts.status = open`
2. Selects warehouse
3. Searches any product by name or code (300ms debounced) or scans barcode (keyboard/camera + multi-barcode)
4. Adds to `pos` cart
5. Optional customer, discount, split payment (cash/card/credit, wallet)
6. Checkout → `sale_service.create_sale()` with `FOR UPDATE` on stock balance
7. Prints invoice via `/print/sale/{id}`
8. If offline: bill lands in `pendingSales` + offline sync queue; replays when connectivity returns, surfacing 409 conflicts

### Purchase cycle

1. Create Purchase Order (existing product picker, or "create new product" flow that requires category/subcategory)
2. Receive the shipment → `qty_received` updated, stock increases, `cost_price` updated, `purchase_price_history`
   logged, product promoted to `tracked`
3. Supplier invoice settles the account

### Inventory cycle

- Every movement (sale, purchase, transfer, adjustment, stocktaking) is written to `stock_movements`
- Balances are computed (`SUM ... WHERE warehouse_id = ?`); `FOR UPDATE` prevents checkout races
- Per-warehouse isolation via `verify_warehouse_access` (> full access for admins/managers)

### Shift cycle

1. Manager or storekeeper opens a shift with `opening_balance`
2. All financial transactions are linked to `shift_id`
3. On close: `closing_balance`, system-computed difference, shift report + handover (عهدة) print

### Quotation → invoice

1. Quote created with items and pricing
2. Confirm flow asks where the cash lands: **drawer** (the user's open shift in the quote's warehouse) or **safe**
   (selected safe → deposit + archived doc)
3. Stock pre-check runs before confirm; confirmation deducts stock, archives, records money

### Offline POS

1. Service worker caches app shell + API responses
2. TanStack Query persists reads via IndexedDB
3. Disconnected: local search cache, local bill in `pendingSales`, local shift in `localShift`
4. Reconnected: `offline` sync queue replays; 409 conflicts surfaced as errors

### Financial reports

- Profit & loss: gross sales - COGS - expenses
- Ledger: classified financial movements (`/reports/ledger`)
- Aging: customers/suppliers 0-30-60-90+ days
- Cash flow: inflow/outflow/net
- Accounting periods: monthly close locking