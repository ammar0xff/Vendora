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

### Current State

- **98 issues fixed** across all sessions, **2 remaining** (both MEDIUM, both architectural — polymorphic `ref_id` without FK)
- `npx tsc --noEmit` passes clean
- Migration SQL ready: `fix_nullable_and_fks.sql` + `add_indexes.sql`

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

### Next Steps
1. **Run migration SQL on production:** `psql -U postgres -d egco -f backend/migrations/typed_fk_columns.sql`
2. **Docker rebuild** and production testing
3. **Close the 3 stale open shifts** (احمد الكوك, بلال عادل, عبد اللطيف الديب) if still open
4. **Fix router port forwarding** for 443 so HTTPS works externally
5. **For FCM:** Create Firebase project → download `google-services.json` → mount in Docker
6. **For Tauri auto-update:** Generate Ed25519 keypair (`npx tauri signer generate`), set pubkey in `tauri.conf.json`

### Relevant Files
| File | Role |
|------|------|
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
