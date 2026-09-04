---
inclusion: always
---

# Vendora — Project Context

## Stack
- **Backend**: FastAPI (Python 3.13) + SQLAlchemy async + PostgreSQL 16 + Alembic
- **Frontend**: React 19 + TypeScript + Tailwind CSS v4 + Vite + Zustand + TanStack Query
- **Deployment**: Docker Compose — 4 services: `db`, `backend`, `frontend:8080`, `nginxpm:80/443`
- **Platforms**: Web PWA + Android (Capacitor) + Desktop (Tauri)
- **Domain**: `eg-co.duckdns.org`

## Project Root: `C:\eg-co-erp\`
- Backend: `backend/app/`
- Frontend: `frontend/src/`
- Specs: `.kiro/specs/`

## Key Conventions

### Backend
- All routers in `backend/app/api/routers/`
- Models in `backend/app/models/` (SQLAlchemy async)
- Schemas in `backend/app/schemas/` (Pydantic v2)
- DB migrations via Alembic: `cd backend && alembic revision --autogenerate -m "..." && alembic upgrade head`
- Run: `uvicorn main:app --reload` from `backend/`

### Frontend
- Pages in `frontend/src/pages/`
- API calls in `frontend/src/api/endpoints.ts`
- State: Zustand stores in `frontend/src/store/`
- Test command: `npx vitest run` from `frontend/`
- Build: `npm run build` from `frontend/`

### Docker Deploy
- Build + restart: `docker compose build <service> && docker compose up -d <service>`
- Force fresh build: `docker compose build --no-cache <service>`
- Logs: `docker compose logs -f <service>`
- DB shell: `docker exec eg-co-erp-db-1 psql -U postgres -d inventory_db -c "..."`

## Default Credentials
- Admin: `ammar` / `changeme`
- Admin: `nada` / `changeme`

## Warehouses
| ID | Name |
|----|------|
| `122f5b3b-9519-5b1e-a3fd-0ddacba7e157` | معرض المؤمن |
| `dc59d83b-1dec-4f60-8cde-4826031c7195` | معرض العبور |
| `cb6d74a5-2aab-473e-8acb-3b559fa4fea4` | معرض شارع ناصر |

## Important Notes
- Arabic RTL UI — all user-facing text in Arabic
- `sale_payments` table tracks per-invoice payments (method, amount, wallet_id)
- `shifts` table: `initial_amount` = opening cash drawer
- Ledger endpoint: `/reports/ledger?from_date=&to_date=&warehouse_id=`
