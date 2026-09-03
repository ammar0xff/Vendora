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

## Latest Session: 2026-08-11

### What Was Done

1. **Jibble attendance CSV import (free tier, no paid API):**
   - User wants Jibble for attendance tracking but its **REST API requires a paid plan** — chose the free route: Jibble's timesheet **CSV export** → existing `POST /hr/attendance/import-csv`
   - Upgraded the importer (`backend/app/api/routers/hr.py`):
     - **Name-based matching**: Jibble exports `Member` full names (no codes). When no code column, matches `hr_employees.name` (case-insensitive, whitespace-stripped). Still supports `emp_code`/`employee code`/`uid`/`id` columns
     - **Jibble-style headers** mapped: `member`/`name`/`full name`/`person` → emp_name; `start time`/`begin` and `end time`/`finish` → check_in/check_out (plus existing `check in`/`clock in`/`in`); `date`/`work date`/`start date`/`end date`; `status`/`state`. Header normalization strips `_`, `(`, `)`
     - **Robust time parsing** `_parse_time()`: ISO with `Z`/`UTC`/offset, date+time formats, 12h `AM/PM` (`%I:%M %p`), 24h `%H:%M:%S`/`%H:%M`, and strict (Y|d/m) date formats
   - **Fixed latent bug:** the insert used a `created_by` column that doesn't exist on `hr_attendance` → `UndefinedColumnError` 500. Removed it (table has no such column)
   - Frontend: added hint under the CSV import card — "يدعم ملفات Jibble (Member / Date / Start time / End time) — يتطابق مع اسم الموظف تلقائياً"
   - Backend + frontend rebuilt + redeployed; `/health` OK
   - **Verified live:** imported a Jibble-style CSV (`Member,Date,Start Time,End Time,Duration`) for Ammar → `added:3`; rows stored with correct dates/times; also tested 12h `9:02:00 AM`/`5:31:00 PM` → parsed 09:02/17:31. All 4 test rows deleted afterward
   - `npx tsc --noEmit` passes

### Previous Session: 2026-08-09

### What Was Done

1. **Fixed "deleting empty subcategory shows 'related to products' error":**
   - Reported: subcategory "قطع 3/4 * 1/2" (المصرية الالمانية بولي) looked empty but deletion failed with "فشل الحذف — قد يكون التصنيف مرتبطاً بمنتجات"
   - **Root cause:** `delete_subcategory` counted **only active products** (`is_active = true`); when 0 → deleted the subcategory, but `products.subcategory_id` was `NOT NULL` + FK `RESTRICT` → **soft-deleted products (`is_active=false`) still held the FK and blocked the underlying DB delete**, even though the UI showed the subcategory as empty (ProductForm deletes hide inactive products)
   - Same bug in `delete_category` (counted active across joined subcategories)
   - **Fix:**
     - `backend/migrations/allow_null_subcategory.sql`: `ALTER TABLE products ALTER COLUMN subcategory_id DROP NOT NULL;` (applied to prod)
     - `models/product.py`: `subcategory_id` → `Mapped[uuid.UUID | None]` + `nullable=True`
     - `schemas/product.py`: `ProductOut.subcategory_id` → `Optional[uuid.UUID] = None`; `frontend/src/types.ts` `Product.subcategory_id` → `string | null`
     - `products.py` `delete_subcategory` + `delete_category`: keep the active-count guard (blocks when active products exist), but **before deleting, detach inactive products** — `UPDATE products SET subcategory_id = NULL WHERE subcategory_id = :id AND is_active = false` (subcategory) / joined through subcategories for category
   - Backend rebuilt + redeployed; `/health` OK
   - **Verified live:** DELETE `/api/subcategories/6e264538-...` (قطع 1/2 * 3/4, 0 active / 18 inactive) → **204**; confirmed subcategory gone (0 rows), 0 products still linked, 18 detached inactive products retained. Guard still works: DELETE on "قطع 1 بوصة" (23 active) → **400** and subcategory intact
   - `npx tsc --noEmit` passes (frontend types only; no frontend rebuild needed since detached products are inactive → never rendered)

### Previous Session: 2026-08-08

### What Was Done

1. **Quotation confirm now asks where the money goes (درج أو خزنة):**
   - User request: "لما أأكد عرض سعر عايز يسألني الفلوس تروح أي درج أو أي خزنة" — before confirming a quotation, prompt for the cash destination
   - Chosen UX (asked user): prompt **before** confirm; "drawer" = the **user's own open shift** in the quotation's warehouse
   - **Backend:**
     - `schemas/sale.py`: added `ConfirmQuotationRequest { destination: Literal["drawer","safe"] = "drawer", safe_id: uuid | None }`
     - `app/api/routers/sales.py:133`: `confirm-quotation` now accepts optional body → passes destination+safe_id to service
     - `sale_service.confirm_quotation(db, sale_id, user_id, destination, safe_id)`: after converting quote → confirmed sale (deducts stock + archives), records the money:
       - **drawer**: `DrawerTransaction(type=sale, amount=net_total, ref_id=sale.id, shift_id=<user's open shift in sale.warehouse_id>)` — errors if no open shift for user in that warehouse
       - **safe**: deposits into the selected safe — `safe_deposits` row (DEP-{seq}), increments `safes.balance`, `safe_transactions` (tx_type=deposit), plus an `ArchivedDocument(doc_type=safe_deposit)`
       - Credits are skipped (`if sale.net_total and not sale.is_credit`); `sale.paid_amount` set to net_total
     - Uses `text` now imported at module level in sale_service.py (was only local)
   - **Frontend:**
     - New `frontend/src/pages/quotations/QuoteDestinationModal.tsx` — shows quote amount, two option cards (الدرج=ورديتي المفتوحة / الخزنة) + safe selector; drawer disabled when user has no open shift; defaults to drawer when shift exists, safe otherwise
     - `quotations/QuotationsPage.tsx` — precheck passes → `setDestQuote(detail)` opens the destination modal instead of confirming directly; `confirmMut` now posts `{ destination, safe_id }` and only includes `safe_id` when destination==='safe' (important: empty string safe_id caused 422 uuid_parsing)
     - Fetches `current-shift` (shiftsApi.current) + `safes` when the modal is open; invalidates `safes`/`shifts` after confirm
   - Unit build germ: QuoteDestinationModal's `Modal` import was `../../../components/ui/Modal` (wrong depth for pages/quotations) → vite unresolved import → fixed to `../../components/ui/Modal`
   - **Verified live (Playwright + API):** drawer path → drawer tx (sale, 77ج) in ammar's shift 212effcc; safe path → safe balance 18672.50→18727.50 + DEP doc + safe_transactions entry; confirmed sales status confirmed + paid_amount=net_total. Both flows confirmed through the deployed UI (modal visible, options & amount correct). All test rows deleted incl. safe balance revert (18672.50 restored)

### Previous Session: 2026-08-06

### What Was Done

1. **Fixed product/category/subcategory `code` ordering — empty-string codes pushed to top:**
   - Reported: product "بكرة شيكرتون" got `code='1'` but did NOT appear first in the inventory list
   - Root causes (two bugs stacking):
     - **Client:** InventoryPage DataTable had `defaultSort={{ key: 'name', dir: 'asc' }}` (line 259) — re-sorted products alphabetically by name on load, overriding backend code order. Removed it; DataTable now respects the backend order by default (still sorts on header click)
     - **Server/DB:** editing a product without a code saved `code=''` (empty string) instead of NULL, because the edit form always sends `code`, and `update_product` uses `exclude_none=True` (keeps `''`). With `Product.code.asc().nullslast()`, `''` sorts **before** `'1'` and `nullslast()` only moves NULL to the end → every edited-but-uncoded product outranked بكرة شيكرتون
   - Fixes:
     - `products.py`: all code ordering now `func.nullif(code, '').asc().nullslast()` for products (line 162), categories (line 34), subcategories (line 119); same in `reports.py:90`; added `from sqlalchemy import func`
     - `products.py`: create/update for products, categories, subcategories normalize empty code → `None` (`code or None`)
     - DB backfill: `UPDATE products SET code = NULL WHERE code = ''` (4 rows) — done on prod
   - Verified live: `GET /products` returns بكرة شيكرتون (code `1`) first, uncoded products follow alphabetically
   - Also verified via Playwright: edit form for بكرة شيكرتون now shows code field = `1` (was empty before because the deployed frontend container predated the fixes — old bundle had `defaultSort` + stale edit form)
   - Both frontend and backend rebuilt + redeployed; `/health` OK

2. **Fixed "adding barcode doesn't save" — nested `<form>` bug:**
   - Reported: clicking إضافة in the barcode manager showed no saved barcode / no list update
   - Root cause: `ProductForm.tsx` wraps the whole modal in `<form>` (line 53), and `BarcodeManager.tsx` rendered its **own nested `<form onSubmit={handleAdd}>`** (line 63). Nested forms are invalid HTML — browsers drop the inner `<form>`, so the submit button never invoked `handleAdd` → **no POST ever fired** (confirmed via Playwright network log: only 1 input + submit button present, zero requests)
   - Fix (`frontend/src/components/ui/BarcodeManager.tsx`): replaced the inner `<form>` with a plain `<div>`; submit button changed to `type="button"` calling `handleAdd` directly; Enter key handled via `onKeyDown` with `e.stopPropagation()` + `e.preventDefault()` so it adds the barcode without submitting the outer product form
   - Verified live via Playwright: clicking إضافة now fires `POST /api/products/{id}/barcodes` and the new barcode (`7777777777777`) appears in the list immediately; test barcode deleted afterward (0 remaining)
   - Frontend rebuilt + redeployed; `npx tsc --noEmit` passes

2. **Added manual editable `code` (كود) to categories, subcategories, and products:**
   - User chose option: a short manual code that displays beside the name, is hand-editable, sorts categories/subcategories, and (for products) is searchable
   - **DB:** `backend/migrations/add_category_codes.sql` (already applied prior) + new `backend/migrations/add_product_codes.sql` — `ALTER TABLE products ADD COLUMN IF NOT EXISTS code VARCHAR(32) NULL;` + `CREATE INDEX idx_products_code`. Applied to prod (ALTER TABLE + CREATE INDEX OK)
   - **Backend:** `Product.code` column (String(32), index, nullable) in product.py; schemas add optional `code` to `ProductCreate`/`ProductUpdate`/`ProductOut`; `list_products` search now matches `name OR code` (`or_(Product.name.ilike, Product.code.ilike)`); categories/subcategories already ordered by `code.asc().nullslast()`
   - **Frontend:** `Product.code`/`ProductCreate.code` in types.ts (callers pass full form object → `code` auto-sent); ProductForm has a "الكود (اختياري)" input (also moved الشركة field up into the same 2-col grid, removed old duplicate); code badge shown next to product names in InventoryPage DataTable + POS CategoryCardBrowser cards, and in SettingsPage category/subcategory lists + their 4 modals (new/edit × category/subcategory) all accept code
   - Both images rebuilt + redeployed; `/health` OK
   - **Verified live via /api proxy:** create product with `code=X-77` → update to `Q-88` → `GET /products?search=Q-88` returns it → delete → 0 remnants
   - Note: `ProductUpdate` uses `exclude_none=True`, so clearing a code sends `''` (empty string) not NULL — acceptable
   - Reported: repeated `api/suppliers` 500 on `eg-co.duckdns.org`
   - Root cause: `create_supplier` (suppliers.py:46) used a raw `INSERT INTO suppliers (...)` **without an `id`** column, but `suppliers.id` has **no DB default** (only the ORM `default=uuid.uuid4`) → `NotNullViolationError` whenever adding a new supplier
   - Fix: added `gen_random_uuid()` for the `id` in the raw INSERT; verified create + soft-delete via API, then hard-deleted the test row
   - CSP: `eg-co.duckdns.org` now returns the fixed header (fonts.googleapis.com + fonts.gstatic.com allowed); the earlier report predates the deploy (browser cache) — header confirmed live on both domains
   - Backend image rebuilt + redeployed; `/health` OK; `GET /suppliers` OK; create + cleanup verified

### Previous Session: 2026-08-05

### What Was Done

1. **Fixed ledger 500 (`GET /reports/ledger`) + Google Fonts CSP:**
   - Reported: `api/reports/ledger` returned 500 on Dashboard/POS (with warehouse_id)
   - Root cause: `ledger.py` cash-drawer query used `dt.type IN ('sale','return')` but `drawer_transactions.type` is the `drawer_tx_type_enum` whose return value is **`return_`** (not `return`) → `InvalidTextRepresentationError` 500
   - Fix: ledger.py:214 → `'return_'`, ledger.py:226 → `r.type == 'return_'`; verified `OK nett=0`
   - Google Fonts: CSP in `frontend/nginx.conf` blocked `fonts.googleapis.com`/`fonts.gstatic.com` (stylesheets failed to load). Added both domains to `style-src`/`font-src`; verified header reflects the change
   - Both images rebuilt + redeployed; `/health` OK
   - Note: `api/shifts/current?warehouse_id=dc59d83b` 404 in the report is normal — ammar's open shift is at معرض المؤمن (122f5b3b), not معرض العبور

2. **Previous session (2026-08-04 session 2): admin warehouse-access fix** — see below.

### Previous Session: 2026-08-04 (session 2)

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

- **108 issues fixed** across all sessions, **0 remaining**
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
| `backend/migrations/allow_null_subcategory.sql` | `DROP NOT NULL` on products.subcategory_id so soft-deleted products can be detached before subcategory/category deletion (applied) |
| `backend/migrations/add_category_codes.sql` | Add `code` to categories/subcategories (idempotent, applied) |
| `backend/migrations/add_product_codes.sql` | Add `code` to products (idempotent, applied) |
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
| `frontend/src/pages/quotations/QuoteDestinationModal.tsx` | Destination picker (درج/خزنة) before quotation confirm |
| `backend/app/schemas/sale.py` | `ConfirmQuotationRequest` (destination/safe_id) |
| `frontend/src/App.tsx` | `FaviconUpdater` — updates all icon types |
| `frontend/nginx.conf` | Rewrite rules for `/manifest.*` → backend |
| `docker-compose.yml` | 4 services: db, backend, frontend, nginxpm |
| `SYSTEM.md` | Complete system architecture reference |
| `TASKS.md` | Features & bugs tracking |
