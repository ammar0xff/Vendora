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

## Latest Session: 2026-06-27

### What Was Done

1. **PWA icons fixed (PWABuilder validation):**
   - `upload_logo` endpoint (`settings.py`) now uses Pillow to center-crop uploaded image to square → generates `logo-192x192.png` and `logo-512x512.png`
   - `pwa_manifest` serves generated icons with proper `sizes: "192x192"` and `sizes: "512x512"` (was `sizes: "any"`)
   - Existing ibb.co logo (243×184) downloaded, cropped to square, resized → stored locally
   - DB `logo_url` updated from external URL to `/uploads/logo.png`

2. **Per-invoice partial payment & tracking:**
   - **DB:** `customer_payments` got `sale_id` (FK → sales), `sales` got `returns_total` + `last_paid_at`
   - **Model/Schema:** `CustomerPayment` model + `CustomerPaymentCreate` schema updated with optional `sale_id`
   - **`POST /customers/{id}/payments`** (`parties.py`): optional `sale_id` → updates `sales.paid_amount` + `last_paid_at`
   - **Return sales** (`sale_service.py`): `partial_return_sale` and `return_sale` now track `returns_total`
   - **`GET /sales/{id}`** (`sales.py`): returns `payment_history`, `returns_total`, `remaining = net_total - returns_total - paid_amount`
   - **SalesPage.tsx:** clickable rows → detail modal with items, financial summary (net/paid/returned/remaining), payment history list, "تسديد" form with amount + note

3. **Skills installed globally** (NO Node.js needed):
   - 66 skills from `farmage/opencode-skills` (fastapi-expert, react-expert, typescript-pro, postgres-pro, python-pro, sql-pro, api-designer, database-optimizer, devops-engineer, debugging-wizard, code-reviewer, fullstack-guardian, secure-code-guardian, docker, nginx, and 50+ others)
   - 7 skills from `anthropics/skills` (frontend-design, skill-creator, webapp-testing, pdf, xlsx, docx, brand-guidelines)
   - 13 workflow commands (common-ground, discovery, planning, execution, retrospectives)
   - Location: `~/.config/opencode/skills/` and `~/.config/opencode/command/`

### Current State

#### PWA Icons
- Manifest returns `logo-192x192.png` (192×192) and `logo-512x512.png` (512×512) — both square
- PWABuilder validation should now pass (no more "sizes must be 192x192 or larger" error)

#### Open Shifts for معرض المؤمن (warehouse `122f5b3b-9519-5b1e-a3fd-0ddacba7e157`)
| Shift ID | User | Opening | State |
|----------|------|---------|-------|
| `5cd4b278` | عبد اللطيف الديب | 0 | No transactions |
| `19e4715b` | احمد الكوك | 4,076 | Has yesterday's txns (net +185) |
| `a770d0db` | بلال عادل | 4,230 | No transactions |
| `a282f4a7` | داليا السيد | 70 | 1 cash sale (536) — correct active shift |

- **Last closed shift:** `7c0b1b11` (بلال عادل, closed 24 Jun, closing_balance=11670, next_day_drawer=70)

#### Blocked
- **ZTE router intercepts port 443** — SSL certificate for `eg-co.duckdns.org` is valid externally; user needs to forward port 443 on their ZTE router and change router admin HTTPS port to avoid conflict

### Key Decisions
- Square PWA icons auto-generated from uploaded logo (center-crop + resize to 192×192 and 512×512)
- Per-invoice payment tracking via `sale_id` on `customer_payments` — coexists with global customer balance model
- `sale.paid_amount` updated on each payment — enables `remaining = net_total - returns_total - paid_amount`
- Full skills collection installed (73 skills) — agent has domain knowledge for the entire tech stack
- Nginx Proxy Manager handles reverse proxy + SSL (no manual nginx config for certs)

### Next Steps
1. **Close the 3 stale open shifts** (احمد الكوك, بلال عادل, عبد اللطيف الديب)
2. **Verify daily ledger** shows correct opening (70) and closing (606)
3. **Fix router port forwarding** for 443 so HTTPS works externally
4. **Prevent duplicate open shifts** in shift opening logic

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
