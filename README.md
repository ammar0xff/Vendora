# Vendora — نظام إدارة متجر سباكة ومواد بناء

نظام ERP متكامل **متعدد الفروع** لمتجر سباكة ومواد بناء، يشمل **POS**, **مخزون**, **مبيعات**, **مشتريات**, **مالية/محاسبة**, **HR ورواتب**, و **ورديات** لكل فرع.

> Multi-branch ERP for a plumbing & building-supplies store: POS, inventory, sales, purchases, accounting, HR/payroll, and per-branch shifts.

---

## ✨ المزايا / Features

- **POS** — باركود (multi-barcode), سلة, خصومات, بيع آجل (credit), مرتجعات جزئية/كاملة
- **مبيعات وعروض أسعار** — تتبع أرباح, تسعير مخصص, تحويل عرض سعر لفاتورة (مع اختيار الدرج أو الخزنة)
- **مخزون** — رصيد محسوب من الحركات (`stock_movements`), عزل لكل فرع, جرد (stocktaking)
- **مشتريات** — فواتير موردين, تاريخ أسعار, اقتراحات إعادة الطلب, استلام مشتريات
- **موردون وعملاء** — دفتر أستاذ, رصيد/ديون, مدفوعات لكل فاتورة
- **مالية** — أرباح/خسائر مع مصروفات, دفتر أستاذ (ledger), درج وخزنة, لوحة تحكم
- **HR ورواتب** — دوام (import CSV — يدعم Jibble), حساب رواتب, كشوف مرتبات
- **ورديات** — لكل فرع, توقيع مدير, عهدة (إذن تسليم)
- **أرشيف** — كل المستندات تُؤرشف تلقائياً مع طباعة HTML احترافية
- **متعدد الفروع** — كل فرع يرى بياناته فقط; المدير/الأدمن يرى الكل

## 📦 Stack

| Layer | Tech |
|-------|------|
| Backend | Python 3.13 · FastAPI · SQLAlchemy 2.0 (async) · Alembic |
| Frontend | React 19 · TypeScript · Vite · Tailwind CSS · Zustand |
| Database | PostgreSQL 16 |
| Mobile | Capacitor (Android) — PWA + WebView |
| Desktop | Tauri v2 (Rust shell + WebView) |
| Infra | Docker Compose · Nginx Proxy Manager (reverse proxy + SSL) |

**Platforms:** Web (PWA, offline POS via IndexedDB) · Android (Capacitor) · Desktop (Tauri)

---

## 🚀 Quick Start

```bash
# 1. أدخل الدليل
cd Vendora

# 2. شغّل النظام بالكامل (db + backend + frontend)
docker compose up -d --build

# 3. تحقّق من الصحة
curl http://localhost/api/health   # أو http://localhost:8080/health

# 4. شغّل initial setup (installs Docker, builds, systemd auto-start)
bash install.sh
```

### Default Login
| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Admin |

> ⚠️ **غيّر كلمة السر فور أول دخول.**

### Roles
| Role | Access |
|------|--------|
| Admin | الكل |
| Manager | مبيعات, مخزون, تقارير, ورديات |
| Cashier | POS, مبيعات, عروض أسعار |
| Storekeeper | مخزون, عمليات, مشتريات |
| Accountant | تقارير, مالية, رواتب |

---

## 📁 Structure

```
Vendora/
├── backend/                  # FastAPI server
│   ├── app/
│   │   ├── api/routers/      # 27 endpoint files
│   │   ├── models/           # SQLAlchemy ORM
│   │   ├── schemas/          # Pydantic
│   │   ├── services/         # Business logic
│   │   └── core/             # Config, security, roles
│   ├── alembic/              # Migrations
│   └── Dockerfile
├── frontend/                 # React 19 + TS + Vite
│   ├── src/                  # api/ components/ pages/ store/
│   ├── android/              # Capacitor
│   ├── src-tauri/            # Tauri (Rust)
│   └── Dockerfile
├── scripts/                  # Runtime entry-point scripts
│   ├── migrate.py            # Safe incremental DB migrations
│   ├── setup.py              # Fresh-server config helper
│   └── data/                 # One-off data-import / catalog scripts
├── data/
│   ├── sql/                  # init_data.sql, prod_db.sql, DB dumps
│   ├── imports/              # Supplier price source files (xlsx/pdf)
│   ├── supplier_files/       # Cleaned supplier catalogs
│   └── analysis/             # Data-cleanup analysis
├── migrations/               # Ad-hoc SQL migrations
├── docs/                     # AUDIT reports
├── ssl/                      # Dev certs
├── manage.py                 # CLI ops (backup/restore/deploy)
├── docker-compose.yml        # db + backend + frontend + nginxpm
└── AGENTS.md · SYSTEM.md · TASKS.md   # AI-agent context & architecture refs
```

---

## 🛠 Ops

```bash
# Backup / restore / deploy / logs
python manage.py backup
python manage.py restore <file>
python manage.py deploy
python manage.py logs

# Fresh-server one-time setup (Ubuntu/Debian, Docker + systemd auto-start)
bash install.sh

# Domain-aware config helper
python scripts/setup.py --domain eg-co.duckdns.org

# Apply pending migrations
python scripts/migrate.py
```

> On the server an `erp` shortcut is created — `erp status | erp backup | erp restart | erp logs`.

---

## 📚 Docs

| File | Purpose |
|------|---------|
| `SYSTEM.md` | Full system architecture (roles, tables, API, workflows) |
| `TASKS.md` | Features & bug-tracking status |
| `AGENTS.md` | AI-agent persistent memory / session context |
| `docs/AUDIT.md` | Backend audit log |
| `docs/AUDIT-frontend.md` | Frontend audit log |

---

## 🌐 Deployment

Live at **`eg-co.duckdns.org`**. Four containers: `db`, `backend`, `frontend` (port 8080), `nginxpm` (80/443/81). HTTPS/SSL handled by Nginx Proxy Manager.

`deploy.sh` — pushes local `master`, then SSHes to the server, runs migrations, closes stale shifts, rebuilds and health-checks.

---

## License

لا يوجد ترخيص محدد — مملوك وخاص. / Proprietary — no license specified.