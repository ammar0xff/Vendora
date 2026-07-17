-- Cleanup + missing indexes migration
-- 1. Drop duplicate FK constraint on drawer_transactions.category_id
-- 2. Add indexes on FK columns that lack them
-- Idempotent: safe to run multiple times
-- Run: psql -U postgres -d inventory_db -f backend/migrations/cleanup_and_indexes.sql

-- ─── 1. Drop duplicate FK on drawer_transactions.category_id ────────────────
-- Two FKs exist: fk_drawer_txn_category (ON DELETE SET NULL) and
-- drawer_transactions_category_id_fkey (no ON DELETE). Keep the SET NULL one.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'drawer_transactions_category_id_fkey'
    ) THEN
        ALTER TABLE drawer_transactions DROP CONSTRAINT drawer_transactions_category_id_fkey;
    END IF;
END $$;

-- ─── 2. Add missing FK indexes ──────────────────────────────────────────────
-- Each CREATE INDEX IF NOT EXISTS is idempotent

-- archived_documents
CREATE INDEX IF NOT EXISTS idx_archived_documents_created_by ON archived_documents(created_by);

-- collection_items
CREATE INDEX IF NOT EXISTS idx_collection_items_product_id ON collection_items(product_id);

-- customer_payments
CREATE INDEX IF NOT EXISTS idx_customer_payments_created_by ON customer_payments(created_by);
CREATE INDEX IF NOT EXISTS idx_customer_payments_sale_id ON customer_payments(sale_id);

-- drawer_transactions
CREATE INDEX IF NOT EXISTS idx_drawer_transactions_created_by ON drawer_transactions(created_by);
CREATE INDEX IF NOT EXISTS idx_drawer_transactions_wallet_id ON drawer_transactions(wallet_id);

-- employees
CREATE INDEX IF NOT EXISTS idx_employees_user_id ON employees(user_id);

-- hr_advances
CREATE INDEX IF NOT EXISTS idx_hr_advances_created_by ON hr_advances(created_by);
CREATE INDEX IF NOT EXISTS idx_hr_advances_employee_id ON hr_advances(employee_id);

-- hr_audit_log
CREATE INDEX IF NOT EXISTS idx_hr_audit_log_performed_by ON hr_audit_log(performed_by);

-- hr_payroll (may have been dropped)
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'hr_payroll') THEN
        CREATE INDEX IF NOT EXISTS idx_hr_payroll_created_by ON hr_payroll(created_by);
    END IF;
END $$;

-- payroll_entries (may have been dropped)
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'payroll_entries') THEN
        CREATE INDEX IF NOT EXISTS idx_payroll_entries_employee_id ON payroll_entries(employee_id);
        CREATE INDEX IF NOT EXISTS idx_payroll_entries_period_id ON payroll_entries(period_id);
    END IF;
END $$;

-- payroll_periods (may have been dropped)
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'payroll_periods') THEN
        CREATE INDEX IF NOT EXISTS idx_payroll_periods_created_by ON payroll_periods(created_by);
    END IF;
END $$;

-- purchase_order_items
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_product_id ON purchase_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_po_id ON purchase_order_items(po_id);

-- purchase_orders
CREATE INDEX IF NOT EXISTS idx_purchase_orders_created_by ON purchase_orders(created_by);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier_id ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_warehouse_id ON purchase_orders(warehouse_id);

-- purchase_price_history
CREATE INDEX IF NOT EXISTS idx_purchase_price_history_supplier_id ON purchase_price_history(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_price_history_po_id ON purchase_price_history(po_id);

-- safe_deposits
CREATE INDEX IF NOT EXISTS idx_safe_deposits_deposited_by ON safe_deposits(deposited_by);
CREATE INDEX IF NOT EXISTS idx_safe_deposits_received_by ON safe_deposits(received_by);
CREATE INDEX IF NOT EXISTS idx_safe_deposits_safe_id ON safe_deposits(safe_id);
CREATE INDEX IF NOT EXISTS idx_safe_deposits_shift_id ON safe_deposits(shift_id);
CREATE INDEX IF NOT EXISTS idx_safe_deposits_warehouse_id ON safe_deposits(warehouse_id);

-- safe_transactions
CREATE INDEX IF NOT EXISTS idx_safe_transactions_safe_id ON safe_transactions(safe_id);

-- sales
CREATE INDEX IF NOT EXISTS idx_sales_created_by ON sales(created_by);
CREATE INDEX IF NOT EXISTS idx_sales_wallet_id ON sales(wallet_id);
CREATE INDEX IF NOT EXISTS idx_sales_warehouse_id ON sales(warehouse_id);

-- shifts
CREATE INDEX IF NOT EXISTS idx_shifts_cashier_id ON shifts(cashier_id);
CREATE INDEX IF NOT EXISTS idx_shifts_closed_by ON shifts(closed_by);
CREATE INDEX IF NOT EXISTS idx_shifts_deposit_received_by ON shifts(deposit_received_by);
CREATE INDEX IF NOT EXISTS idx_shifts_supervisor_id ON shifts(supervisor_id);

-- stock_movements
CREATE INDEX IF NOT EXISTS idx_stock_movements_created_by ON stock_movements(created_by);

-- subcategories
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON subcategories(category_id);

-- users
CREATE INDEX IF NOT EXISTS idx_users_default_warehouse_id ON users(default_warehouse_id);

-- accounting_periods
CREATE INDEX IF NOT EXISTS idx_accounting_periods_closed_by ON accounting_periods(closed_by);
CREATE INDEX IF NOT EXISTS idx_accounting_periods_locked_by_id ON accounting_periods(locked_by_id);

-- sale_payments
CREATE INDEX IF NOT EXISTS idx_sale_payments_wallet_id ON sale_payments(wallet_id);

-- expense_vendors
CREATE INDEX IF NOT EXISTS idx_expense_vendors_created_by ON expense_vendors(created_by);

-- expenses
CREATE INDEX IF NOT EXISTS idx_expenses_approved_by ON expenses(approved_by);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by);
CREATE INDEX IF NOT EXISTS idx_expenses_safe_id ON expenses(safe_id);
CREATE INDEX IF NOT EXISTS idx_expenses_vendor_id ON expenses(vendor_id);
CREATE INDEX IF NOT EXISTS idx_expenses_wallet_id ON expenses(wallet_id);

-- hr_payroll_entries
CREATE INDEX IF NOT EXISTS idx_hr_payroll_entries_employee_id ON hr_payroll_entries(employee_id);
CREATE INDEX IF NOT EXISTS idx_hr_payroll_entries_period_id ON hr_payroll_entries(period_id);
