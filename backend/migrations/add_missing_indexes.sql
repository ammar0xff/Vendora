-- Missing indexes for foreign key columns (54 identified)
-- Run this to add all missing FK indexes

-- accounting_periods.closed_by -> users
CREATE INDEX IF NOT EXISTS idx_accounting_periods_closed_by ON accounting_periods(closed_by);

-- archived_documents.created_by -> users
CREATE INDEX IF NOT EXISTS idx_archived_documents_created_by ON archived_documents(created_by);

-- collection_items.product_id -> products
CREATE INDEX IF NOT EXISTS idx_collection_items_product_id ON collection_items(product_id);

-- customer_payments.created_by -> users
CREATE INDEX IF NOT EXISTS idx_customer_payments_created_by ON customer_payments(created_by);

-- drawer_transactions.created_by -> users
CREATE INDEX IF NOT EXISTS idx_drawer_transactions_created_by ON drawer_transactions(created_by);

-- drawer_transactions.wallet_id -> payment_wallets
CREATE INDEX IF NOT EXISTS idx_drawer_transactions_wallet_id ON drawer_transactions(wallet_id);

-- drawer_transactions.category_id -> financial_categories
CREATE INDEX IF NOT EXISTS idx_drawer_transactions_category_id ON drawer_transactions(category_id);

-- employees.user_id -> users
CREATE INDEX IF NOT EXISTS idx_employees_user_id ON employees(user_id);

-- expense_vendors.created_by -> users
CREATE INDEX IF NOT EXISTS idx_expense_vendors_created_by ON expense_vendors(created_by);

-- expenses.wallet_id -> payment_wallets
CREATE INDEX IF NOT EXISTS idx_expenses_wallet_id ON expenses(wallet_id);

-- expenses.warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_expenses_warehouse_id ON expenses(warehouse_id);

-- expenses.category_id -> financial_categories
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);

-- expenses.vendor_id -> expense_vendors
CREATE INDEX IF NOT EXISTS idx_expenses_vendor_id ON expenses(vendor_id);

-- expenses.approved_by -> users
CREATE INDEX IF NOT EXISTS idx_expenses_approved_by ON expenses(approved_by);

-- expenses.created_by -> users
CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by);

-- expenses.safe_id -> safes
CREATE INDEX IF NOT EXISTS idx_expenses_safe_id ON expenses(safe_id);

-- hr_advances.created_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_advances_created_by ON hr_advances(created_by);

-- hr_advances.employee_id -> hr_employees
CREATE INDEX IF NOT EXISTS idx_hr_advances_employee_id ON hr_advances(employee_id);

-- hr_audit_log.performed_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_audit_log_performed_by ON hr_audit_log(performed_by);

-- hr_employees.user_id -> users
CREATE INDEX IF NOT EXISTS idx_hr_employees_user_id ON hr_employees(user_id);

-- hr_payroll.created_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_payroll_created_by ON hr_payroll(created_by);

-- hr_payroll_entries.created_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_payroll_entries_created_by ON hr_payroll_entries(created_by);

-- hr_payroll_periods.paid_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_payroll_periods_paid_by ON hr_payroll_periods(paid_by);

-- hr_payroll_periods.approved_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_payroll_periods_approved_by ON hr_payroll_periods(approved_by);

-- hr_payroll_periods.submitted_by -> users
CREATE INDEX IF NOT EXISTS idx_hr_payroll_periods_submitted_by ON hr_payroll_periods(submitted_by);

-- payroll_entries.period_id -> payroll_periods
CREATE INDEX IF NOT EXISTS idx_payroll_entries_period_id ON payroll_entries(period_id);

-- payroll_entries.employee_id -> employees
CREATE INDEX IF NOT EXISTS idx_payroll_entries_employee_id ON payroll_entries(employee_id);

-- payroll_periods.created_by -> users
CREATE INDEX IF NOT EXISTS idx_payroll_periods_created_by ON payroll_periods(created_by);

-- products.subcategory_id -> subcategories
CREATE INDEX IF NOT EXISTS idx_products_subcategory_id ON products(subcategory_id);

-- purchase_order_items.product_id -> products
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_product_id ON purchase_order_items(product_id);

-- purchase_order_items.po_id -> purchase_orders
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_po_id ON purchase_order_items(po_id);

-- purchase_orders.warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_purchase_orders_warehouse_id ON purchase_orders(warehouse_id);

-- purchase_orders.created_by -> users
CREATE INDEX IF NOT EXISTS idx_purchase_orders_created_by ON purchase_orders(created_by);

-- purchase_orders.supplier_id -> suppliers
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier_id ON purchase_orders(supplier_id);

-- purchase_price_history.supplier_id -> suppliers
CREATE INDEX IF NOT EXISTS idx_purchase_price_history_supplier_id ON purchase_price_history(supplier_id);

-- purchase_price_history.po_id -> purchase_orders
CREATE INDEX IF NOT EXISTS idx_purchase_price_history_po_id ON purchase_price_history(po_id);

-- safe_deposits.deposited_by -> users
CREATE INDEX IF NOT EXISTS idx_safe_deposits_deposited_by ON safe_deposits(deposited_by);

-- safe_deposits.received_by -> users
CREATE INDEX IF NOT EXISTS idx_safe_deposits_received_by ON safe_deposits(received_by);

-- safe_deposits.safe_id -> safes
CREATE INDEX IF NOT EXISTS idx_safe_deposits_safe_id ON safe_deposits(safe_id);

-- safe_deposits.shift_id -> shifts
CREATE INDEX IF NOT EXISTS idx_safe_deposits_shift_id ON safe_deposits(shift_id);

-- safe_deposits.warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_safe_deposits_warehouse_id ON safe_deposits(warehouse_id);

-- safe_transactions.safe_id -> safes
CREATE INDEX IF NOT EXISTS idx_safe_transactions_safe_id ON safe_transactions(safe_id);

-- sale_payments.wallet_id -> payment_wallets
CREATE INDEX IF NOT EXISTS idx_sale_payments_wallet_id ON sale_payments(wallet_id);

-- sales.created_by -> users
CREATE INDEX IF NOT EXISTS idx_sales_created_by ON sales(created_by);

-- sales.wallet_id -> payment_wallets
CREATE INDEX IF NOT EXISTS idx_sales_wallet_id ON sales(wallet_id);

-- sales.warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_sales_warehouse_id ON sales(warehouse_id);

-- shifts.deposit_received_by -> users
CREATE INDEX IF NOT EXISTS idx_shifts_deposit_received_by ON shifts(deposit_received_by);

-- shifts.warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_shifts_warehouse_id ON shifts(warehouse_id);

-- shifts.supervisor_id -> users
CREATE INDEX IF NOT EXISTS idx_shifts_supervisor_id ON shifts(supervisor_id);

-- shifts.closed_by -> users
CREATE INDEX IF NOT EXISTS idx_shifts_closed_by ON shifts(closed_by);

-- shifts.cashier_id -> users
CREATE INDEX IF NOT EXISTS idx_shifts_cashier_id ON shifts(cashier_id);

-- stock_movements.created_by -> users
CREATE INDEX IF NOT EXISTS idx_stock_movements_created_by ON stock_movements(created_by);

-- subcategories.category_id -> categories
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON subcategories(category_id);

-- users.default_warehouse_id -> warehouses
CREATE INDEX IF NOT EXISTS idx_users_default_warehouse_id ON users(default_warehouse_id);
