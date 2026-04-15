
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔴 CRITICAL

1. Race Condition in Stock Sales (POS)
- **Type:** Logic / Data
- **Problem:** create_sale reads balance → validates → then deducts. Two simultaneous sales of the same product can 
both pass validation and both deduct, going negative.
- **Fix:** Add SELECT ... FOR UPDATE in get_balance when called from sale creation, or use a DB-level constraint 
CHECK (qty >= 0) on computed balance.

2. Double Commit in create_sale — Partial Data Risk
- **Type:** Data / API
- **Problem:** create_sale does commit() after creating the sale, then commit() again after archiving. If the second 
commit fails, sale exists in DB but not in archive. Also if record_movement throws after db.add(sale), the session is
dirty with no rollback.
- **Fix:** Wrap entire create_sale in a single transaction, commit once at the end.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟠 HIGH

3. No Validation on Sale Item qty — Can Be 0 or Negative
- **Type:** Data / Security
- **Problem:** SaleItemCreate.qty: Decimal has no gt=0 constraint. A crafted request with qty=0 or qty=-5 would 
create a sale that adds stock instead of deducting it.
- **Fix:**
python
from pydantic import field_validator
qty: Decimal
@field_validator('qty')
def qty_positive(cls, v):
    if v <= 0: raise ValueError('qty must be > 0')
    return v


4. Product Can Be Created With Negative Price
- **Type:** Data
- **Problem:** retail_price: Decimal = 0 — no minimum. A product with retail_price = -100 would give customers money.
- **Fix:** Add ge=0 to all price fields in ProductCreate.

5. Wallet Balance Can Go Negative
- **Type:** Logic / Data
- **Problem:** wallet_service does balance + :amt with no check when amt is negative (expense/withdrawal). No guard 
against overdraft.
- **Fix:** Add check before update:
python
if amount < 0:
    current = await get_wallet_balance(db, wallet_id)
    if current + amount < 0:
        raise BusinessError("رصيد المحفظة غير كافٍ")


6. Stocktaking Save — No Warehouse Selected Guard on Mobile
- **Type:** Logic
- **Problem:** On mobile, saveAll() checks activeWarehouseId but the floating save button appears before warehouse is
selected (pendingCount > 0 check runs before warehouse check).
- **Fix:** Disable the save button if !activeWarehouseId.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟡 MEDIUM

7. POS — Cart Not Cleared on Page Navigation
- **Type:** Data / UX
- **Problem:** If user navigates away mid-sale and comes back, cart is still there (Zustand persisted). But the shift
might have changed or closed. No validation that the current shift matches the cart's warehouse.
- **Fix:** On POS mount, validate shift is still open and matches warehouse. Clear cart if mismatch.

8. Payroll Calculate — No Idempotency Warning
- **Type:** UX / Logic
- **Problem:** Clicking "حساب الرواتب" multiple times recalculates and overwrites. No warning if payroll was already 
approved/paid.
- **Fix:** Check status before recalculating — block if status = 'paid'.

9. Archive Delete — No Cascade Check
- **Type:** Data
- **Problem:** Deleting an archive document doesn't check if it's referenced elsewhere (e.g. a shift handover 
document that's linked to a shift).
- **Fix:** Add confirmation with document type info, or soft-delete only.

10. Users Page — Password Reset via prompt()
- **Type:** Security / UX
- **Problem:** Password is entered via browser prompt() — visible in plain text, no confirmation field, no strength 
requirement beyond 4 chars.
- **Fix:** Use a proper modal with password + confirm fields.

11. Purchases — No Duplicate PO Number Check
- **Type:** Data
- **Problem:** No unique constraint or check on po_number at the application level (only DB sequence). Rapid double-
click on "فاتورة مشتريات جديدة" could create duplicates.
- **Fix:** The submit button already has isPending guard — verify it's applied correctly.

12. Reports Page — Date Range Not Validated
- **Type:** Logic
- **Problem:** fromDate > toDate is not validated — returns empty results silently with no error message.
- **Fix:** Add frontend validation: if from > to, show error.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🔵 LOW / UX

13. Confirm Dialogs Using window.confirm()
- **Type:** UX
- **Problem:** All delete/destructive actions use confirm() — blocks the UI thread, looks unprofessional, can't be 
styled.
- **Fix:** Replace with a proper confirmation modal component.

14. Ledger Edit — No Optimistic Lock
- **Type:** Data
- **Problem:** Two managers editing the same sale item simultaneously — last write wins silently.

15. POS Search — Barcode Scan Fires on Every Keystroke
- **Type:** Performance
- **Problem:** handleBarcodeSearch fires on Enter but the product list re-fetches on every character change with no 
debounce.
- **Fix:** Add 300ms debounce on search input.

16. Stocktaking — 721 Products Loaded at Once
- **Type:** Performance
- **Problem:** All products fetched in one request with no pagination. With 721+ products, this is a large payload on
every page load.
- **Fix:** Add virtual scrolling or pagination.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━





---

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🔴 CRITICAL

17. Dispatch Order — No Stock Balance Check
- **Type:** Logic / Data
- **Problem:** dispatch_order creates transfer_out movements without checking if the source warehouse has enough 
stock. You can dispatch 1000 units from a warehouse with 0 units — stock goes negative.
- **Fix:** Add balance check before each transfer_out:
python
balance = await get_balance(db, item.product_id, data.from_warehouse_id)
if balance < item.qty:
    raise BusinessError(f"رصيد غير كافٍ: {prod.name} — متاح {balance}")


18. Delete Drawer Transaction — No Closed Shift Check
- **Type:** Logic / Data
- **Problem:** Admin can delete a transaction from a closed shift, retroactively changing the shift's financial record
after it was signed off by a manager.
- **Fix:** Check shift status before deleting:
python
shift = get shift for this tx
if shift.status == 'closed':
    raise HTTPException(400, "لا يمكن حذف معاملة من وردية مغلقة")


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟠 HIGH

19. Safe Transfer — Can Transfer to Same Safe
- **Type:** Logic
- **Problem:** No check preventing from_safe == to_safe. Balance stays the same but two transactions are recorded (
phantom money).
- **Fix:** Add if from_safe_id == to_safe_id: raise HTTPException(400, "لا يمكن التحويل لنفس الخزنة")

20. Customers — Payment Amount Not Validated
- **Type:** Data
- **Problem:** Customer debt payment has no minimum amount check. You can submit amount = 0 or negative, which would 
increase the customer's debt.
- **Fix:** Add if payAmount <= 0 check on frontend + backend.

21. Operations — Same Source/Destination Warehouse
- **Type:** Logic
- **Problem:** Can create a dispatch from warehouse A to warehouse A — stock goes out and back in, net zero but 
creates fake movement records.
- **Fix:** Validate from_warehouse_id != to_warehouse_id on backend.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟡 MEDIUM

22. Shifts Page — No Pagination on History
- **Type:** Performance
- **Problem:** Shifts history loads all shifts with no limit — in a busy store after months of operation this could 
be thousands of records.

23. Purchases — Receive PO Doesn't Check if Already Received
- **Type:** Logic
- **Problem:** A PO with status = 'received' can be received again if the button is clicked twice rapidly (before 
status updates).
- **Fix:** Backend should check if po.status != 'draft': raise error.

24. Quotation Confirm — No Stock Pre-check on Frontend
- **Type:** UX
- **Problem:** Confirming a quotation deducts stock but the user gets no warning if stock is insufficient until after
the API call fails.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


> Now I have the full picture. Here are the duplication and forgotten page issues:


## 🔴 DUPLICATE PAGES — Confusing to Users

25. /finance = /accounting → "الميزان المالي" tab (EXACT DUPLICATE)
- **Type:** UX / Duplication
- **Problem:** FinanceLedgerPage (/finance) and FinanceLedgerContent inside AccountingPage (/accounting) call the 
exact same API (/financial-ledger) with the same logic. User sees "الميزان المالي" in sidebar AND inside الحسابات tab
— same data, two places.
- **Fix:** Remove /finance route and sidebar link. Keep only the tab inside /accounting.

26. /admin = /accounting → "لوحة التحكم" tab (DUPLICATE)
- **Type:** UX / Duplication
- **Problem:** AccountingPage imports AdminPage directly as its first tab "لوحة التحكم". So /admin and /accounting 
show the exact same dashboard. User has two sidebar links showing the same thing.
- **Fix:** Remove /admin route from sidebar (keep the route for direct access but remove the nav link). The 
accounting page already has it.

27. /purchases vs /purchase-orders — Same Icon, Confusing Names
- **Type:** UX
- **Problem:** Both show "المشتريات" section with same ShoppingBag icon. /purchases = view/receive invoices, 
/purchase-orders = smart reorder suggestions. Users can't tell the difference from the sidebar.
- **Fix:** Rename /purchase-orders label to "اقتراحات الشراء 🤖" (already done) but change the icon to something 
distinct like Lightbulb or Sparkles.

28. /reports vs /accounting → "تقارير المبيعات" tab (OVERLAP)
- **Type:** UX / Duplication
- **Problem:** /reports page has P&L, revenue charts. /accounting has a "تقارير المبيعات" tab with similar data. 
Users don't know which to use.
- **Fix:** /reports should be removed from sidebar and merged into /accounting. Or clearly differentiate: /reports = 
operational daily reports, /accounting = financial statements.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟠 FORGOTTEN PAGES WITH ISSUES

29. /shifts Page — No Delete Protection on Open Shift
- **Type:** Logic
- **Problem:** ShiftsPage shows all historical shifts. No visual distinction between open/closed shifts. Admin could 
accidentally interact with the wrong shift.

30. /stock-adjustments — No Reason Required for Damage/Adjustment
- **Type:** Data / Audit
- **Problem:** Creating a damage or adjustment_out movement has no required note field. In a real company, every 
stock reduction needs a reason for audit purposes.
- **Fix:** Make note required when movement_type is damage or adjustment_out.

31. /reports — PDF/Print Buttons Have No Loading State
- **Type:** UX
- **Problem:** Clicking "طباعة تقرير المخزون" or "تحميل PDF" opens a new window but shows no loading indicator. If 
the PDF takes 3-5 seconds to generate, user thinks it didn't work and clicks again.

32. PurchaseOrdersPage — No Warehouse Selected Guard
- **Type:** Logic
- **Problem:** Page loads suggestions without requiring a warehouse to be selected. The created PO needs a warehouse 
but the page doesn't enforce selection upfront.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Summary of All Duplications to Remove:

| Remove | Keep |
|--------|------|
| /finance sidebar link + route | /accounting → "الميزان المالي" tab |
| /admin sidebar link | /accounting → "لوحة التحكم" tab |
| /reports (merge into accounting) | /accounting → "تقارير" tab |

This reduces the sidebar from ~15 items to ~11 items — much cleaner.






 Now I have the complete picture. Here's what's missing beyond the backlog:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🔴 Missing — Critical for Daily Operations

1. Customer Credit Limit Enforcement (partially in backlog)
- Backend has no credit_limit field on customers
- Cashier can sell آجل to a customer with 50,000 ج.م debt with no warning
- **Impact:** Real money loss daily

2. Printable Customer/Supplier Statement
- No endpoint to print a customer's full account statement (كشف حساب) as PDF
- Currently only viewable on screen — accountant needs to print it for the customer
- **Impact:** Daily operational need

3. Low Stock Alerts Not Actionable
- Low stock shows in dashboard as a number but no notification, no email, no direct link to create a PO
- **Impact:** Stock runs out silently

4. No Barcode Label Printing
- Can scan barcodes but can't print barcode labels for products
- Hardware store needs to label shelves/products
- **Impact:** Daily operational need

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟠 Missing — Important for Management

5. Expenses Module (top of backlog)
- No way to record rent, electricity, salaries as company expenses
- P&L report is incomplete without expenses
- **Impact:** Financial reports are wrong

6. End-of-Month Closing
- No concept of "closing the month" — payroll doesn't auto-post to expenses, no period lock
- Accountant can edit January data in March
- **Impact:** Accounting integrity

7. Product Bundles/Kits Pricing
- Collections exist but no automatic pricing based on component costs
- No way to see collection profitability
- **Impact:** Selling bundles at a loss unknowingly

8. Supplier Payment Tracking
- Purchases page shows amount_paid but no way to record partial payments over time
- No supplier payment schedule
- **Impact:** Can't track what's owed to suppliers

9. Inter-Branch Transfer Approval
- Dispatch orders execute immediately with no approval step
- Branch manager can transfer stock without HQ approval
- **Impact:** Inventory control risk

10. Cash Reconciliation Report
- No report comparing expected drawer cash vs actual counted cash across all shifts
- Manager has to manually calculate discrepancies
- **Impact:** Daily cash management

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟡 Missing — Nice to Have

11. Product Images in POS
- Products show first letter only — no image in POS grid
- For a hardware store with 700+ similar-looking products, images help cashiers

12. Shift Performance Comparison
- No report comparing cashier performance across shifts (sales per hour, avg transaction value)

13. Reorder Point Alerts in POS
- When a product's stock drops below reorder point during a sale, no alert to the cashier

14. Customer Birthday/Notes
- No notes field on customers for special pricing agreements or contact history

15. Backup Scheduling
- manage.py backup is manual only — no scheduled automatic daily backup
- One power outage = data loss

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━



> Now I have everything. Full audit of Settings page:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🔴 CRITICAL — Security & Integrity

1. GET /settings is PUBLIC — No Auth Required
- **Type:** Security
- **Problem:** get_settings has NO auth dependency — anyone on the internet can call 
http://81.10.109.140/api/settings and get store name, phone, logo URL, contact phones. While not catastrophic, it's 
an unintended exposure.
- **Fix:** Add _=Depends(get_current_user) OR keep it public but only return store_name and logo_url (needed for 
login page).

2. create_warehouse / update_warehouse / delete_warehouse — Only get_current_user, NOT require_role("admin")
- **Type:** Security / Access Control 🚨
- **Problem:** ANY logged-in user (cashier, storekeeper) can create, rename, or delete warehouses via API. The UI 
restricts it but the API doesn't.
- **Fix:**
python
_=Depends(require_role("admin"))  # on all 3 warehouse endpoints


3. Warehouse "تصفير الجرد" Button — No Auth Check on Frontend
- **Type:** Security / Access Control
- **Problem:** The reset button calls DELETE /stock/movements?warehouse_id=... which correctly requires admin role on
backend. But the button is visible to ALL users who can see settings — a non-admin will get a 403 silently with no 
explanation.
- **Fix:** Hide the button if user.role !== 'admin'.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟠 HIGH

4. Delete Category — No Check for Products Using It
- **Type:** Data Integrity
- **Problem:** Deleting a category that has products assigned to it will orphan those products (subcategory_id 
becomes invalid). No warning shown.
- **Fix:** Backend should check 
SELECT COUNT(*) FROM products WHERE subcategory_id IN (SELECT id FROM subcategories WHERE category_id=:id) before 
deleting.

5. Delete Warehouse — No Check for Active Shifts or Sales
- **Type:** Data Integrity
- **Problem:** The UI only blocks deletion of code='main'. Any other warehouse can be deleted even if it has open 
shifts, sales, or stock movements. The DB foreign key will throw a 500 error with no user-friendly message.
- **Fix:** Show count of linked records before deletion: "هذا المخزن فيه 983 حركة مخزون و45 فاتورة — هل أنت متأكد؟"

6. Save Settings — No isPending Guard
- **Type:** Data / Duplicate Submission
- **Problem:** The "حفظ الإعدادات" button has no disabled={saveSettings.isPending}. Rapid clicking sends multiple PUT
requests simultaneously.
- **Fix:** Add disabled={saveSettings.isPending}.

7. Wallet Delete — No Balance Check
- **Type:** Data Integrity
- **Problem:** Can delete a wallet that has a non-zero balance. The balance disappears from the system with no 
record.
- **Fix:** Backend should block deletion if balance != 0, or require balance transfer first.

8. Add Category — No isPending Guard
- **Type:** Duplicate Submission
- **Problem:** "إضافة" button in category modal has no disabled={addCat.isPending}. Double-click creates duplicate 
categories.
- **Fix:** Add disabled={!newCatName || addCat.isPending}.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🟡 MEDIUM

9. Product Options Tab — Read Only, Can't Edit
- **Type:** UX / Missing Feature
- **Problem:** "خيارات المنتجات" tab shows sizes, companies, materials, units as read-only badges. There's a 
PUT /settings/product-options endpoint but NO UI to add/edit/delete options. Users can't manage these lists.
- **Fix:** Add add/delete UI for each option list.

10. Warehouse Code — No Format Validation
- **Type:** Data
- **Problem:** Warehouse code accepts any string including Arabic, spaces, special chars. Codes like "معرض 1" or "R 
02" will cause issues in reports and exports.
- **Fix:** Frontend validation: code.match(/^[A-Z0-9_-]+$/).

11. Add Subcategory — Can Submit Without Category Selected
- **Type:** Logic
- **Problem:** "إضافة" button is disabled={!selectedCatForSub} ✅ but the addSub.mutate() call doesn't validate 
newSubName — can add a subcategory with empty name.
- **Fix:** Add disabled={!selectedCatForSub || !newSubName}.

12. Rename Warehouse — No isPending Guard
- **Type:** Duplicate Submission
- **Problem:** "حفظ" button in rename inline form has no disabled={renameWh.isPending}.

13. Settings Page — No Role-Based Tab Visibility
- **Type:** Access Control / UX
- **Problem:** All 5 tabs visible to all users who can access settings. A cashier shouldn't see "المخازن" or "وسائل ا
لدفع" tabs.
- **Fix:** Hide sensitive tabs based on role:
  - "المخازن" + "وسائل الدفع" → admin only
  - "الفئات" → admin/manager only

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 🔵 LOW / UX

14. No Confirmation Before Deleting Category with Subcategories
- Currently just confirm('حذف الفئة؟') — no info about how many subcategories will be affected.

15. Logo Upload — No File Size/Type Validation on Frontend
- Accepts any file, could upload a 50MB video. Backend doesn't validate either.
- **Fix:** if (file.size > 2_000_000) { toast.error('الحجم أكبر من 2MB'); return }

16. Contact Phones — Fixed 3 Slots
- Hardcoded to exactly 3 contact phone slots. Can't add a 4th or remove unused ones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Summary of Access Control Issues:

| Endpoint | Current | Should Be |
|----------|---------|-----------|
| GET /settings | Public | Public (store_name/logo only) |
| POST /stock/warehouses | Any user | Admin only |
| PUT /stock/warehouses/:id | Any user | Admin only |
| DELETE /stock/warehouses/:id | Any user | Admin only |
| DELETE /wallets/:id | Admin ✅ | Admin + balance=0 check |







