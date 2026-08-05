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

## Latest Session: 2026-08-04 (session 2)

### What Was Done

1. **Fixed admin warehouse-access bug blocking quotation confirm + shift open:**
   - Reported bug: confirming a quotation (عرض سعر) showed "ليس لديك صلاحية الوصول إلى هذا الفرع"; refreshing hid the open shift; opening a new shift in any branch returned "لديك وردية مفتوحة بالفعل في هذا الفرع"
   - Root cause: `verify_warehouse_access` (dependencies.py:112) only granted full access when `is_manager=True`, ignoring the `admin`/`manager` roles. `ammar`/`nada` are `role='admin'` with `is_manager=False`, so they were denied on any warehouse not explicitly in `user_warehouses` (e.g. البادروم الكبير, مخزن النواكل)
   - This 403 fired on `POST /stock/balance/bulk` (called by QuotationsPage `precheckAndConfirm` and by `/shifts/current`), so the quotation pre-check failed AND the current open shift (212effcc at معرض المؤمن) was invisible → "no open shift" → opening a duplicate was rejected
   - Fix: `verify_warehouse_access` now treats `is_manager OR role in ('admin', 'manager')` as full access — matching the existing `is_privileged` logic in shifts.py:97
   - Backend rebuilt + redeployed; verified: `/shifts/current` returns ammar's open shift; `balanceBulk` on unassigned warehouse returns OK (no 403)

2. **Previous session (2026-08-04): Purchase-flow E2E verification** — see below.

### Previous Session: 2026-08-04

### What Was Done

1. **Purchase-flow E2E verification (production):**
   - Confirmed the user's concern is **already handled**: the NewPOForm product picker shows "إضافة X كمنتج جديد" when a name has no match, which opens the full `ProductForm` modal that **requires category + subcategory** (validate blocks empty subcategory with "التصنيف الفرعي مطلوب", ProductForm.tsx:22) and collects unit, company, shelf, cost/retail/wholesale, barcode, stock toggle
   - Save path calls `productsApi.create` → `POST /products` → `create_product`, which **requires `subcategory_id`** (ProductCreate schema, product.py:31) — so new products always get a category
   - Found dead code: `POST /purchases/quick-add-product` (purchases.py:285) silently auto-assigns a default subcategory but the frontend **never calls it** — unused
   - Ran live E2E test on prod: create new product via `POST /products` → create PO referencing it → verify searchable → receive PO → stock movement recorded + cost_price updated (25.5) + promoted to `tracked` (global + per-warehouse) + `purchase_price_history` row → all confirmed in DB
   - **Found + fixed bug:** `GET /products/{product_id}/movements` returned raw ORM `StockMovement` objects → `PydanticSerializationError` 500. Rewrote to raw SQL + `dict(r._mapping)` (matches working `stock.py:list_movements` pattern), added `datetime` import at top of products.py
   - Backend image rebuilt + redeployed; movements endpoint re-tested OK
   - **All test data cleaned up** (product, PO, PO items, movement, warehouse status, price history, archive doc — 7 rows, verified 0 remnants)

### Previous Session: 2026-07-17

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

- **106 issues fixed** across all sessions, **0 remaining**
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
| `backend/app/api/routers/purchases.py` | `receive_purchase` (stock + cost_price + price history + archive), dead `quick-add-product` (never called by frontend) |
| `frontend/src/pages/purchases/PurchasesPage.tsx` | `NewPOForm` — picker with "إضافة كمنتج جديد" → ProductForm modal (requires category/subcategory) || `backend/app/api/routers/sales.py` | `get_sale` — returns `payment_history`, `returns_total`, `remaining` |
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
