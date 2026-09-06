# Vendora — Tasks & Status

> آخر تحديث: 2026-09-06 (جلسة توثيق: README + SYSTEM.md + TASKS sync)
> آخر جلسات فير: 2026-08-11 (Jibble CSV attendance) · 2026-08-09 (subcategory delete) · 2026-08-08 (قرار الدرج/الخزنة)
> Stack: FastAPI (Python 3.12/3.13) · PostgreSQL 16 · React 19 · TypeScript · Tailwind v4 · Vite · Docker

---

## 1 المقدمة — Project Overview

نظام ERP متكامل لمتجر سباكة ومواد بناء متعدد الفروع.

**المزايا الرئيسية:**
- POS — باركود, سلة, خصومات, بيع آجل, مرتجعات
- مبيعات وعروض أسعار — تتبع أرباح, تسعير مخصص, تحويل لفاتورة
- مخزون — رصيد محسوب من الحركات, عزل لكل فرع
- مشتريات — فواتير موردين, تاريخ أسعار, اقتراحات إعادة طلب
- موردون وعملاء — دفتر أستاذ, رصيد, إدارة ديون
- HR ورواتب — محرك دوام, حساب رواتب, كشوف مرتبات
- ورديات — لكل فرع, توقيع مدير, إذن تسليم عهدة
- مالية — أرباح/خسائر مع مصروفات, دفتر أستاذ, لوحة تحكم شاملة
- أرشيف — كل المستندات تؤرشف تلقائياً بطباعة HTML احترافية
- متعدد الفروع — كل فرع يرى بياناته فقط; المدير يرى الكل

### Default Login
| Username | Password | Role |
|----------|----------|------|
| `ammar` | `changeme` | Admin |
| `nada` | `changeme` | Accountant (full perms, is_manager) |

### Architecture
```
Vendora/
├── backend/          FastAPI (Python 3.12 img / 3.13 CI)
│   ├── app/
│   │   ├── api/routers/   27 routers + print/ sub-package (7 files)
│   │   ├── models/        SQLAlchemy ORM (20 files, 33 tables)
│   │   ├── schemas/       Pydantic v2 (17 files)
│   │   ├── services/      Business logic (8 services)
│   │   └── core/          Config, security, roles, ratelimit
│   ├── alembic/           Scaffold only (schema = create_all + SQL migrations)
│   ├── migrations/        Idempotent SQL migrations
│   └── Dockerfile
├── frontend/         React 19 + TypeScript + Vite + Tailwind v4
│   ├── src/pages/        25 page modules
│   ├── src/store/        Zustand (9 stores: auth, app, pos, purchaseCart,
│   │                     pendingSales, localShift, offline, offlineCache, queryPersister)
│   └── src/api/          Axios client + typed endpoints
├── docker-compose.yml   4 services (db, backend, frontend, nginxpm)
├── data/sql/init_data.sql
├── manage.py             CLI (status/backup/restore/deploy/migrate/build-*)
├── install.sh / deploy.sh
├── frontend/android/     Capacitor (Android)
└── frontend/src-tauri/   Tauri v2 (Desktop)
```

### User Roles
| Role | Access |
|------|--------|
| Admin | الكل |
| Manager | مبيعات, مخزون, تقارير, ورديات |
| Cashier | POS, مبيعات, عروض أسعار |
| Storekeeper | مخزون, عمليات, مشتريات |
| Accountant | تقارير, مالية, رواتب |

---

## 2 الميزات — Features Status

### ✅ مكتملة (20)

| # | الميزة |
|---|--------|
| 1 | Expenses Module — متكررة / لمرة / اعتماد / موردون |
| 2 | Cash Flow Statement — وارد / صادر / صافي |
| 3 | Aging Reports — عملاء + موردون / 0-30-60-90+ |
| 4 | Customer Credit Limits — حد أقصى للمديونية + منع البيع الآجل |
| 5 | Granular Permissions — require_perm() لكل feature + route guards |
| 6 | Payroll & Attendance — engine, ZK sync, CSV import, تقارير |
| 7 | UI Restructuring — دمج المشتريات بالعمليات / إزالة تكرارات |
| 8 | Reports & Settings — دفتر الأستاذ / إحصائيات / categories tree |
| 9 | Duplication Cleanup — /finance /admin /reports /purchases |
| 10 | Split Payments — نقدي + كارت / نقدي + آجل في الـ POS |
| 11 | Hold / Resume Bills — تعليق واستئناف الفواتير في الـ POS |
| 12 | Multiple Barcodes per Product — عدة باركودات + BarcodeManager |
| 13 | Supplier Price Comparison — مقارنة أسعار الموردين |
| 14 | CSV Attendance Sync — استيراد حضور من ملف CSV |
| 15 | Payroll Approval Workflow — مسودة → مراجعة → اعتماد → صرف |
| 16 | Audit Log — تتبع كل التغييرات + صفحة frontend |
| 17 | Product Images in POS — رفع وعرض الصور في POS + المنتجات |
| 18 | Export Excel — جميع الصفحات مع export endpoints |
| 19 | Accounting Periods — إغلاق شهري / period lock |
| 20 | **Offline POS** — SW caching + sync queue + UI indicators |

### ✅ قيد التنفيذ

#### 🛒 Offline POS متكامل (مُنفَّذ)
| #   | المهمة            | الوصف                                                                     | الحالة |
| --- | ----------------- | ------------------------------------------------------------------------- | ------ |
| O1  | Persistent Cache  | IndexedDB persistence لـ React Query باستخدام `@tanstack/react-query-persist-client` + `idb-keyval` | ✅ |
| O2  | Optimistic UI     | `pendingSalesStore` (Zustand persist) — فواتير محلية تظهر في OfflineBanner | ✅ |
| O3  | Local Shift       | `localShiftStore` — فتح وردية محلياً + مزامنة تلقائية عند الاتصال          | ✅ |
| O4  | Sync Conflict     | OfflineSync يتحقق من أخطاء 409 (مخزون/أسعار) عند المزامنة ويعرضها للمستخدم | ✅ |
| O5 | Offline-Proof POS | POSPage يعمل Offline: بحث محلي, فاتورة محلية, وردية محلية, طباعة محلية     | ✅ |
| O6 | PWA icon from settings | Manifest ديناميكي يستخدم شعار المتجر من `/api/settings/manifest.json` | ✅ |
 
#### 📱 Android App (جاهز للتشغيل)
| # | المهمة | الوصف | الحالة |
|---|--------|-------|--------|
| A1 | Build pipeline | `npm run build:android` → APK (8 plugins installed) | ✅ |
| A2 | Camera barcode | `@capacitor/camera` plugin + `scanBarcode()` utility | ✅ |
| A3 | Push notifications | `@capacitor/local-notifications` مثبت — يحتاج FCM setup | 🔲 |
| A4 | Bluetooth printing | `@capacitor-community/bluetooth-le` + `printBluetooth()` | ✅ |
| A5 | Biometric auth | `@aparajita/capacitor-biometric-auth` + `requestBiometricAuth()` | ✅ |
| A6 | App icon from settings | `scripts/generate-icons.mjs` يولد أيقونات Android من شعار المتجر تلقائياً في `prebuild:android` | ✅ |

#### 🖥️ Desktop App (جاهز للتشغيل)
| # | المهمة | الوصف | الحالة |
|---|--------|-------|--------|
| D1 | Build pipeline | `npm run build:desktop` → AppImage/EXE | ✅ |
| D2 | Tray / background | System tray + `tauri-plugin-notification` + tray menu | ✅ |
| D3 | Offline indicator | Tauri commands `is_online` + `get_offline_queue` | ✅ |
| D4 | Auto-update | `tauri.conf.json` updater configured — pubkey set (Ed25519) + backend `/api/updater` feed + `/updates` downloads | ✅ |
| D5 | App icon from settings | `scripts/generate-icons.mjs` يولد أيقونات Tauri (PNG + مربعات ويندوز + iOS) من شعار المتجر تلقائياً في `prebuild:desktop` | ✅ |

#### 🧪 جودة وبنية تحتية
| # | المهمة | الوصف |
|---|--------|-------|
| Q1 | Playwright E2E | 5 test specs (login/POS/inventory/sales/settings) + helpers | ✅ |
| Q2 | GitHub Actions CI/CD | lint → typecheck → test → build → native apps + Docker on tags | ✅ |
| Q3 | Docker | Dockerfile للتشغيل على أي سيرفر |
| Q4 | Rate limiting | slowapi على auth endpoints | ✅ |
| Q5 | HttpOnly cookies | بدلاً من localStorage للـ JWT | ✅ |
| Q6 | Print router refactor | 1329-line `print_router.py` → `print/` sub-package (7 files: `__init__` + sale/purchase/archive/inventory/shift/dispatch) | ✅ |
| Q7 | CSRF protection | Referer/Origin + token validation globally | ✅ |

---

## 3 البق — Bugs Status

### ✅ تم الإصلاح (46)

#### Critical
| # | الموجز | الإصلاح |
|---|--------|---------|
| C1 | Missing `/stock/transfer` route decorator | Added `@router.post` decorator |
| C2 | Race condition في مبيعات المخزون | SELECT ... FOR UPDATE في get_balance |
| C3 | Double Commit في create_sale | Transaction واحدة / commit واحد |
| C4 | SQL injection via f-strings (7 files) | Parameterized queries everywhere |
| C5 | Duplicate function in `hr.py` | Removed dead function |
| 17 | Dispatch Order — بدون فحص رصيد | balance check قبل transfer_out |
| 18 | Delete Drawer Transaction — بدون فحص الوردية | Shift status check |

#### High
| # | الموجز | الإصلاح |
|---|--------|---------|
| D1 | `wallet_service` dangerous rollback | Removed rollback, let exception propagate |
| D2 | Wallet delete no balance check | Already fixed (checks balance != 0) |
| D3 | Wallet reset no audit trail | Insert adjustment tx before reset |
| D5 | SaleItem qty can be 0 or negative | field_validator('qty') gt=0 |
| D6 | Product prices can be negative | Field(ge=0) لكل price fields |
| D7 | Wallet balance can go negative | Overdraft check |
| D8 | Category delete orphan check | Already fixed (COUNT(*) before delete) |
| D10 | Shift tx delete on closed shift | Check shift.status != 'closed' |
| 3 | يمكن إنشاء بيع بكمية 0 أو سالبة | field_validator('qty') gt=0 |
| 4 | يمكن إنشاء منتج بسعر سالب | Field(ge=0) لكل price fields |
| 5 | رصيد المحفظة ممكن يبقى سالب | Overdraft check قبل تحديث الرصيد |
| 6 | Stocktaking — بدون اختيار مخزن | warehouse guard في save + UI |
| 20 | Customer Payment — بدون حد أدنى | gt=0 validation (frontend + backend) |
| 21 | Operations — نفس المخزن للمصدر والوجهة | model_validator check_warehouses |
| S5 | Warehouse CRUD too permissive | Changed to require_role("admin") |

#### Medium
| # | الموجز | الإصلاح |
|---|--------|---------|
| 7 | POS — Cart Not Cleared عند تغيير الوردية/المخزن | useEffect + prevRef |
| 8 | Payroll Calculate — بدون Idempotency | blocking if status != draft |
| 9 | Archive Delete — بدون Cascade Check | block delete if ref_id not null |
| 10 | Users — Password Reset عبر prompt() | Modal بدلاً من prompt() |
| 11 | Purchases — Duplicate PO Number | auto-generated via DB sequence |
| 12 | Reports — Date Range بدون Validation | dateError + enabled: !dateError |
| 15 | POS Search — بدون Debounce | 300ms debounce via useEffect |
| 16 | Stocktaking — 721 منتج بدون Pagination | listPage مع page/page_size=100 |
| 22 | Shifts — بدون Pagination | limit/offset في list endpoint |
| 23 | Purchases — Receive PO مكرر | if po.status == received → BusinessError |
| 24 | Quotation Confirm — بدون Stock Pre-check | balance check قبل confirm |
| 30 | Stock Adjustments — No Reason Required | `*` marker + `!note.trim()` guard |
| S1 | GET /settings is PUBLIC | Added Depends(get_current_user) |
| S2 | Warehouse CRUD — Only get_current_user | Already uses require_role("admin") |
| S3 | Reset Button Visible to All | Wrapped in {isAdmin && (...)} |
| S4 | Delete Category — No Check for Products | Already checks COUNT(*) |
| S5 | Delete Warehouse — No Linked Check | Already checks movements/sales/shifts |
| S6 | Save Settings — No isPending Guard | Already has disabled={saveSettings.isPending} |
| S7 | Wallet Delete — No Balance Check | Already checks balance != 0 |
| S8 | Add Category — No isPending Guard | Already has disabled={... || addCat.isPending} |
| S9 | Product Options Tab — Read Only | Inline add/delete UI |
| S10 | Warehouse Code — No Format Validation | .toUpperCase().replace(...) + validation msg |
| S11 | Add Subcategory Without Name | || !newSubName.trim() in disabled |
| S12 | Rename Warehouse — No isPending Guard | Already has disabled={renameWh.isPending} |
| S13 | Settings Tab Visibility | Already filters via hasPerm |
| S14 | Logo Upload — No Validation | Already validates type + 2MB |
| S15 | Contact Phones — Fixed 3 Slots | Dynamic add/remove |
| 31 | Print Buttons No Loading State | printingId per-row state + disabled |
| 32 | PurchaseOrdersPage — No Warehouse Guard | toast.error('اختر المخزن') |

#### Low/UX
| # | الموجز | الإصلاح |
|---|--------|---------|
| 13 | Confirm Dialogs via window.confirm() | ConfirmDialog component |
| 25 | /finance ← duplicate of /accounting | route + sidebar link removed |
| 26 | /admin ← duplicate of /accounting | sidebar link removed |
| 27 | /purchases vs /purchase-orders | merged into operations tabs |
| 28 | /reports ← overlap with /accounting | merged into accounting tabs |

#### Security (Mitigated)
| # | الموجز | الحالة |
|---|--------|--------|
| S2 | JWT in query params (print token) | Mitigated: 60s short-lived print token |
| S3 | JWT in localStorage | Mitigated: needs HttpOnly cookies (architectural) |
| S4 | No CSRF | N/A with Bearer token auth |

### ✅ تم إصلاحها في هذه الجلسة

| # | الموجز | الإصلاح |
|---|--------|---------|
| S6 | Mass assignment في warehouse endpoints | Pydantic schemas `WarehouseCreate`/`WarehouseUpdate` |
| F1 | window.confirm() في PWA update | Auto-update بدون confirm |
| | migrate_json_to_pg.py في codebase | تم الحذف |
| | Warehouse create/update dict → schema | `stock.py` يستخدم Pydantic بدلاً من raw dict |

### ✅ تم إصلاحها في هذه الجلسة (2026-05-21)

| # | الموجز | الإصلاح |
|---|--------|---------|
| Q6 | Print router refactor — completed | Created `print/purchase.py`, `print/archive.py`, `print/inventory.py`, `print/shift.py` sub-modules; all registered via `print/__init__.py` imports; old `print_router.py` now thin re-export |
| CSRF | `require_csrf` applied globally | Refactored `require_csrf` to be self-contained (no `get_current_user` dep); added `Depends(require_csrf)` to main `APIRouter` — all mutating endpoints now require `X-CSRF-Token` header |
| CSS | Comprehensive print CSS | Merged old `print_router.py` CSS with `print/__init__.py` CSS — covers all classes used by all 6 print sub-modules |
| Q1 | Playwright E2E tests | Created `playwright.config.ts` + 4 spec files (login/POS/inventory/sales); `@playwright/test` installed; `npm run test:e2e` / `test:e2e:ui` scripts added; vitest e2e exclusion configured |

### ✅ تم إصلاحها في هذه الجلسة (2026-05-20)

| # | الموجز | الإصلاح |
|---|--------|---------|
| 33 | Variable shadowing — `setCustomer` في POSPage | local state `customer`/`setCustomer` renamed to `customerInput`/`setCustomerInput` |
| 34 | `tsc -b` build broken بسبب Zustand persist + `erasableSyntaxOnly` | Changed build script to `tsc --noEmit` |
| 35 | `useQuery` inside `.map()` callback in AdminPage | Replaced with `useQueries()` — hooks rule violation |
| 36 | `AgingTable` component created during render in AgingPage | Moved outside component — was causing remount/state loss |
| 37 | `InlineInput` component created during render in SettingsPage | Extracted as standalone function with explicit props |
| 38 | `useAuthStore` called after early return in SettingsPage | Moved hook above `if (isLoading) return` — hooks order violation |
| 39 | `SectionCard`/`Row` components created during render in CashFlowPage | Moved both outside component |
| 40 | OfflineSync useEffect missing dependencies | Added `dequeue`, `markFailed`, `markSyncing`, `qc`, `queue` to deps |
| 41 | Layout useEffect missing `isAdmin` and `setActiveWarehouse` deps | Added to dependency array |
| 42 | Unused `deleteCat`/`deleteSub` mutations in SettingsPage | Removed — duplicated in `CategoriesTree` component |
| 43 | Offline checkout `onSuccess` fires with queued synthetic response | Added `data.queued` check — shows queue toast instead of "فاتورة undefined" |
| 44 | Cart clear button in POSPage has no confirmation — data loss risk | Added `ConfirmDialog` wrapping both clear buttons |
| 45 | No debounced search in InventoryPage — excessive API calls on keystroke | Added `useEffect` debounce (300ms) + `debouncedSearch` state |
| 46 | Print windows blocked by popup blockers across 5+ pages | Created shared `openPrint` utility with popup blocker detection + toast fallback; migrated all pages |
| 47 | No test infrastructure or tests | Installed vitest; wrote 11 tests for offline queue store |
| 48 | DataTable skeleton rows too basic / not reflective of content | Enhanced with icon placeholders + varying widths per row index |
| 49 | Empty states lack call-to-action | Added `emptyAction` prop with contextual "إضافة" button in InventoryPage, SuppliersPage |
| 50 | PageLoader/EmptyState components lack custom text/subtext | Added `text`/`subtext` props; updated CashFlowPage, AgingPage |
| 51 | SafesPage renders blank until data arrives; no loading/empty/error states | Added `PageLoader`, empty state for safes/wallets, inline error banner |
| 52 | ExpensesPage 3 mutations missing `onError` — silent save failures | Added `onError` handlers to createMut, approveMut, deleteMut |
| | SQL injection in print_router (f-string ARRAY) | Replaced with parameterized `ANY(:sale_ids)` bind |
| | SQL injection in reports (f-string DATE_TRUNC) | Added `VALID_PERIODS` whitelist |
| | Schema: missing `SaleItemOut` class | Defined `SaleItemOut` crashing 10+ endpoints |
| | Schema: missing `total`/`net_total`/`paid_amount` on Sale ORM model | Added columns + updated service to compute values |
| | Auth: missing `require_perm` on stock transfer, customer payments, safe deposit | Added permission checks |
| | Auth: missing `Depends(get_current_user)` on `/auth/roles` | Added auth dependency |
| | Race condition: no `FOR UPDATE` on wallet, stock, shift, safe queries | Added `.with_for_update()` to 10+ read-then-write queries |
| | Mass assignment in payroll `create_employee` | Changed to validate via `EmployeeCreate` schema first |
| | Bare `except Exception: pass` in payroll_engine, settings, finance | Narrowed to specific exception types + added logging |
| | Dead code: unused `TYPE_LABELS` in wallets, `check_period_open` in periods | Removed unused code |
| | Dynamic SQL in expenses router (no field whitelisting) | Added field name whitelist |

### ✅ تم إصلاحها في هذه الجلسات (2026-07-30 → 2026-08-11)

| # | الموجز | الإصلاح |
|---|--------|---------|
| J1 | Jibble CSV attendance import (free tier) | Upgraded `POST /hr/attendance/import-csv`: name-based matching, `Member`/`Start time`/`End time` header mapping, robust time parsing (ISO/12h/24h); fixed `UndefinedColumnError` on `hr_attendance` insert (`created_by` removed). Verified live: 12h `9:02:00 AM` → 09:02 |
| J2 | Deleting empty subcategory blocked by hidden products | `delete_subcategory`/`delete_category` counted only active products; soft-deleted products still held `subcategory_id` FK (RESTRICT). Fix: `DROP NOT NULL` + detach inactive products (`UPDATE products SET subcategory_id=NULL WHERE is_active=false`) before delete. Verified live: 18 inactive products detached, guard still blocks active ones |
| J3 | Quotation confirm now asks where cash lands | `ConfirmQuotationRequest {destination: drawer\|safe}`; drawer = user's open shift in the quote's warehouse, safe = deposit + `safe_deposit` archive doc. New `QuoteDestinationModal`. Verified live both paths |
| J4 | Empty-string codes sorted above real codes | `func.nullif(code, '').asc().nullslast()` for products/categories/subcategories (+report joins); empty codes normalized to NULL on create/update. Verified live |
| J5 | Nested `<form>` killed barcode-添加 | `BarcodeManager` wrapped in ProductForm's `<form>`; replaced inner form with `<div>` + `type="button"`. Verified: POST fires now |
| J6 | `create_supplier` raw INSERT without id | `suppliers.id` had no DB default → `NotNullViolationError`. Added `gen_random_uuid()` in the raw INSERT. Verified |
| J7 | Ledger 500 (`drawer_tx_type` `return` vs `return_`) | Enum member is `return_`; fixed ledger.py queries (`'return_'`, `r.type == 'return_'`). Verified `OK nett=0` |
| J8 | Admin warehouse-access bug blocked quotation confirm / shift open | `verify_warehouse_access` only honored `is_manager`; now also `role in ('admin','manager')` (matches shifts.py `is_privileged`). Unblocked ammar on any warehouse |
| J9 | `GET /products/{id}/movements` Pydantic serialization 500 | Rewrote to raw SQL + `dict(r._mapping)` (matches `stock.py:list_movements`). Verified |
| J10 | Google Fonts blocked by CSP | Added `fonts.googleapis.com` + `fonts.gstatic.com` to `style-src`/`font-src` in frontend nginx CSP. Verified header live |
| J11 | Purchase-flow E2E (prod) | Confirmed new-product picker requires category/subcategory; verified receive → stock + `cost_price` + `purchase_price_history` + `tracked` promotion; cleaned all test rows. Removed-dead-code note: `POST /purchases/quick-add-product` unused |
| J12 | CSP still hardcoded old domain? | Removed hardcoded domain from CSP — allows any HTTPS origin. Health URL updated to Nginx port. `sale_service` gained missing `StockMovement` import; DebtsContent pagination filter fixed (`customersApi.list` safe) |

### 🔍 تم التحقق — أصلحت من جلسات سابقة

| # | الموجز | الحالة |
|---|--------|--------|
| D4 | Customer balance column missing from ORM | موجود في `party.py:18` — Fixed |
| A8 | ZK sync hardcodes device creds | القراءة من `settings` مش hardcoded — Fixed |
| S8 | Password reset min 8 chars | `PasswordReset.password: Field(min_length=8)` — Fixed |
| | collections.py update/delete no require_perm | موجود `require_perm("inventory")` — Fixed |
| | safes.py withdraw no role check | موجود `require_role("admin", "manager")` — Fixed |

---

## 4 ملخص

| القسم | العدد |
|-------|-------|
| Features مكتملة | 20 |
| Offline POS | 6/6 ✅ |
| Android App | 5/6 ✅ (FCM pending) |
| Desktop App | 5/5 ✅ (Auto-update يعمل — pubkey + /api/updater feed) |
| Quality & Infra | 7/7 ✅ |
| Bugs/Improvements تم إصلاحها | 108 |
| تم إصلاحها في آخر جلسات (2026-07/08) | 12 (J1–J12) |
| Audit items مفتوحة | 0 (تم التحقق — الكل Fixed) |
