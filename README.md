# EG-CO ERP System

A full-featured web ERP for a multi-branch plumbing & hardware company.

**Stack:** FastAPI · PostgreSQL · React 19 · TypeScript · Tailwind · Docker

---

## Features

- **POS** — barcode scanning, cart, discounts, credit sales, returns
- **Sales & Quotations** — profit tracking, custom pricing, convert to invoice
- **Inventory** — stock computed from movements, per-branch isolation
- **Purchases** — supplier invoices, price history, smart reorder suggestions
- **Suppliers & Customers** — ledger, balance tracking, debt management
- **HR & Payroll** — attendance engine, salary calculation, payslips
- **Shift System** — per-branch, manager sign-off, handover receipts
- **Finance** — P&L with expenses, financial ledger, company overview dashboard
- **Archive** — all documents auto-archived with professional HTML print
- **Multi-branch** — each branch sees only its own data; admin sees all

---

## Quick Start

### Requirements
- Docker + Docker Compose

### First Run
```bash
# Linux / macOS
bash install.sh

# Windows — right-click install.bat → Run as administrator
install.bat
```

Open **http://localhost** in your browser.

### Default Login
| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Admin |

> ⚠️ Change passwords after first login.

---

## Management Commands

```bash
python manage.py status      # Check system health
python manage.py backup      # Backup database → backups/
python manage.py restore <file>  # Restore from backup
python manage.py restart     # Restart all services
python manage.py logs        # Live logs
```

---

## Architecture

```
inventory-web/
├── backend/          FastAPI app (Python 3.13)
│   ├── app/
│   │   ├── api/routers/   All API endpoints
│   │   ├── models/        SQLAlchemy ORM models
│   │   ├── services/      Business logic
│   │   └── core/          Config, security, roles
│   └── Dockerfile
├── frontend/         React + TypeScript + Vite
│   ├── src/
│   │   ├── pages/         All UI pages
│   │   ├── components/    Shared components
│   │   ├── store/         Zustand state
│   │   └── api/           API client
│   └── Dockerfile
├── docker-compose.yml
├── init_data.sql     Initial data (products, users, warehouses)
├── manage.py         Management CLI
├── install.sh        Linux installer
├── install.bat       Windows installer
└── BACKLOG.md        Remaining features from PRD
```

---

## User Roles

| Role | Access |
|------|--------|
| Admin | Everything |
| Manager | Sales, inventory, reports, shifts |
| Cashier | POS, sales, quotations |
| Storekeeper | Inventory, operations, purchases |
| Accountant | Reports, finance, payroll |

---

## Backup & Restore

```bash
# Backup
python manage.py backup
# → saves to backups/backup_YYYYMMDD_HHMMSS.sql (keeps last 10)

# Restore
python manage.py restore backup_20260330_174523.sql
```

---

## Deployment on New Machine

```bash
git clone https://github.com/ammar0xff/eg-co-erp.git
cd eg-co-erp
bash install.sh
```

All data (products, users, warehouses, settings) loads automatically from `init_data.sql`.
