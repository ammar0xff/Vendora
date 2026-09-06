# Vendora

Multi-branch ERP for a plumbing and building-supplies business: point of sale, inventory, sales and quotations,
purchasing, accounting, HR/payroll, and per-branch shift management.

> نظام إدارة متجر سباكة ومواد بناء متعدد الفروع

The same system is served three ways: a web PWA (with offline POS), a native Android app (Capacitor), and a desktop
app (Tauri). All user-facing text is Arabic with an RTL interface.

---

## Features

| Area | Capabilities |
|------|--------------|
| **POS** | Barcode scanning with multiple barcodes per product, cart, discounts, credit sales, partial/full returns, split payments, hold/resume bills |
| **Sales & quotations** | Profit tracking, custom pricing, quotation-to-invoice conversion with drawer or safe destination for the cash |
| **Inventory** | Balances computed from `stock_movements`, per-warehouse isolation, inter-warehouse transfers, stocktaking, adjustments, reorder suggestions, shelf numbers |
| **Purchasing** | Supplier invoices, purchase orders with receiving, price history per product, supplier price comparison |
| **Customers & suppliers** | Ledgers, balances and debts, per-invoice payments, credit limits, collections, aging reports |
| **Finance & accounting** | Profit & loss with expenses, general ledger, safes, customer wallets, cash flow, accounting periods with monthly closing |
| **HR & payroll** | Attendance (CSV import including Jibble exports, ZK fingerprint device sync), payroll engine, payroll approval workflow, payslips |
| **Shifts** | Per-branch shifts with opening/closing cash balances, manager sign-off, custodian (عهدة) handover records |
| **Archive & printing** | Every document is archived automatically and printed with professional HTML templates |
| **Multi-branch isolation** | Each branch sees only its own data; managers and admins see everything |
| **Permissions** | Role-based access plus per-feature permissions (view/create/edit/delete) for every module |
| **Offline POS** | Service worker caching, IndexedDB query cache, optimistic local bills and shifts, background sync with conflict detection |
| **Platform** | PWA installable, Android app, desktop app, Excel exports, audit log |

## Tech stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.12 (Docker image) / 3.13 (CI) - FastAPI - SQLAlchemy 2.0 (async) - Pydantic v2 |
| Frontend | React 19 - TypeScript 5.9 - Vite 8 - Tailwind CSS v4 - Zustand - TanStack Query |
| Database | PostgreSQL 16 |
| Mobile | Capacitor (Android) - PWA + WebView with native plugins |
| Desktop | Tauri v2 (Rust shell + WebView) |
| Infra | Docker Compose - Nginx Proxy Manager (reverse proxy + SSL) |
| Quality | Playwright E2E - Vitest - ESLint - GitHub Actions CI/CD |

## Getting started

Requirements: a recent OS with Docker and the Docker Compose plugin.

```bash
# 1. Clone and enter the directory
git clone https://github.com/ammar0xff/Vendora.git
cd Vendora

# 2. Build and start the full system (db + backend + frontend)
docker compose up -d --build

# 3. Check health
curl http://localhost:8080/api/health

# 4. Open the app
open http://localhost:8080
```

On first boot, PostgreSQL runs `data/sql/init_data.sql`, which seeds the default users, roles, and categories.

### Default login

| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | Admin (admin, all permissions) |
| `nada` | `changeme` | Accountant (full permissions, `is_manager`) |

> Change the default passwords on first login.

### Roles

| Role | Access |
|------|--------|
| Admin | Everything |
| Manager | Sales, inventory, reports, shifts |
| Cashier | POS, sales, quotations |
| Storekeeper | Inventory, operations, purchasing |
| Accountant | Reports, finance, payroll |

## Repository structure

```
Vendora/
├── backend/                 # FastAPI server
│   ├── app/
│   │   ├── api/
│   │   │   ├── routers/    # 27 API routers, print/ sub-package
│   │   │   ├── router.py   # central router registration
│   │   │   ├── deps.py     # shared dependencies (get_db, auth)
│   │   │   └── errors.py   # BusinessError + exception handlers
│   │   ├── core/           # config, security, roles, rate limiting
│   │   ├── models/         # SQLAlchemy ORM models
│   │   ├── schemas/        # Pydantic v2 request/response schemas
│   │   └── services/       # business logic layer
│   ├── alembic/            # scaffold only (schema = create_all + SQL migrations)
│   ├── migrations/         # idempotent SQL migrations
│   ├── main.py             # FastAPI entry point
│   └── Dockerfile
├── frontend/                # React + TypeScript
│   ├── src/
│   │   ├── pages/          # ~25 page modules
│   │   ├── api/            # Axios client + typed endpoints
│   │   ├── store/          # Zustand stores (auth, cart, offline, ...)
│   │   ├── components/     # shared UI (DataTable, Modal, ...)
│   │   └── utils/          # formatting, native shell, push, updates
│   ├── android/            # Capacitor Android project
│   ├── src-tauri/          # Tauri desktop project (Rust)
│   ├── e2e/                # Playwright end-to-end tests
│   ├── scripts/            # icon generation helpers
│   └── Dockerfile
├── data/sql/               # init_data.sql, prod_db.sql, DB dump
├── scripts/                # migrate.py, setup.py, data/import helpers, ZK sync
├── migrations/             # ad-hoc SQL migrations
├── docs/                   # AUDIT.md, AUDIT-frontend.md
├── manage.py               # ops CLI (setup, deploy, backup, migrate, builds)
├── install.sh              # one-time fresh-server setup
├── deploy.sh               # push + SSH production deploy
├── docker-compose.yml      # db, backend, frontend, nginxpm
├── AGENTS.md               # AI-agent persistent memory / context
├── SYSTEM.md               # full system architecture reference
└── TASKS.md                # features & bugs tracking
```

## Backend

The API is a single FastAPI app with `230+` endpoints grouped into 27 routers. The frontend's Nginx config proxies
`/api/*` to the backend and strips the prefix, so the app talks to the same origin.

- **Auth & security** - JWT access tokens with HttpOnly cookies, CSRF validation, password hashing (bcrypt), login rate
  limiting, short-lived print tokens for unauthenticated document views.
- **Permissions** - every module is guarded by role (`require_role`) and feature permissions (`require_perm`) for each of
  view/create/edit/delete.
- **Concurrency** - hot read-then-write paths (stock balances, safes, wallets, shifts) use `SELECT ... FOR UPDATE`.
- **Services** - `stock_service`, `sale_service`, `wallet_service`, `payroll_engine`, `shift_service`, `audit_service`,
  and `report_service` keep business logic out of the routers.
- **Printing** - the `print/` sub-package serves HTML documents for sales, purchases, archive, inventory, shifts, and
  dispatch orders with shared print CSS.
- **Migrations** - schema is created via `Base.metadata.create_all` on startup plus idempotent SQL migrations in
  `scripts/migrate.py` and `backend/migrations/` (no `BEGIN/COMMIT` wrappers, `IF NOT EXISTS` guards).
- **Monitoring** - `/health` returns service liveness; the audit log records every mutating action with old/new values.

## Frontend

- **State** - Zustand stores for auth, the POS cart, purchase cart, pending offline sales, local offline shift, and the
  offline sync queue.
- **Data fetching** - TanStack Query with an IndexedDB persister so reads survive reloads.
- **Offline POS** - the service worker caches the app shell and API responses; disconnected cashiers can still search
  locally, build bills, and open a local shift. The sync queue replays when connectivity returns and surfaces 409
  conflicts instead of failing silently.
- **Android (Capacitor)** - camera barcode scanning, Bluetooth receipt printing, biometric auth, local notifications,
  and file access; app icons are generated from the store logo at build time.
- **Desktop (Tauri v2)** - system tray, offline indicator, notifications, and an auto-updater fed by the backend
  `/api/updater` endpoint.
- **PWA** - installable manifest is generated from store settings (logo + name).

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
| `restore-append` | Load SQL without wiping |
| `migrate` | Apply incremental SQL migrations (idempotent) |
| `update-init` / `export-clean` | Snapshot DB to `init_data.sql` / export master data only |
| `logs` / `list-backups` | Tail logs, list backups |
| `build-apk` / `build-appimage` / `build-exe` | Build native packages |

On the server an `erp` shortcut is installed (`erp status`, `erp backup`, `erp restart`, `erp logs`).

### Fresh server setup

```bash
bash install.sh            # installs Docker + Compose, builds, systemd auto-start
python scripts/setup.py --domain your.domain.com
```

### Deployment

The stack runs as four containers: `db`, `backend` (internal :8000), `frontend` (host :8080), and `nginxpm` (host
80/443/81 for Nginx Proxy Manager). HTTPS and certificate renewal are handled by Nginx Proxy Manager.

- `deploy.sh` - pushes `master`, SSHes to the server, runs migrations, closes stale shifts, rebuilds, and health-checks.
- `manage.py deploy` - git pull + `docker compose up -d --build` with automatic backup and migration.
- Tagged releases (`v*`) trigger CI/CD that builds desktop installers, an Android APK, and Docker images.

## CI/CD

`.github/workflows/build.yml` runs on every push to `master`/`main` and on pull requests:

1. **Frontend CI** - `tsc --noEmit`, ESLint, Vitest unit tests, production build.
2. **Backend CI** - byte-compiles all Python, `ruff` lint.
3. **Manage check** - imports `manage.py` and renders `--help`.
4. On `v*` tags only: Tauri desktop builds (Linux / Windows / macOS), Android APK via Gradle, and Docker images push to
   Docker Hub.

## Testing

- **Unit** - Vitest; the offline queue store has its own test suite (`frontend/src/store/__tests__`).
- **E2E** - Playwright specs covering login, POS sale flow, inventory browsing, sales, and settings
  (`frontend/e2e/`). Run with `npm run test:e2e`.

## Configuration

| Variable | Where | Purpose |
|----------|-------|---------|
| `DATABASE_URL` | `docker-compose.yml` | asyncpg connection string |
| `SECRET_KEY` | `docker-compose.yml` | JWT signing / CSRF secrets |
| `FIREBASE_CREDENTIALS` | `docker-compose.yml` | optional FCM service account (push) |
| `VITE_API_URL` | `.github/workflows/build.yml` | backend base for native builds |

## Documentation

| File | Purpose |
|------|---------|
| `SYSTEM.md` | Full architecture: roles, tables, API, workflows |
| `TASKS.md` | Features and bug-fixing status |
| `AGENTS.md` | AI-agent persistent memory / session context |
| `docs/AUDIT.md` | Backend audit log |
| `docs/AUDIT-frontend.md` | Frontend audit log |

## License

Proprietary - all rights reserved. No open-source license is granted.