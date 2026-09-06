# Vendora — System Blueprint

> Updated: 2026-09-06  
> Stack: FastAPI (Python 3.12 / CI 3.13) · PostgreSQL 16 · React 19 · TypeScript · Tailwind CSS v4 · Vite · Docker  
> Platforms: Web PWA (offline POS) · Android (Capacitor) · Desktop (Tauri v2)

---

## Table of contents

1. [Overview](#1-overview)
2. [Directory layout](#2-directory-layout)
3. [Database](#3-database)
4. [Backend — FastAPI](#4-backend--fastapi)
5. [Frontend — React](#5-frontend--react)
6. [Infrastructure](#6-infrastructure)
7. [Core workflows](#7-core-workflows)

---

## 1. Overview

A multi-branch ERP for a plumbing and building-supplies store. Arabic RTL UI throughout.

- **Backend** - FastAPI, SQLAlchemy 2.0 (async), idempotent SQL migrations
- **Frontend** - React 19, TypeScript, Vite, Tailwind CSS v4, Zustand
- **Database** - PostgreSQL 16
- **Android** - Capacitor (WebView + native plugins)
- **Desktop** - Tauri v2 (Rust shell + WebView)
- **PWA** - Service worker + IndexedDB persistence for offline POS

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
├── frontend/                   # React + TypeScript
│   ├── src/
│   │   ├── App.tsx             # routes + permission guards
│   │   ├── api/                # client.ts + endpoints.ts
│   │   ├── store/              # 9 Zustand stores
│   │   ├── pages/              # 25 page modules
│   │   ├── components/         # ui/ + layout/ + shared components
│   │   ├── hooks/              # useOnlineStatus
│   │   └── utils/              # format, native, pushNotifications, desktopUpdate
│   ├── android/                # Capacitor Android project
│   ├── src-tauri/              # Tauri v2 desktop project (Rust)
│   ├── e2e/                    # Playwright specs
│   ├── scripts/                # generate-icons.mjs
│   ├── public/                 # static assets
│   ├── nginx.conf              # reverse proxy + security headers
│   └── Dockerfile              # node:20 → nginx:alpine
├── data/sql/                   # init_data.sql, prod_db.sql, dump
├── scripts/                    # migrate.py, setup.py, import/data helpers, zk_sync.py
├── migrations/                 # ad-hoc SQL migrations
├── docs/                       # AUDIT.md, AUDIT-frontend.md
├── manage.py                   # ops CLI
├── install.sh                  # fresh-server setup
├── deploy.sh                   # push + SSH production deploy
├── docker-compose.yml          # 4 services: db, backend, frontend, nginxpm
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

## 5. Frontend — React

### API layer (`frontend/src/api/`)

| File | Purpose |
|------|---------|
| `client.ts` | Axios instance: base URL (`VITE_API_URL || '' + /api`), JWT interceptor, CSRF header |
| `endpoints.ts` | all typed endpoint functions |

### Stores (`frontend/src/store/`, Zustand)

| Store | Purpose |
|-------|---------|
| `auth.ts` | user, token, permissions, login/logout (persisted) |
| `app.ts` | active warehouse / branch |
| `pos.ts` | POS cart (items, quantities, discounts, notes) |
| `purchaseCart.ts` | purchase cart |
| `pendingSales.ts` | offline pending sales (persisted) |
| `localShift.ts` | offline local shift (persisted) |
| `offline.ts` | offline sync queue (persisted) |
| `offlineCache.ts` | local search cache |
| `queryPersister.ts` | TanStack Query IndexedDB persister |

### Pages (`frontend/src/pages/`, 25 modules)

Login, dashboard, POS, sales, quotations, payroll, admin, customers, operations (purchases/purchase-orders/
purchase-bill/transfers/dispatch grouped), inventory (stock, stocktaking, stock-adjustments, products), shifts,
reports (accounting/aging/cashflow), archive, expenses, safes, supplier-prices, suppliers, users, settings.

### Shared UI (`frontend/src/components/`)

`ui/` (Modal, DataTable, ConfirmDialog, FormField, SearchInput, BarcodeManager, ...), `layout/` (Sidebar, Layout),
`ErrorBoundary`, `OfflineBanner`, `OfflineSync`, `NativeShell`.

### PWA / offline

| File | Purpose |
|------|---------|
| `sw.ts` (via vite-plugin-pwa) | service worker: app-shell + API caching |
| `utils/format.ts` | number/currency formatting (signed currency strings) |
| `utils/native.ts` | native-shell capabilities (browser vs Capacitor vs Tauri) |

### Android (Capacitor) — `frontend/android/`

Camera barcode ↔ `@capacitor/camera`; Bluetooth printing ↔ `@capacitor-community/bluetooth-le`; biometric auth ↔
`@aparajita/capacitor-biometric-auth`; local/push notifications ↔ `@capacitor/local-notifications`,
`@capacitor/push-notifications`; status bar/filesystem ↔ `@capacitor/status-bar`, `@capacitor/filesystem`.
App icons are generated from the store logo by `scripts/generate-icons.mjs` in `prebuild:android`.

### Desktop (Tauri v2) — `frontend/src-tauri/`

System tray, offline indicator, notifications, auto-updater wired to the backend `/api/updater` feed.

---

## 6. Infrastructure

### Docker Compose (`docker-compose.yml`) — 4 services

| Service | Image | Host ports | Resource limits |
|---------|-------|-----------|-----------------|
| `db` | `postgres:16-alpine` | `5432` | 1 CPU, 512M |
| `backend` | built from `./backend` | (internal only) `8000` | 1 CPU, 1G |
| `frontend` | built from `./frontend` | `8080 → 80` | - |
| `nginxpm` | `jc21/nginx-proxy-manager` | `80`, `443`, `81` | - |

Backend connects via `DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/inventory_db`. `SECRET_KEY` is set
from compose. Optional `firebase-service-account.json` mounted when FCM push is used. Volumes: `pgdata`, `uploads_data`,
`npm_data`, `npm_letsencrypt`. `data/sql/init_data.sql` seeds the DB on first boot.

### Frontend `nginx.conf`

- reverse-proxies `/api/` → `backend:8000`, `/uploads/` → backend, `/manifest.json`/`/manifest.webmanifest` →
  `/settings/manifest.json`
- SPA fallback (`try_files ... /index.html`)
- security headers: CSP (assets + Google Fonts), HSTS, X-Frame-Options, nosniff, referrer policy
- `limit_req_zone login:5r/m` — 5 login requests/minute per IP

### Backend Dockerfile

`python:3.12-slim` + gcc/libpq for asyncpg + Pango/Cairo (WeasyPrint PDFs) + Noto fonts; runs as non-root `appuser`;
serves on `8000`.

### manage.py

CLI commmands: `setup`, `deploy`, `build`, `deploy-fresh`, `stop`, `restart`, `status`, `backup`, `restore`,
`restore-append`, `migrate`, `update-init`, `export-clean`, `logs`, `list-backups`, `build-apk`, `build-appimage`,
`build-exe`.

### install.sh / deploy.sh

`install.sh` — one-time setup on Ubuntu 20.04/22.04/24.04 or Debian 11/12: installs Docker + Compose plugin, builds
images, creates an `erp` systemd service (`erp status | backup | restore | restart | logs`).

`deploy.sh` — push local `master`, SSH to production, back up + migrate, rebuild, health-check.

### CI/CD (`.github/workflows/build.yml`)

| Job | Runs on | Gates |
|-----|---------|-------|
| `ci-frontend` | push/PR on master+main | npm ci, `tsc --noEmit`, ESLint, Vitest, production build |
| `ci-backend` | push/PR | byte-compile all `.py`, `ruff` lint |
| `ci-manage` | push/PR | `manage.py --help` renders |
| `build-desktop` | `v*` tags only | Tauri builds: Linux / Windows / macOS; upload + GitHub release |
| `build-android` | `v*` tags only | Gradle `assembleDebug` APK; upload + GitHub release |
| `build-docker` | `v*` tags only | `backend` + `frontend` images → Docker Hub |

### Playwright E2E (`frontend/e2e/`)

`login.spec.ts`, `pos.spec.ts`, `inventory.spec.ts`, `sales.spec.ts`, `settings.spec.ts`, shared `helpers.ts`.
Run with `npm run test:e2e` in `frontend/`.

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