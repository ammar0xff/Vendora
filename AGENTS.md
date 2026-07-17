# Memory File — AI Agent Context

> This file is the AI agent's persistent memory. It captures session context, decisions, state, and next steps. Updated at the end of each conversation session.

---

## Project Overview

EG-CO ERP — POS + Inventory + Accounting system for a plumbing/building supplies store.
- **Stack:** FastAPI (Python 3.13) · PostgreSQL 16 · React 19 · TypeScript · Tailwind CSS · Vite · Docker
- **Platforms:** Web PWA + Android (Capacitor) + Desktop (Tauri)
- **Deployment:** Docker Compose (db, backend, frontend:8080, nginxpm:80/443/81)
- **Domain:** `eg-co.duckdns.org`
- **Project root:** `C:\eg-co-erp\`
- **See also:** `SYSTEM.md` (architecture), `TASKS.md` (features/bugs)

### Default Logins
| User | Password | Role |
|------|----------|------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Admin |

---

## Latest Session: 2026-07-17

### What Was Done

1. **Full codebase audit (6 rounds, 98 issues fixed):**
   - Round 1-4: Race conditions (FOR UPDATE, advisory locks), Decimal precision, wallet balance, FK ondelete, Pydantic schemas, cancel/return logic, payment splits, offline sync, cashier perms, period lock, XSS, print auth
   - Round 5 (18 fixes): Indexes, constraints, Google Fonts CDN removal, CSP/HSTS, validation, `.gitignore`, sourcemaps
   - Round 6 (34 fixes): CORS cleanup, SECRET_KEY enforcement, `get_db` rollback, DrawerTxOut expanded, LIKE sanitization, helpers DRY refactor, ORM cascade delete, `afterprint` event, `SettingsUpdate` schema, `sale_payments` ORM model
   - Round 7 (2 fixes): POSPage decomposition (2294→1558 lines, 11 modal components extracted), SupplierForm saving state

2. **POSPage decomposition:**
   - Extracted 11 modal components into `frontend/src/pages/pos/modals/`:
     `HeldInvoicesModal`, `ReturnModal`, `DrawerEntryModal`, `CustomerDebtModal`, `LedgerModal`, `OpenShiftModal`, `HandoverModal`, `CloseShiftModal`, `RevenueDeliveryModal`, `SplitPaymentModal`, `PhoneModal`
   - POSPage.tsx reduced from 2294 → 1558 lines
   - TypeScript compiles clean

3. **DB structure audit + fix:**
   - Ran comprehensive audit of all 50 tables (FK constraints, orphan tables, missing indexes, broken FKs)
   - Found: duplicate FK on `drawer_transactions.category_id`, 53 FK columns without indexes, `typed_fk_columns.sql` never applied (rolled back every time)
   - Fixed `typed_fk_columns.sql` to be idempotent (removed `BEGIN/COMMIT` wrapper, added `IF NOT EXISTS` for constraint)
   - Created `cleanup_and_indexes.sql`: drops duplicate FK + adds 53 missing indexes
   - All 3 migrations applied to production: typed FKs now on `stock_movements` (370 rows backfilled), `drawer_transactions.ref_id` now has FK to `sales.id`

4. **Payroll data migration:**
   - Migrated 18 rows from old flat `hr_payroll` table → normalized `hr_payroll_periods` (2 rows) + `hr_payroll_entries` (18 rows)
   - Dropped old `hr_payroll` table
   - Dropped orphan `payroll_periods` and `payroll_entries` tables (0 rows, legacy)
   - `employees` table kept (0 rows but `report_generator.py` imports from legacy `models.py`)

5. **Tauri auto-update:**
   - Generated Ed25519 keypair on server via `cryptography` library
   - Private key saved at `C:\eg-co-erp\.tauri-update-key` on server (gitignored)
   - Public key `XuSBI9QvTk2pTHIWO6xBUvnwECUduW8irlRr97FzzKo=` set in `tauri.conf.json`

6. **SECRET_KEY:**
   - Replaced placeholder with real random 64-byte key in `docker-compose.yml`
   - Backend logs no longer show SECRET_KEY warning

### Current State

- **104 issues fixed** across all sessions, **0 remaining**
- `npx tsc --noEmit` passes clean
- All migrations applied to production ✓
- All 4 Docker containers healthy ✓
- SECRET_KEY set ✓
- Tauri updater keypair generated ✓
- Orphan tables cleaned up (3 dropped, 1 kept for legacy compat) ✓

### Key Decisions
- Square PWA icons auto-generated from uploaded logo (center-crop + resize to 192×192 and 512×512)
- Per-invoice payment tracking via `sale_id` on `customer_payments` — coexists with global customer balance model
- `sale.paid_amount` updated on each payment — enables `remaining = net_total - returns_total - paid_amount`
- Nginx Proxy Manager handles reverse proxy + SSL (no manual nginx config for certs)
- `DrawerTransaction.ref_id` → FK to `sales.id` (was untyped, always pointed to sales)
- `StockMovement` → typed FK columns `sale_id`, `purchase_id`, `operation_id` (original `ref_id`/`ref_type` preserved)
- `SaleStatus` enum: `draft`, `quotation`, `confirmed`, `returned`, `cancelled` — no `completed`
- All monetary calculations use `Decimal()`
- Redis rate limiter auto-fallback: uses Redis when `REDIS_URL` set, in-memory otherwise
- FCM push: lazy Firebase init, only when `FIREBASE_CREDENTIALS` env var set
- Migrations must be idempotent (no `BEGIN/COMMIT` wrappers, use `IF NOT EXISTS`)
- Orphan tables (`employees`, `payroll_periods`, `payroll_entries`, `hr_payroll`) left in DB for now — 0 rows on old tables, 18 on `hr_payroll`

### Next Steps
1. **Fix router port forwarding** for 443 so HTTPS works externally
2. **For FCM:** Create Firebase project → download `google-services.json` → mount in Docker
3. **Change SSH password** — `اهشك الجمبري` is exposed in this chat

### Relevant Files
| File | Role |
|------|------|
| `backend/migrations/typed_fk_columns.sql` | Typed FK columns (idempotent) |
| `backend/migrations/cleanup_and_indexes.sql` | Duplicate FK cleanup + 53 missing indexes |
| `backend/migrations/migrate_hr_payroll.sql` | Migrate 18 rows from flat hr_payroll to normalized tables |
| `backend/migrations/drop_orphan_tables.sql` | Drop legacy payroll_periods + payroll_entries tables |
| `backend/app/api/routers/settings.py` | `upload_logo` (PWA icon generation), `pwa_manifest` |
| `backend/app/api/routers/sales.py` | `get_sale` — returns `payment_history`, `returns_total`, `remaining` |
| `backend/app/api/routers/parties.py` | `add_payment` — accepts `sale_id`, updates `sales.paid_amount` |
| `backend/app/services/sale_service.py` | `partial_return_sale` / `return_sale` — track `returns_total` |
| `backend/app/models/customer_payment.py` | Added `sale_id` column |
| `backend/app/schemas/party.py` | `CustomerPaymentCreate` with optional `sale_id` |
| `frontend/src/pages/sales/SalesPage.tsx` | Clickable rows, detail modal with financial summary + pay |
| `frontend/src/api/endpoints.ts` | `addPayment` with optional `sale_id` |
| `backend/app/api/routers/ledger.py` | Daily ledger endpoint |
| `frontend/src/App.tsx` | `FaviconUpdater` — updates all icon types |
| `frontend/nginx.conf` | Rewrite rules for `/manifest.*` → backend |
| `docker-compose.yml` | 4 services: db, backend, frontend, nginxpm |
| `SYSTEM.md` | Complete system architecture reference |
| `TASKS.md` | Features & bugs tracking |
