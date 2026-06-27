# EG-CO ERP — خريطة النظام الكاملة

> تاريخ: 2026-06-24  
> Stack: FastAPI (Python 3.13) · PostgreSQL 16 · React 19 · TypeScript · Tailwind CSS · Vite · Docker  
> منصة: Web PWA + Android (Capacitor) + Desktop (Tauri)

---

## فهرس المحتويات

1. [نظرة عامة](#1-نظرة-عامة)
2. [هيكل المجلدات](#2-هيكل-المجلدات)
3. [قاعدة البيانات](#3-قاعدة-البيانات)
4. [Backend — FastAPI](#4-backend--fastapi)
5. [Frontend — React](#5-frontend--react)
6. [Infrastructure](#6-infrastructure)
7. [سير العمل الرئيسية](#7-سير-العمل-الرئيسية)

---

## 1. نظرة عامة

نظام ERP متكامل لمتجر سباكة ومواد بناء (متعدد الفروع).  
يتكون من:

- **Backend** — FastAPI مع SQLAlchemy 2.0 (async) + Alembic migrations
- **Frontend** — React 19 + TypeScript + Vite + Tailwind CSS + Zustand
- **قاعدة بيانات** — PostgreSQL 16
- **تطبيق Android** — Capacitor (WebView + Native plugins)
- **تطبيق Desktop** — Tauri v2 (Rust shell + WebView)
- **PWA** — Service Worker + IndexedDB persistence للـ offline POS

### دخول افتراضي

| المستخدم | كلمة السر | الصلاحية |
|----------|-----------|----------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Admin |

### الصلاحيات

| الدور | الوصول |
|-------|--------|
| Admin | الكل |
| Manager | مبيعات, مخزون, تقارير, ورديات |
| Cashier | POS, مبيعات, عروض أسعار |
| Storekeeper | مخزون, عمليات, مشتريات |
| Accountant | تقارير, مالية, رواتب |

---

## 2. هيكل المجلدات

```
C:\eg-co-erp\
│
├── backend/                  # FastAPI server
│   ├── app/
│   │   ├── api/
│   │   │   ├── deps.py       # Dependencies (get_db, get_current_user, ...)
│   │   │   ├── errors.py     # BusinessError, error handlers
│   │   │   └── routers/      # 27 endpoint files
│   │   ├── core/
│   │   │   ├── config.py     # Settings (pydantic-settings)
│   │   │   ├── security.py   # JWT, password hashing, CSRF
│   │   │   └── roles.py      # Role/permission helpers
│   │   ├── models/           # SQLAlchemy ORM models
│   │   ├── schemas/          # Pydantic request/response schemas
│   │   └── services/         # Business logic layer
│   ├── alembic/              # Database migrations
│   ├── uploads/              # Uploaded files (images, CSVs, ...)
│   ├── main.py               # FastAPI app entry point
│   └── Dockerfile
│
├── frontend/                 # React + TypeScript
│   ├── src/
│   │   ├── api/              # Axios client + endpoint modules
│   │   ├── components/       # Shared UI components
│   │   ├── contexts/         # React contexts
│   │   ├── hooks/            # Custom hooks
│   │   ├── lib/              # Utilities (formatting, barcode, ...)
│   │   ├── pages/            # Page components
│   │   └── store/            # Zustand stores
│   ├── android/              # Capacitor Android project
│   ├── src-tauri/            # Tauri Desktop project (Rust)
│   ├── public/               # Static assets
│   ├── scripts/              # Build helper scripts
│   └── Dockerfile
│
├── docker-compose.yml        # 3 services: db, backend, frontend
├── manage.py                 # CLI for ops (backup, restore, deploy, ...)
├── init_data.sql             # Seed data (default users, categories, ...)
├── erp.bat                   # Windows launcher shortcut
├── SSL/                      # Self-signed certs for HTTPS dev
└── *.sql, *.py               # Utility/one-off scripts
```

---

## 3. قاعدة البيانات

### جدول المستخدمين والصلاحيات

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `users` | `models/user.py:22` | حسابات الدخول (id, username, hashed_password, role, warehouse_id, is_active) |
| `roles_permissions` | `models/user.py:50` | صلاحيات مخصصة لكل دور (user_id, feature, can_view, can_create, can_edit, can_delete) |

### جدول المنتجات والمخزون

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `products` | `models/product.py:30` | المنتجات (name, barcode, category_id, prices, unit, image, shelf_number, is_active) |
| `product_barcodes` | `models/product.py:100` | باركودات متعددة لكل منتج (barcode, product_id) |
| `categories` | `models/category.py:8` | التصنيفات (name, parent_id) — شجرة متعددة المستويات |
| `subcategories` | `models/category.py:30` | تصنيفات فرعية (name, category_id, is_active) |
| `warehouses` | `models/warehouse.py:8` | المخازن/الفروع (name, code, is_active) |
| `stock` | `models/stock.py:8` | رصيد المخزون (product_id, warehouse_id, quantity, updated_at) |
| `stock_movements` | `models/stock_movement.py:8` | حركات المخزون (product_id, warehouse_id, type, qty_change, ref_type, ref_id, note) |
| `stocktaking` | `models/stocktaking.py:8` | جرد المخزون (warehouse_id, date, status) |
| `stocktaking_items` | `models/stocktaking.py:30` | بنود الجرد (stocktaking_id, product_id, system_qty, actual_qty, diff) |
| `stock_transfers` | `models/stock_movement.py:30` | تحويلات بين المخازن (from_warehouse, to_warehouse, status, date) |
| `stock_transfer_items` | `models/stock_movement.py:50` | بنود التحويل (transfer_id, product_id, qty) |

### جداول المبيعات والمشتريات

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `sales` | `models/sale.py:10` | فواتير البيع (id, date, customer_id, warehouse_id, shift_id, total, paid_amount, status, sale_type, note) |
| `sale_items` | `models/sale.py:50` | بنود الفاتورة (sale_id, product_id, qty, unit_price, total) |
| `sale_payments` | `models/sale.py:80` | طرق الدفع (sale_id, method, amount, reference) |
| `quotations` | `models/sale.py:110` | عروض الأسعار (date, customer_id, warehouse_id, items, total, status) |
| `purchase_orders` | `models/purchase.py:8` | أوامر الشراء (supplier_id, warehouse_id, date, status, total, notes) |
| `purchase_order_items` | `models/purchase.py:40` | بنود أمر الشراء (po_id, product_id, qty_ordered, qty_received, unit_price) |
| `purchase_invoices` | `models/purchase.py:70` | فواتير الموردين (supplier_id, warehouse_id, date, total, paid_amount) |

### جداول العملاء والموردين

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `parties` | `models/party.py:10` | العملاء والموردين (name, phone, type, tax_id, balance, credit_limit, address) |
| `suppliers` | `models/party.py:50` | Verifies party.type == 'supplier' |

### جداول المالية

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `expenses` | `models/finance.py:8` | المصروفات (amount, category, date, note, type [recurring/one-time], approved_by) |
| `expense_categories` | `models/finance.py:30` | تصنيفات المصروفات |
| `safes` | `models/finance.py:50` | الخزائن (name, balance, warehouse_id) |
| `safe_transactions` | `models/finance.py:70` | حركات الخزينة (safe_id, type, amount, ref_type, ref_id, note) |
| `customer_wallets` | `models/finance.py:90` | محافظ العملاء (party_id, balance) |
| `wallet_transactions` | `models/finance.py:110` | حركات المحفظة (wallet_id, type, amount, ref_type, ref_id, note, balance_before) |
| `accounting_periods` | `models/finance.py:130` | الفترات المالية (name, start_date, end_date, is_closed) |

### جداول الموارد البشرية

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `employees` | `models/hr.py:8` | الموظفون (name, phone, salary, department, hire_date, is_active) |
| `attendance_records` | `models/hr.py:30` | سجلات الحضور (employee_id, date, check_in, check_out, source) |
| `payrolls` | `models/hr.py:50` | كشوف المرتبات (employee_id, period, basic_salary, allowances, deductions, net, status) |
| `payroll_items` | `models/hr.py:70` | بنود الراتب (payroll_id, type, amount) |
| `attendance_devices` | `models/hr.py:90` | أجهزة البصمة (name, ip, port, model, is_active) |

### جداول الورديات

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `shifts` | `models/shift.py:8` | الورديات (user_id, warehouse_id, opened_at, closed_at, status, opening_balance, closing_balance, notes) |
| `shift_transactions` | `models/shift.py:30` | معاملات الوردية (shift_id, type, amount, ref_type, ref_id, note) |

### جداول المطبوعات والأرشفة

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `archives` | `models/archive.py:8` | المستندات المؤرشفة (id, ref_type, ref_id, html_content, created_at) |

### جداول الإعدادات والسجل

| الجدول | الملف | الوصف |
|--------|-------|-------|
| `settings` | `models/settings.py:8` | إعدادات المتجر (JSON key-value) |
| `audit_log` | `models/audit.py:8` | سجل التدقيق (user_id, action, entity_type, entity_id, old_values, new_values, timestamp) |

---

## 4. Backend — FastAPI

### `backend/main.py`
نقطة الدخول. تنشئ `FastAPI` app، تسجل `APIRouter` الرئيسي، تثبت middleware (CORS, CSRF, rate-limiting).

### `backend/app/core/config.py`
إعدادات التطبيق عبر `pydantic-settings`: `DATABASE_URL`, `SECRET_KEY`, `ACCESS_TOKEN_EXPIRE_MINUTES`, `UPLOAD_DIR`.

### `backend/app/core/security.py`
- `create_access_token()` / `create_print_token()` — JWT
- `hash_password()` / `verify_password()` — passlib + bcrypt
- `require_csrf()` — CSRF protection via header validation

### `backend/app/core/roles.py`
- `require_role(role)` — dependency للتحقق من الدور
- `require_perm(feature)` — dependency للتحقق من صلاحية معينة
- `get_current_user()` — extracts + verifies JWT

### `backend/app/api/deps.py`
Dependencies مشتركة: `get_db` (async session), `get_pagination`, etc.

### `backend/app/api/errors.py`
`BusinessError` class + exception handlers (`BusinessError`, `ValidationError`, `IntegrityError`).

### Routers (`backend/app/api/routers/`)

| الملف | المسار | الوظيفة |
|-------|--------|---------|
| `auth.py` | `/auth/*` | Login, logout, refresh, change password, roles/permissions CRUD |
| `users.py` | `/users/*` | CRUD مستخدمين, reset password |
| `products.py` | `/products/*` | CRUD منتجات, بحث, باركودات متعددة |

| `categories.py` | `/categories/*` | CRUD تصنيفات (شجرة) |
| `subcategories.py` | `/subcategories/*` | CRUD تصنيفات فرعية |
| `warehouses.py` | `/warehouses/*` | CRUD مخازن |

| `stock.py` | `/stock/*` | رصيد, حركات, تحويلات, جرد, تعديل رصيد |
| `stocktaking.py` | `/stocktaking/*` | جرد المخزون |
| `transfers.py` | `/transfers/*` | تحويلات بين المخازن |

| `sales.py` | `/sales/*` | CRUD فواتير بيع, مرتجعات, دفع |
| `quotations.py` | `/quotations/*` | CRUD عروض أسعار, تحويل لفاتورة |
| `pos.py` | `/pos/*` | نقاط البيع (checkout, hold, resume, void, split payments) |
| `purchases.py` | `/purchases/*` | أوامر شراء, استلام, فواتير موردين |

| `customers.py` | `/customers/*` | CRUD عملاء |
| `suppliers.py` | `/suppliers/*` | CRUD موردين |

| `expenses.py` | `/expenses/*` | CRUD مصروفات, موافقة |
| `safes.py` | `/safes/*` | CRUD خزائن, إيداع/سحب |
| `wallets.py` | `/wallets/*` | محافظ العملاء, حركات |
| `accounting.py` | `/accounting/*` | تقارير مالية, دفتر أستاذ, فترات |
| `cash_flow.py` | `/cash-flow/*` | كشف التدفق النقدي |

| `hr.py` | `/hr/*` | موظفين, حضور, رواتب, أجهزة بصمة |
| `shifts.py` | `/shifts/*` | CRUD ورديات, معاملات, تقارير |

| `settings.py` | `/settings/*` | إعدادات المتجر (شعار, اسم, manifest.json) |
| `archive.py` | `/archive/*` | أرشفة وعرض المستندات |
| `audit.py` | `/audit/*` | سجل التدقيق |
| `collections.py` | `/collections/*` | تحصيل ديون |
| `dashboard.py` | `/dashboard/*` | لوحة التحكم (إحصائيات, charts) |
| `health.py` | `/health` | Health check endpoint |
| `export.py` | `/export/*` | تصدير Excel لجميع الجداول |

### Print Routers (`backend/app/api/routers/print/`)

تم تقسيم `print_router.py` (كان 1329 سطراً) إلى 8 ملفات:

| الملف | المسار | المطبوعات |
|-------|--------|-----------|
| `__init__.py` | — | CSS مشترك + تسجيل جميع sub-routers |
| `sale.py` | `/print/sale/*` | فاتورة بيع, عرض سعر, مرتجع |
| `purchase.py` | `/print/purchase/*` | أمر شراء, فاتورة مورد |
| `archive.py` | `/print/archive/*` | مستندات مؤرشفة |
| `inventory.py` | `/print/inventory/*` | جرد, كشف رصيد |
| `shift.py` | `/print/shift/*` | تقرير وردية, إيداع عهدة |
| `financial.py` | `/print/financial/*` | تقارير مالية |
| `hr.py` | `/print/hr/*` | كشف مرتب, تقرير دوام |

### Models (`backend/app/models/`)

كل ملف يحتوي على SQLAlchemy `DeclarativeBase` models.  
راجع [قاعدة البيانات](#3-قاعدة-البيانات) أعلاه لكل جدول وصفه.

### Schemas (`backend/app/schemas/`)

Pydantic v2 schemas للـ request/response validation.  
نفس تقسيم الـ routers تقريباً (كل router عنده schema file).

### Services (`backend/app/services/`)

طبقة منطق الأعمال — تفصل الـ business logic عن الـ routers:

| الملف | الوظيفة |
|-------|---------|
| `stock_service.py` | حسابات الرصيد (FOR UPDATE), حركات المخزون, تحويلات |
| `sale_service.py` | إنشاء فاتورة, خصم رصيد, مرتجعات, split payments |
| `purchase_service.py` | أوامر شراء, استلام, تحديث رصيد |
| `wallet_service.py` | محافظ العملاء (إيداع/سحب/تحويل مع overdraft check) |
| `finance_service.py` | تقارير مالية, دفتر أستاذ, إقفال فترة |
| `payroll_engine.py` | حساب الرواتب (custom business rules: دوام, غياب, إضافي, ...) |
| `zk_sync.py` | مزامنة أجهزة البصمة ZKTeco عبر pyzk |
| `archive_service.py` | أرشفة تلقائية لكل المستندات |
| `excel_export.py` | تصدير Excel عبر openpyxl |
| `settings_service.py` | قراءة/كتابة الإعدادات, generate manifest.json |
| `barcode_service.py` | توليد باركودات, scan, validation |

### Alembic (`backend/alembic/`)

- `env.py` — تكوين Alembic (async driver, `target_metadata = Base.metadata`)
- `versions/` — ملفات migrations (كل ملف يمثل تغييراً في الـ schema)

---

## 5. Frontend — React

### `frontend/src/api/`

| الملف | الوظيفة |
|-------|---------|
| `client.ts` | Axios instance (baseURL, interceptors للـ JWT + refresh + CSRF) |
| `auth.ts` | دوال تسجيل الدخول/تسجيل الخروج |
| `products.ts` | دوال CRUD + بحث + باركودات |
| `categories.ts`, `subcategories.ts` | دوال التصنيفات |
| `warehouses.ts` | دوال المخازن |
| `stock.ts` | دوال المخزون والحركات |
| `sales.ts` | دوال المبيعات |
| `pos.ts` | دوال نقاط البيع |
| `purchases.ts` | دوال المشتريات |
| `parties.ts` | دوال العملاء والموردين |
| `expenses.ts` | دوال المصروفات |
| `safes.ts` | دوال الخزائن |
| `wallets.ts` | دوال المحافظ |
| `accounting.ts` | دوال التقارير المالية |
| `hr.ts` | دوال الموارد البشرية |
| `shifts.ts` | دوال الورديات |
| `settings.ts` | دوال الإعدادات |
| `archive.ts` | دوال الأرشفة |
| `audit.ts` | دوال سجل التدقيق |
| `dashboard.ts` | دوال لوحة التحكم |
| `collections.ts` | دوال التحصيل |
| `suppliers.ts` | دوال الموردين |
| `export.ts` | دوال التصدير |

### `frontend/src/store/` (Zustand stores)

| الملف | الوظيفة |
|-------|---------|
| `authStore.ts` | Auth state (user, token, login/logout, permissions) — persist |
| `cartStore.ts` | سلة POS (items, quantities, discounts, notes) — غير persist |
| `pendingSalesStore.ts` | فواتير Offline pending — persist (localStorage) |
| `localShiftStore.ts` | وردية محلية Offline — persist (localStorage) |
| `offlineSyncStore.ts` | Queue المزامنة (actions pending sync) — persist |

### `frontend/src/contexts/`

| الملف | الوظيفة |
|-------|---------|
| `QueryContext.tsx` | React Query provider + persist client (IndexedDB) |
| `ThemeContext.tsx` | الوضع الليلي/النهاري |

### `frontend/src/hooks/`

| الملف | الوظيفة |
|-------|---------|
| `useAuth.ts` | اختصار لـ authStore |
| `usePermissions.ts` | التحقق من الصلاحيات في الـ components |
| `useBarcode.ts` |扫描 الباركود (keyboard + camera) |
| `useDebounce.ts` | Debounce للبحث |
| `useOnlineStatus.ts` | مراقبة الاتصال (onLine/offLine) |
| `useOfflineSync.ts` | مزامنة Offline queue |

### `frontend/src/components/` (مشتركة)

| الملف | الوظيفة |
|-------|---------|
| `DataTable.tsx` | جدول بيانات عام (sorting, pagination, loading, empty state) |
| `Modal.tsx` | نافذة منبثقة عامة |
| `ConfirmDialog.tsx` | تأكيد الإجراءات |
| `FormField.tsx` | حقل نموذج عام |
| `SearchInput.tsx` | حقل بحث |
| `PageLoader.tsx` | شاشة تحميل |
| `EmptyState.tsx` | حالة عدم وجود بيانات |
| `ErrorBoundary.tsx` | Catch errors |
| `OfflineBanner.tsx` | إشعار Offline |
| `Sidebar.tsx` | القائمة الجانبية |
| `Layout.tsx` | الهيكل العام للصفحات |
| `BarcodeManager.tsx` | إدارة باركودات متعددة لمنتج |
| `openPrint.ts` | Utility للطباعة (popup blocker detection + fallback) |

### `frontend/src/pages/`

| الملف | المسار | الوظيفة |
|-------|--------|---------|
| `LoginPage.tsx` | `/login` | تسجيل الدخول |
| `DashboardPage.tsx` | `/dashboard` | لوحة التحكم (إحصائيات, رسوم بيانية) |
| `POSPage.tsx` | `/pos` | نقطة البيع (بحث, سلة, check out, hold, resume) |
| `SalesPage.tsx` | `/sales` | قائمة فواتير البيع |
| `SaleDetailPage.tsx` | `/sales/:id` | تفاصيل فاتورة بيع |
| `QuotationsPage.tsx` | `/quotations` | عروض الأسعار |
| `InventoryPage.tsx` | `/inventory` | رصيد المخزون (بحث, فلتر) |
| `StockMovementsPage.tsx` | `/stock-movements` | حركات المخزون |
| `StocktakingPage.tsx` | `/stocktaking` | الجرد |
| `TransfersPage.tsx` | `/transfers` | تحويلات المخزون |
| `ProductsPage.tsx` | `/products` | إدارة المنتجات |
| `ProductFormPage.tsx` | `/products/new`, `/products/:id/edit` | إضافة/تعديل منتج |
| `CategoriesPage.tsx` | `/categories` | إدارة التصنيفات (شجرة) |
| `WarehousesPage.tsx` | `/warehouses` | إدارة المخازن |
| `SuppliersPage.tsx` | `/suppliers` | إدارة الموردين |
| `CustomersPage.tsx` | `/customers` | إدارة العملاء |
| `PurchasesPage.tsx` | `/operations` | المشتريات (أوامر شراء + فواتير موردين) |
| `ExpensesPage.tsx` | `/expenses` | المصروفات |
| `SafesPage.tsx` | `/safes` | الخزائن |
| `WalletsPage.tsx` | `/wallets` | محافظ العملاء |
| `AccountingPage.tsx` | `/accounting` | تقارير مالية (أرباح/خسائر, دفتر أستاذ, فترات) |
| `CashFlowPage.tsx` | `/cash-flow` | كشف التدفق النقدي |
| `AgingPage.tsx` | `/aging` | تقارير الأعمار (عملاء + موردون) |
| `CollectionsPage.tsx` | `/collections` | تحصيل الديون |
| `HrPage.tsx` | `/hr` | الموارد البشرية (موظفين, حضور, رواتب) |
| `ShiftsPage.tsx` | `/shifts` | إدارة الورديات |
| `SettingsPage.tsx` | `/settings` | الإعدادات (شعار, اسم, صلاحيات, tabs) |
| `ArchivePage.tsx` | `/archive` | الأرشيف |
| `AuditPage.tsx` | `/audit` | سجل التدقيق |
| `AdminPage.tsx` | `/admin` | لوحة تحكم المدير (manage users, roles) |

### PWA / Offline

| الملف | الوظيفة |
|-------|---------|
| `sw.ts` | Service Worker (caching استراتيجيات للـ API + static assets) |
| `offlineSync.ts` | مزامنة Offline queue عند استعادة الاتصال |
| `manifest.ts` | Manifest ديناميكي (شعار + اسم من الإعدادات) |

### Android (Capacitor) — `frontend/android/`

| الميزة | الـ plugin |
|--------|------------|
| Camera barcode | `@capacitor/camera` |
| Bluetooth printing | `@capacitor-community/bluetooth-le` |
| Biometric auth | `@aparajita/capacitor-biometric-auth` |
| Local notifications | `@capacitor/local-notifications` |
| Status bar | `@capacitor/status-bar` |
| Filesystem | `@capacitor/filesystem` |

### Desktop (Tauri) — `frontend/src-tauri/`

| الميزة | الوصف |
|--------|-------|
| System tray | أيقونة في شريط المهام مع قائمة (إظهار, إخفاء, خروج) |
| Offline indicator | `tauri::command is_online` + `get_offline_queue` |
| Auto-update | Tauri updater (needs pubkey) |
| Notifications | `tauri-plugin-notification` |

---

## 6. Infrastructure

### Docker Compose (`docker-compose.yml`)

3 خدمات:

| الخدمة | الصورة | الاعتماديات | الموارد |
|--------|--------|-------------|---------|
| `db` | `postgres:16-alpine` | — | 1 CPU, 512M RAM |
| `backend` | مبنية من `./backend` | db (healthcheck) | 1 CPU, 1G RAM |
| `frontend` | مبنية من `./frontend` | backend | — |

- الـ backend يتصل بـ db عبر `DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/inventory_db`
- الـ frontend يعمل على port 80 (Nginx reverse proxy)
- Volume: `pgdata` لقاعدة البيانات, `uploads_data` للملفات المرفوعة

### Backend Dockerfile

- Base: `python:3.11-slim`
- system deps: gcc, libpq-dev, Pango/Cairo (لـ WeasyPrint التقارير), خطوط Noto
- pip install من `requirements.txt`
- يعمل كمستخدم `appuser` (غير root)
- Port 8000

### Frontend Dockerfile

- Multi-stage:
  1. `node:20-alpine` — npm ci + build
  2. `nginx:alpine` — تخدم الـ static build على port 80
- nginx.conf يعمل reverse proxy للـ backend في الطلبات `/api/*`

### `manage.py`

CLI أداة:

| الأمر | الوظيفة |
|-------|---------|
| `backup` | نسخة احتياطية من قاعدة البيانات (pg_dump) |
| `restore` | استعادة نسخة احتياطية |
| `deploy` | تحديث التطبيق على السيرفر (git pull + docker compose up -d --build) |
| `logs` | عرض logs الحاوية |
| `migrate` | تشغيل Alembic migrations |

### `init_data.sql`

بيانات أولية تُحقن تلقائياً عند أول تشغيل لـ PostgreSQL (عبر `/docker-entrypoint-initdb.d/`):
- مستخدمين افتراضيين (ammar, nada)
- صلاحيات افتراضية
- تصنيفات أولية

### CI/CD (GitHub Actions — `.github/`)

| الـ workflow | الوظيفة |
|-------------|---------|
| `ci.yml` | lint → typecheck → test → build → Docker images |
| `release.yml` | بناء Android APK + Desktop EXE عند إنشاء tag |
| `e2e.yml` | تشغيل Playwright E2E tests |

### Playwright E2E (`frontend/e2e/`)

| الملف | الوظيفة |
|-------|---------|
| `login.spec.ts` | تسجيل الدخول/الخروج |
| `pos.spec.ts` | دورة بيع كاملة في POS |
| `inventory.spec.ts` | تصفح المخزون, جرد |
| `sales.spec.ts` | إنشاء فاتورة بيع, عرض |

---

## 7. سير العمل الرئيسية

### دورة البيع في POS
1. يفتح cashier وردية → shift status = `open`
2. يختار warehouse
3. يبحث عن منتج (search debounced 300ms) أو scan barcode
4. يضيف إلى cartStore
5. (اختياري) يحدد عميل, يطبق خصم, split payment
6. Checkout → sale_service.create_sale() مع FOR UPDATE على stock
7. يطبع الفاتورة عبر `/print/sale/{id}`
8. لو Offline: يحفظ في pendingSalesStore + offlineSyncStore → يزامن لاحقاً

### دورة المشتريات
1. مدخل بيانات ينشئ Purchase Order
2. مدير يوافق على الـ PO
3. أمين مخزن يستلم الشحنة → qty_received يحدث
4. stock يزيد تلقائياً
5. تنشأ Purchase Invoice (حساب مورد)

### دورة المخزون
- كل حركة (بيع, شراء, تحويل, جرد, تعديل) تسجل في `stock_movements`
- الرصود محسوبة (query-driven) باستخدام `SUM(...) WHERE warehouse_id = ?`
- `FOR UPDATE` يمنع الـ race conditions عند checkout

### دورة الورديات
1. مدير أو أمين مخزن يفتح وردية → opening_balance
2. كل المعاملات المالية تربط بـ shift_id
3. عند الإغلاق → closing_balance, system حساب الفرق
4. طباعة تقرير الوردية + إيداع العهدة

### Offline POS
1. Service Worker يخبئ assets الأساسية
2. React Query persist client يخبئ البيانات في IndexedDB
3. لو disconnected:
   - البحث محلياً في cache
   - إنشاء فاتورة محلياً في pendingSalesStore
   - فتح وردية محلية في localShiftStore
4. عند استعادة الاتصال:
   - offlineSyncStore يزامن الفواتير المعلقة
   - لو 409 (conflict) → يعرض خطأ للمستخدم

### التقارير المالية
- Profit & Loss: إجمالي مبيعات - تكلفة مبيعات - مصروفات
- دفتر الأستاذ: كل الحركات المالية مصنفة
- Aging: عملاء 0-30-60-90+ يوم
- Cash Flow: وارد وصادر وصافي
- دعم الفترات المالية (monthly close)
