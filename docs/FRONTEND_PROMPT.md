Vendora ERP — World-Class Frontend Engineering & UI/UX Build Prompt
1. Mission

Build Vendora ERP, a production-grade, Arabic-first, RTL business management platform for an Egyptian plumbing and building-supplies company (شركة المصرية الالمانية).

You are acting as a principal frontend engineer, senior product designer, Arabic RTL specialist, and enterprise UX architect.

Your goal is not simply to make the backend accessible through a collection of forms and tables. Your goal is to create a cohesive, fast, beautiful, trustworthy, and exceptionally usable ERP that cashiers, storekeepers, accountants, managers, and administrators can operate confidently throughout a full working day.

The final product must feel like a carefully designed commercial application, not a generic admin template or an AI-generated collection of dashboard cards.

Priorities, in order:

Correctness and data integrity.
Speed and efficiency for real business workflows.
Excellent Arabic RTL usability.
Visual consistency and professional polish.
Accessibility, responsiveness, and offline resilience.
Maintainable architecture and complete feature coverage.

Make thoughtful product decisions independently. Do not stop at a design proposal, wireframe, or list of recommendations. Implement the working frontend, connect it to the real backend, run the available checks, and iterate until the application meets the quality bar.

2. Project Context and Constraints

Vendora is a multi-branch ERP. The backend is complete, tested with 107 end-to-end tests, and deployed.

Repository: github.com/ammar0xff/Vendora
Production API: https://vendora-backend-six.vercel.app/api
OpenAPI documentation: https://vendora-backend-six.vercel.app/api/docs
Local API: http://localhost:8000
Default demo login (both local and production): ammar / changeme (admin; NOTE: intentionally lacks the finance permission — nada / changeme is the accountant with finance).
Behavioral reference: the repository's e2e suite (e2e/api, 107 tests) encodes the real API contracts — read it before implementing any workflow; its test files are per-domain (test_sales.py, test_payroll.py, ...).
Local backend: docker compose up -d
Backend documentation: inspect /docs and the repository's endpoint schemas.
Legacy frontend: inspect Git history for the previous React implementation and reuse useful business logic or verified interaction patterns where appropriate.

Hard constraints:

Build the frontend only.
Do not modify backend code, API schemas, authentication behavior, database structures, or business rules.
Do not invent API endpoints, request fields, response fields, permissions, or workflow states.
Verify actual endpoint contracts before implementing each feature.
Do not replace real functionality with static mock data.
Do not silently ignore failed API requests or pretend mutations succeeded.
Preserve all backend-enforced business rules and validation.
Do not stop after the dashboard or POS. Deliver the complete specified application in incremental, verified phases.
3. Required Technology Stack

Use the repository's planned stack:

React 19
TypeScript with strict type checking
Vite
Tailwind CSS
shadcn/ui with Radix UI primitives
TanStack Query for server state, caching, invalidation, and mutations
Zustand for appropriate client-side state
React Hook Form and Zod where compatible with verified API contracts
React Router for routing and route protection
Lucide icons
A suitable chart library for business analytics
IndexedDB and a TanStack Query persister for offline capabilities
PWA manifest and service worker

Choose compatible, actively maintained dependencies. Avoid unnecessary libraries, duplicated state management, and large dependencies for trivial functionality.

Keep reusable components, feature modules, API clients, validation, formatting utilities, and design tokens separate.

4. Product Design Direction
4.1 Visual identity

Create a refined, modern enterprise interface inspired by high-quality financial software, contemporary POS applications, and thoughtfully designed operations platforms.

The design should communicate:

Trust and financial accuracy.
Operational efficiency.
Clarity under pressure.
Professionalism without unnecessary decoration.
A coherent identity suitable for a real Egyptian business.

Use a restrained visual language:

A warm, neutral light theme with subtle gray surfaces and clear white content panels.
A deep charcoal or midnight-toned dark theme with carefully differentiated surfaces.
One distinctive brand accent, derived from the existing logo if possible.
Semantic colors for success, warning, error, information, and financial states.
Thin borders, subtle shadows, deliberate spacing, and restrained corner radii.
Clear typographic hierarchy, consistent alignment, and generous breathing room.
Tabular numerals for prices, balances, quantities, and financial reports.
Lucide icons with consistent sizing and stroke weight.

Avoid excessive gradients, glassmorphism, decorative blobs, oversized headings, gratuitous animations, excessive rounded cards, and colorful dashboard clutter.

Do not invent a logo if an existing business logo is available. Retrieve the configured logo from the backend where supported and create a polished fallback when unavailable.

4.2 Design tokens first

Establish a centralized design system before implementing individual pages.

Define reusable tokens for:

Background, surface, elevated surface, border, text, muted text, and brand colors.
Semantic success, warning, error, and informational states.
Sidebar, header, popover, dialog, and overlay surfaces.
Spacing, typography, line heights, radii, shadows, and motion.
Focus rings, disabled states, hover states, and selected states.
Light and dark themes.

Use CSS variables and semantic Tailwind utilities. Never scatter arbitrary hex colors throughout components.

Dark mode is the default for the initial application experience, but users must be able to switch themes. Persist their preference and ensure both themes are fully designed, not merely color-inverted.

4.3 Typography and Arabic support

Arabic is the primary language, not a translation added after the interface is designed.

Use a high-quality Arabic-capable font, such as IBM Plex Sans Arabic or Tajawal, with suitable fallbacks.
Set the document direction to RTL and the language to Arabic.
Align navigation, forms, dialogs, tables, breadcrumbs, and icon placement correctly.
Use natural, concise Egyptian business terminology where appropriate.
Preserve readable Arabic labels without clipping or awkward line breaks.
Handle Arabic text alongside Latin usernames, product codes, barcodes, invoice numbers, URLs, and serial numbers.
Use direction-aware CSS properties such as margin-inline-start, padding-inline-end, and logical border properties instead of hard-coded left/right positioning.
Use bidi isolation for mixed-direction identifiers and numeric strings when necessary.
Mirror directional icons when their meaning requires it, but never mirror brand icons or universally understood symbols indiscriminately.
Format dates using the Arabic locale and the Africa/Cairo timezone.
Format Egyptian currency consistently as 1,234.50 ج.م and quantities with sensible precision.

Test realistic Arabic content rather than placeholder English text.

4.4 Motion and feedback

Motion should explain changes, not decorate them.

Use short, restrained transitions.
Animate drawer and dialog entry without delaying interaction.
Provide clear hover, pressed, focused, selected, loading, success, and error states.
Respect reduced-motion preferences.
Avoid layout shifts when loading or showing feedback.
Use skeletons that match the final layout.
5. Application Shell and Navigation

Build a persistent, polished ERP shell.

Sidebar
Right-aligned RTL sidebar, approximately 220–250 px when expanded.
Collapsible to a compact icon rail.
Clear active-route styling with a subtle brand accent.
Group related modules logically.
Support nested routes and expandable groups.
Include meaningful icons, accessible tooltips in compact mode, and readable labels.
Keep the user's current location obvious.
Persist the sidebar's expanded/collapsed preference.
Never show navigation links the user cannot access.

Navigation groups:

الرئيسية
نقطة البيع
المبيعات
المخزون
العمليات
المشتريات
العملاء والموردون
المديونات والمالية
الموارد البشرية
الورديات
الأرشيف
التقارير
الإعدادات
المستخدمون
Header

Include:

Global warehouse/branch selector where relevant.
Global search for products and barcodes.
Current shift status.
Breadcrumbs or a clear page title.
Theme toggle.
User menu with account details, password change, and logout.
Notification access where supported.

On smaller screens, convert the sidebar into a usable navigation drawer and keep essential actions accessible.

Page structure

Every major page should follow a consistent composition:

Breadcrumb or section context.
Page title and concise description when useful.
Primary action placed predictably.
Relevant summary information, only when it helps the task.
Search, filters, and view controls.
Main table, grid, form, or workflow.
Pagination and secondary actions.

Do not force every page into the same card-heavy layout. Use the presentation that best fits the task.

Global search

Support keyboard-accessible product search and barcode lookup using:

GET /products?search=
GET /products/barcode/{b}

Use debouncing where appropriate, sensible result limits, loading feedback, and keyboard navigation. Selecting a product should take the user to the relevant workflow when possible.

6. UX Patterns and Component Standards

Build reusable, production-quality primitives before duplicating page-specific implementations.

Data tables

Create a consistent data-table system supporting:

Server-side pagination and search.
Sortable columns where the API supports sorting.
Filters and date ranges.
Column alignment appropriate to Arabic and numeric data.
Sticky headers when useful.
Responsive overflow without breaking the page.
Row selection only where bulk actions exist.
Clear row actions and predictable action menus.
Loading skeletons, empty states, and recoverable error states.
Excel export where supported.
Persistent filters when navigating into a detail page and back, where practical.

Financial tables must align numeric columns consistently and make totals easy to verify.

Never hide critical information behind hover-only interactions.

Forms
Use clear Arabic labels, concise helper text, and inline validation.
Distinguish required and optional fields.
Group related fields into logical sections.
Use sensible defaults only when supported by business rules.
Use searchable selects for long customer, supplier, warehouse, and product lists.
Support keyboard navigation and appropriate focus order.
Prevent accidental duplicate submissions.
Preserve entered values when safe after recoverable failures.
Focus the first invalid field and explain how to correct it.
Require explicit confirmation for destructive or irreversible actions.
Avoid giant forms. Use drawers, tabs, sections, or step-by-step flows when they materially improve usability.
Drawers and dialogs

Use right-side drawers for quick create/edit workflows and centered dialogs for confirmations or focused decisions.

Keep context visible when editing a record from a list.
Prevent accidental dismissal while a mutation is actively processing when losing the form would be harmful.
Trap focus and restore it after closing.
Support Escape when safe.
Keep destructive actions visually distinct.
Do not nest multiple dialogs unnecessarily.
Notifications and error handling

Create one consistent Arabic toast and inline-feedback system.

Success messages must confirm actual successful operations.
Business errors must display the backend's Arabic message.
Network failures must explain that the operation could not be completed.
Validation errors must map to their corresponding fields when possible.
Conflict errors must offer a clear next step.
Retryable queries must have a visible retry action.
Do not expose stack traces, raw HTML, or internal implementation details.
Empty, loading, and error states

Every list, dashboard section, detail page, and asynchronous workflow must handle:

Initial loading.
Background refresh.
Empty results.
Failed requests.
Partial data.
Successful mutations.
Permission denial.
Offline or reconnecting states when relevant.

Empty states should tell the user what the screen is for and, when authorized, offer a useful next action.

7. Money, Dates, Quantities, and Data Integrity

These rules are mandatory throughout the application.

Monetary calculations

The backend represents money as strings, for example "48.00".

Never use JavaScript floating-point arithmetic for financial calculations.
Use a decimal-safe library or integer minor units where appropriate.
Preserve decimal precision through line totals, discounts, payments, credit balances, and change.
Match the backend's rounding and validation rules.
Keep display formatting separate from calculation values.
Never mutate or submit formatted currency strings as raw monetary values.
Reconcile split payments and totals explicitly before checkout.
Quantities and stock

Use precision appropriate to the product's unit. Do not assume every product is sold as an integer quantity.

Clearly distinguish tracked from untracked stock and unavailable inventory.

Dates
Display dates in a consistent Arabic format.
Interpret business dates in Africa/Cairo.
Avoid accidental UTC conversions that change the displayed business date.
Keep API serialization consistent with the actual endpoint contract.
Server state
Use TanStack Query for all remote state.
Set appropriate stale times and cache invalidation rules.
Invalidate or update related queries after mutations.
Avoid stale balances, stock, and financial summaries after successful writes.
Handle cancellation and concurrent operations safely.
8. Authentication, Permissions, and API Client
Authentication

POST /auth/login accepts { username, password }, returns an access token and user information, and sets an HttpOnly access_token cookie.

Support both deployment modes:

Same-origin cookie mode

Send requests with credentials: 'same-origin'.
For POST, PUT, PATCH, and DELETE, echo the readable csrf_token cookie in the X-CSRF-Token header.
Do not attempt to read the HttpOnly access-token cookie.
Follow the backend's actual CSRF behavior.

Cross-origin bearer mode

Send Authorization: Bearer <access_token>.
Use bearer authentication for the configured cross-origin deployment.
CORS allowlist (backend Settings.CORS_ORIGINS): http://localhost:5173,
http://localhost:3000, http://localhost, https://eg-co.duckdns.org,
https://ammar0xff.github.io. A frontend hosted on any OTHER origin will be
blocked in this mode — either host same-origin (served by the backend), host on
an allowlisted origin (e.g. GitHub Pages), or have the origin added to
CORS_ORIGINS before deploying. Cookie mode does not apply cross-origin (the
access_token cookie is SameSite=lax), so Bearer is the only cross-origin option.
Follow the actual API and hosting CORS contract.

Centralize configuration using environment variables. Never hard-code credentials or tokens.

Implement a typed API client with:

Correct base URL handling.
Authentication headers and credentials.
Consistent JSON and multipart handling.
Error normalization.
Support for binary downloads and HTML/PDF responses.
Request cancellation where appropriate.
Correct handling of 401, 403, 409, and 422.
Safe session expiration and redirect behavior.

Use /auth/me as the authoritative session source:

GET /auth/me returns { id, username, full_name, role, permissions[], is_manager, default_warehouse_id }.

Cache the authenticated user and derive navigation and route access from the returned permissions.

Roles and Arabic labels:

admin — مدير عام
manager — مشرف
cashier — كاشير
storekeeper — أمين مخازن
accountant — محاسب

Feature permissions:

pos, sales, quotations, inventory, operations, purchases, customers, reports, archive, payroll, users, settings, admin, shifts, finance.

Important: Admin does not automatically have the finance permission. Never infer permissions from role names.

The frontend is responsible for usability, not security enforcement. The backend remains authoritative.

9. Core User Experience: The POS

The point-of-sale screen is the most important interface in the application.

Design it around the real environment: a busy cashier, frequent barcode scans, Arabic product names, rapid payment handling, and limited tolerance for unnecessary clicks.

Layout

On supported desktop and tablet widths:

Right side: product search, barcode input, categories, and product results.
Left side: persistent cart, discounts, totals, customer information, and payment workflow.
Keep the cart and final total visible while browsing products.
Give barcode input reliable keyboard focus.
Keep primary actions visually obvious and reachable.
Make the interface usable at 1024 px and wider.

Use a compact, readable product grid with product names, prices, relevant units, and stock information when appropriate. Product imagery should help identification, not dominate the layout.

Barcode workflow
Automatically recognize scans in the barcode field.
Add a matching product to the cart immediately.
Increment quantity on repeated scans when appropriate.
Handle unknown barcodes with a clear, non-disruptive message.
Avoid losing focus after adding products.
Prevent keyboard shortcuts from firing while the user is typing in an unrelated field.
Cart

Support:

Increment/decrement quantity.
Direct quantity editing.
Per-item discount and notes.
Item removal.
Retail/wholesale pricing.
Customer selection when needed.
Subtotal, discounts, and final total.
Clear distinction between unit price and line total.

Updates must be immediate and deterministic. Prevent negative quantities and invalid discounts before submission, while still respecting server-side validation.

Payments

Support all backend-supported combinations:

Cash.
Card.
Wallet.
Split payments, including cash + card and cash + credit.
Credit sales with customer selection and credit-limit warnings.

Load available wallets from GET /wallets. Retrieve customer credit information from GET /customers/{id}/account.

Show the remaining amount due and any change clearly. Prevent checkout when the payment state is invalid.

Shift requirement

Check GET /shifts/current.

If no open shift exists, show a focused workflow to open one using:

POST /shifts/open { warehouse_id, initial_amount }.

Explain the requirement in Arabic and return the user to the POS after a successful opening.

Hold and resume
Support holding and resuming bills.
Load server-side drafts using GET /sales/drafts.
Save drafts using POST /sales/draft.
Support local held bills where appropriate.
Clearly distinguish local-only drafts from server-persisted drafts.
Checkout

Checkout must feel deliberate, fast, and safe:

Review the final total.
Select the payment method and validate the amount.
Submit exactly once.
Show progress without allowing duplicate submission.
Handle backend rejection without losing the cart.
On success, show the invoice number and available receipt actions.
Reset the completed cart only after confirmed success.

Use the verified sale-print endpoint and open server-rendered documents in a new tab or window.

Keyboard shortcuts

Implement and document:

F2 — focus/open payment.
Escape — clear or dismiss according to the current context, with confirmation if a non-empty cart would be lost.
A predictable shortcut for focusing barcode search.
Enter and arrow-key navigation where appropriate.

Do not intercept browser or input shortcuts unnecessarily.

Returns

Support full and partial returns from an existing sale using the verified endpoints:

POST /sales/{id}/partial-return
POST /sales/{id}/return

Show the original invoice, eligible quantities, returned quantities, and resulting amounts. Require confirmation and explain validation errors.

10. Dashboard

Build an actionable business overview, not a wall of decorative statistics.

KPI section

Use real data from:

GET /reports/sales/daily
GET /reports/sales/monthly
GET /shifts/current
GET /stock/low-stock
GET /wallets/summary
GET /safes
GET /admin/overview for authorized administrators.

Prioritize today's sales, monthly sales, open shift status, low-stock alerts, and cash/wallet balances.

Use comparison indicators only when a valid comparison period exists. Never invent growth percentages, targets, or financial trends.

Analytics
Sales chart covering the previous 14 days.
Top-selling products from GET /reports/sales/top-products.
Latest 10 sales from GET /sales.
Useful low-stock alerts.
Quick actions based on the user's permissions.

Make chart labels, tooltips, empty states, and currency formatting Arabic-aware. Ensure charts remain readable in both themes.

The dashboard should answer three questions immediately:

How is the business performing?
What needs attention?
What should I do next?
11. Complete Feature Requirements

Implement all routes and features below. Verify the exact API request and response schemas before implementation. Use shared page templates where useful, but do not compromise task-specific usability.

11.1 Login — /login
Centered, polished Arabic login experience.
Business logo from GET /settings when available.
Username and password inputs.
Show/hide password control.
Clear pending, invalid-credentials, and network-error states.
Display backend Arabic error messages.
Redirect to the application after successful authentication.
Avoid exposing credentials or tokens in logs.
11.2 Sales and quotations — /sales

Permission: sales.

Filters for date range, warehouse, cashier, status, and credit-only sales.
Invoice number, date, customer, total, paid amount, and status.
Sale detail page with items, payments, and profit when authorized.
Print, cancel, return, and supported item editing.
Quotations tab and quotation confirmation workflow.
Preserve list context when returning from details.

Use verified endpoints, including PUT /sales/{id}/cancel, item-edit endpoints, quotation creation, and quotation confirmation.

11.3 Products — /products

Permission: inventory.

Searchable product table with images and category filters.
Retail, wholesale, and cost prices, respecting permissions.
Tracked/untracked stock indicators and active status.
Create/edit drawer with product options from GET /settings/product-options.
Multiple barcode management.
Product image upload.
Stock movement history.
Product movement between supported locations.
Per-warehouse stock breakdown.

Use the verified /products, /barcodes, and /stock endpoint contracts.

11.4 Categories — /categories
Two-pane category and subcategory management.
Clear selection and hierarchy.
Create, edit, and delete with safe confirmations.
Empty states and inline validation.
No drag-and-drop requirement.
11.5 Inventory — /inventory

Permission: inventory.

Tabs:

Stock balances and stock valuation.
Low-stock monitoring and configured thresholds.
Bulk stock adjustments.
Inter-warehouse transfers.
Dispatch workflow and printable dispatch documents.
Stocktaking helper comparing counted and system quantities.
Warehouse CRUD for authorized administrators.

Use the verified stock balance, valuation, low-stock, adjustment, transfer, dispatch, and warehouse endpoints.

Always make the active warehouse clear.

11.6 Operations — /operations

Permission: operations.

Provide workflows for:

Dispatch — صرف.
Goods receipt — استلام.
Stock requests.
Operations history.

Each workflow needs an appropriate form, validation, confirmation, success state, and print preview.

11.7 Purchases — /purchases

Permission: purchases.

Purchase-order list and creation.
Supplier, warehouse, items, cost, and quantity.
Receive-purchase workflow.
Supplier invoice image upload.
Supplier-price comparison by product.
Product purchase-price history chart.
Reorder suggestions.
Quick-add product workflow.

Clearly distinguish ordered, received, and outstanding quantities wherever the backend provides that information.

11.8 Customers and suppliers

Routes: /customers and /suppliers.

Use the relevant verified permission rules for each module.

Searchable lists and CRUD.
Detail pages with profile, balance, and ledger.
Customer payments and supplier transactions.
Supported balance adjustments.
Credit-limit fields and warnings.
Aging information from /reports/aging.

Make financial history easy to scan and keep balance-changing actions explicit.

11.9 Collections — /collections
Collection/bundle catalog.
Create, edit, and delete.
Availability checking.
Clear product composition and availability status when supported by the API.
11.10 Expenses — /expenses

Permission: finance.

Expense list and filters.
Expense creation with amount, category, vendor, payment method, and destination.
One-time and recurring expense configuration.
Recurrence interval and end date where supported.
Approval workflow.
Summary cards.

Use /financial-categories, /expense-vendors, expense endpoints, and GET /expenses/summary.

11.11 Safes and wallets — /finance/cash

Permission: finance.

Safe cards and balances.
Deposit, withdrawal, and transfer workflows.
Transaction history.
Wallet balances and history.
Supported wallet balance reset.

Label wallet types clearly, including فودافون كاش and انستاباي where configured.

Show confirmation and resulting balance only after the server confirms the operation.

11.12 Ledger and statements — /finance/ledger

Permission: finance.

Tabs:

General ledger.
Periodic ledger.
Daily ledger items.
Profit and loss.
Cash flow.
Receivables/payables aging.
Accounting periods.

Use the verified financial ledger and report endpoints.

Accounting periods:

List periods.
Close a period.
Reopen a period when authorized and supported.

When a closed period blocks a write, display the backend's Arabic explanation and prevent misleading retry behavior.

11.13 Employees and attendance — /hr

Permission: payroll.

Employee CRUD.
Shift management.
Attendance table with supported edits and excuses.
CSV attendance import.
ZK device synchronization and sync logs.
HR settings.
Employee advances.
HR audit log.

Import and sync workflows need progress, completion summaries, and actionable failure states.

11.14 Payroll — /hr/payroll

Permission: payroll.

Month picker.
Payroll calculation.
Per-employee breakdown.
Manual bonuses and deductions.
Workflow stepper: draft → submit → approve → pay.
Reopen only when supported by backend rules.
Monthly payroll report.
Individual payslip tickets.

Make workflow status and the next permitted action obvious. Confirm payroll submission, approval, and payment actions.

11.15 Shifts — /shifts

Permission: shifts.

Current shift overview.
Open shift when required.
Cash transactions.
Shift closure.
Manager-assisted close when a discrepancy requires it.
Revenue delivery to a safe.
Custodian handover with printable document.
Shift summary and printable report.

Clearly distinguish expected cash, counted cash, and discrepancies where returned by the API.

11.16 Archive — /archive

Permission: archive.

Search archived documents.
Filter by type, date, and warehouse.
View invoice, purchase-order, dispatch, handover, inventory, and shift documents where supported.
Detail page with print and PDF actions.
11.17 Reports — /reports

Permission: reports.

Tabs for:

Daily and monthly sales.
Sales by cashier.
Top products.
Profit.
Inventory print.
Ledger.
Cash flow.
Aging.

Every report should provide relevant filters, an appropriate visualization or table, print functionality, and Excel export where supported.

Never fabricate missing data or calculate unauthorized financial metrics on the client.

11.18 Audit log — /audit-log

Permission: admin.

Search and filter by user, action, entity, and date where supported.
Display who performed the action and when.
Show old and new values in a readable diff.
Use a dedicated detail view for complex changes.
11.19 Users and permissions — /users

Permission: users.

User CRUD.
Password reset.
Role assignment.
Per-feature permissions.
Per-warehouse access.
Manager selection where supported.

Use /permissions/{id}, /users/{id}/warehouses, and /users/managers.

Clearly show the effect of permission changes. Never infer that selecting an administrator role automatically grants finance access. Respect server-side self-deletion restrictions.

11.20 Settings — /settings

Permission: settings.

Tabs or sections for:

Store name, address, phones, currency, paper size, and low-stock threshold.
Logo upload.
Product option management.
Storefront theme.
Storefront theme ZIP import.
Live storefront preview using the PUBLIC catalog endpoints GET /store/products, /store/products/{id}, /store/categories (public-safe fields only — no cost/profit).
Storefront editors for the data that already exists in store_settings: theme_primary, theme_accent, theme_bg, font_heading, font_body, storefront_template, storefront_hero_title, storefront_hero_subtitle, storefront_tagline, storefront_sections (ordered homepage sections), storefront_menu, storefront_socials, storefront_posts, store_hours, store_map_url. The imported custom ZIP template is served by GET /settings/storefront-theme (public, returns {imported, html, ...}); import via POST /settings/storefront-theme/import, remove via DELETE.
Notification configuration.

Use unsaved-change indicators and explicit save/cancel actions. Avoid silently overwriting settings.

11.21 Notifications

Use the verified /notifications/* endpoints.

Device token registration and removal.
Notification token listing.
Authorized push-notification sending.

Explain permission requirements and notification failures in Arabic.

12. Printing, Exports, and Documents

Printing is a core ERP workflow.

Prefer backend-rendered HTML and PDF documents over recreating financial documents in React.
Open supported print documents in a new tab or window.
Preserve the authenticated session where required.
Handle blocked popups and failed document requests.
Use short-lived, scoped print tokens for unauthenticated sharing where supported.
Provide print and PDF actions only when supported by the actual endpoint.
Include Excel export buttons on eligible lists.

The backend includes server-rendered document routes such as /print/sale/{id}, /print/shift/{id}, /print/archive/{id}, and corresponding PDF variants where available. Verify the actual route contract; do not assume every page has identical routes.

For downloads, use correct content types, filenames, and browser download behavior. Never treat an HTML error response as a successful PDF or Excel download.

13. Offline POS and PWA

Offline functionality is required for the POS and must be implemented carefully.

Cache strategy
Cache the application shell.
Use IndexedDB for persisted product/search data and queued operations.
Persist suitable TanStack Query data.
Avoid caching authenticated or financial responses indiscriminately.
Define clear cache invalidation and user/session isolation.
Never expose one user's cached data to another user on a shared terminal.
Offline POS

When disconnected, support the explicitly required workflows:

Search cached products.
Build and edit a bill.
Open a local shift ONLY as clearly-labeled client state when offline — the backend has NO offline-shift endpoint; on reconnect the cashier must open a real shift via POST /shifts/open before offline sales can sync. Never present a local shift as a server-recognized shift.
Queue unsynced sales in IndexedDB.
Show queued sales and synchronization status.
Replay queued operations after reconnecting.
Surface conflicts, including HTTP 409 and 400 responses, for manual resolution.

Critical: Never imply that an offline sale has been accepted by the backend before the server confirms it.

Clearly distinguish:

Saved locally.
Waiting to synchronize.
Synchronizing.
Successfully synchronized.
Failed or conflicted.

Prevent duplicate replay, preserve the original sale payload, and define idempotency behavior only if supported by the backend contract.

If offline shift opening or sale submission requires server state that is not available, communicate the limitation rather than inventing backend behavior.

Installable PWA requirements:

Valid manifest.
App icons using available brand assets.
Appropriate standalone display mode.
Service worker lifecycle and update handling.
Offline fallback.
Clear offline/online indicators.
Safe logout and cache cleanup behavior.
14. Routing, Architecture, and Code Quality

Organize the code by feature rather than building a giant application component.

Suggested structure:

app/ — router, providers, application initialization.
components/ui/ — shared UI primitives.
components/layout/ — shell, sidebar, header, breadcrumbs.
features/auth/
features/dashboard/
features/pos/
features/sales/
features/products/
features/inventory/
features/operations/
features/purchases/
features/customers/
features/suppliers/
features/finance/
features/hr/
features/shifts/
features/archive/
features/reports/
features/users/
features/settings/
lib/api/ — API client, error normalization, endpoint modules.
lib/formatting/ — money, quantity, dates, bidi utilities.
lib/validation/
lib/storage/ — IndexedDB and persistence.
lib/permissions/
styles/ — tokens and global styles.

Create typed endpoint functions and reusable query/mutation hooks. Avoid any, duplicated request logic, massive components, and fragile implicit coupling.

Lazy-load feature routes where practical.

Use a consistent URL and query-parameter strategy for search, filters, tabs, and pagination when it improves navigation and shareability.

15. Permission-Aware Navigation and Route Protection
Fetch the current user from /auth/me.
Build navigation from the returned permissions.
Protect routes and individual actions.
Handle loading the session without flashing unauthorized pages.
Redirect unauthorized users to an appropriate accessible page.
Show a useful Arabic access-denied state when needed.
Do not rely on hidden buttons as a security mechanism.
Keep frontend behavior consistent with backend authorization.

A user with access to one feature must not automatically receive access to another feature with similar naming.

16. Accessibility and Responsive Behavior

Target WCAG 2.2 AA where practical.

Semantic HTML.
Proper labels and accessible names.
Full keyboard operation.
Visible focus indicators.
Sufficient contrast in both themes.
Screen-reader announcements for important status changes.
Correct dialog focus management.
Reduced-motion support.
No information conveyed by color alone.
Usable error summaries.
Touch targets appropriate for tablets.
Avoid horizontal overflow except in intentionally scrollable tables.

Desktop is the primary target for most administrative pages. The POS must work particularly well on tablets at 1024 px and wider.

Make mobile behavior deliberate rather than simply shrinking the desktop layout.

17. Performance
Keep initial bundle size reasonable.
Lazy-load heavy reports, charts, and infrequently used features.
Debounce appropriate search fields.
Use server-side pagination rather than downloading entire datasets.
Avoid repeated API requests and unnecessary rerenders.
Use optimistic updates only when rollback and consistency are safe.
Use virtualization only when real dataset sizes justify it.
Optimize image loading and preview behavior.
Keep POS interactions responsive during background requests.
Avoid unnecessary animations and layout shifts.
18. Testing and Verification

The work is not complete until the actual implementation has been verified.

Required checks
tsc --noEmit passes.
ESLint reports zero errors.
npm run build succeeds.
Existing backend code remains untouched.
The application starts locally using the documented workflow.
Production API configuration is correct.
No secrets or credentials are committed.
Functional test coverage

Test at minimum:

Login success, invalid credentials, and session restoration.
Permission-aware navigation and direct route access.
Arabic RTL layout in both themes.
Product search and barcode behavior.
Decimal-safe money calculations.
POS discounts, split payments, credit sales, and duplicate-submit prevention.
Open-shift requirements.
Sale success, failed checkout, and printing.
Inventory adjustments and transfers.
Customer/supplier financial workflows.
Finance permission isolation.
Payroll workflow permissions and state transitions.
Pagination, filters, empty states, and API errors.
PWA installation and offline state indicators.
Offline sale queue replay and conflict handling.

Use mocked responses only in isolated tests. Production application screens must use the real API.

Do not claim an endpoint or workflow works merely because its UI renders.

19. Implementation Plan

Build in small, verifiable phases.

Phase 1 — Foundation
Inspect repository, API docs, old frontend, and package scripts.
Create the frontend/ application.
Establish design tokens, Arabic typography, RTL behavior, dark/light themes, and shared primitives.
Implement the API client, session handling, permission model, routing, and application shell.
Implement login, logout, password change, and not-found/access-denied states.

Exit criteria: the app builds, login works against the real API, session restoration works, and authorized navigation is correct.

Phase 2 — Dashboard and shared data infrastructure
Implement typed query hooks and reusable data tables.
Implement dashboard KPIs, chart, recent sales, and low-stock alerts.
Verify currency, date, and error formatting.

Exit criteria: all visible dashboard data is API-backed and handles loading, empty, and failure states.

Phase 3 — POS
Build barcode-first product selection and cart.
Implement discounts, retail/wholesale pricing, payments, credit warnings, shift enforcement, drafts, and printing.
Add keyboard shortcuts and duplicate-submit prevention.

Exit criteria: a complete sale workflow works against the real backend and all financial calculations are verified.

Phase 4 — Products, categories, inventory, and operations
Implement catalog management, stock balances, adjustments, transfers, warehouses, dispatch, receipt, and stocktaking.
Phase 5 — Sales, quotations, purchases, customers, suppliers, and collections
Complete transaction history, detail pages, document workflows, and financial account views.
Phase 6 — Finance
Implement expenses, safes, wallets, ledger, reports, and accounting periods.
Validate all finance-specific permissions and closed-period behavior.
Phase 7 — HR, payroll, and shifts
Implement attendance, employees, payroll state transitions, shift closure, revenue delivery, and handovers.
Phase 8 — Reports, archive, audit, users, and settings
Complete all remaining modules, exports, print actions, permissions management, and configuration.
Phase 9 — PWA, offline POS, and hardening
Implement offline persistence, queued operations, synchronization recovery, and installation behavior.
Test realistic failure cases.
Resolve TypeScript, lint, build, accessibility, and UX defects.
Perform a final visual consistency pass across every module.

At each phase, keep the app runnable and avoid accumulating broken placeholder screens.

20. Definition of Done

The finished product must satisfy all of the following:

Every specified module has a functional, navigable implementation.
API integrations use verified endpoint contracts.
The backend is unchanged.
Permissions govern navigation and actions correctly.
Arabic RTL is correct throughout the application.
Light and dark themes are both polished.
POS is fast, keyboard-friendly, and reliable.
Financial arithmetic is decimal-safe.
Every list has loading, empty, error, and retry states.
Destructive actions and financial transitions are handled safely.
Print and export actions work where the backend supports them.
Offline functionality accurately represents synchronization status.
The interface is responsive and accessible.
TypeScript, lint, and production build checks pass.
No important route is an empty page, nonfunctional mockup, or dead-end placeholder.
21. Final Instructions to the Implementing Agent

Before coding, inspect the repository and understand the actual API.

During implementation:

Make design decisions instead of asking for approval on every detail.
Prioritize real workflows over decorative polish.
Reuse components without forcing unrelated screens into identical layouts.
Use realistic Arabic content.
Validate API behavior rather than guessing.
Fix root causes instead of hiding errors.
Keep changes incremental and the application runnable.
Do not claim completion without running available checks.
Do not stop after the first successful build.
Review the application visually and functionally, then improve weak areas.

For every screen, ask:

Can the user understand its purpose within seconds?
Is the primary action obvious?
Can the task be completed with minimal unnecessary clicks?
Are financial values and operational states unambiguous?
Does the interface behave correctly in Arabic RTL and both themes?
Are loading, failure, empty, and success states handled?
Does the page feel like part of one coherent product?

The ultimate goal: Vendora should feel like a premium, production-ready ERP built specifically for an Egyptian business: fast enough for a busy cashier, clear enough for a storekeeper, trustworthy enough for an accountant, and powerful enough for a manager — with a consistent design quality across the entire application, not just the dashboard.