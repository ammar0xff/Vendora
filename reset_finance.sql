-- =============================================================
-- ERP Finance & Operations Reset Script
-- Resets all financial, operational, and log data to zero.
-- Does NOT touch product prices or related master data.
-- =============================================================

BEGIN;

-- ---------------------------------------------------------
-- 1. TRUNCATE transactional tables (CASCADE for FK safety)
-- ---------------------------------------------------------

-- Sales & Invoices
TRUNCATE TABLE sale_items CASCADE;
TRUNCATE TABLE sales CASCADE;

-- Shifts & Drawer
TRUNCATE TABLE drawer_transactions CASCADE;
TRUNCATE TABLE shifts CASCADE;

-- Customers / Suppliers Payments
TRUNCATE TABLE customer_payments CASCADE;
TRUNCATE TABLE supplier_transactions CASCADE;

-- Note: expenses / expense_vendors tables exist in model but not yet migrated

-- Purchasing
TRUNCATE TABLE purchase_order_items CASCADE;
TRUNCATE TABLE purchase_orders CASCADE;
TRUNCATE TABLE purchase_price_history CASCADE;

-- Stock Movements
TRUNCATE TABLE stock_movements CASCADE;

-- Archive & Logs
TRUNCATE TABLE archived_documents CASCADE;
TRUNCATE TABLE audit_log CASCADE;

-- Safes & Wallets
TRUNCATE TABLE safe_deposits CASCADE;
TRUNCATE TABLE safe_transactions CASCADE;
TRUNCATE TABLE wallet_transactions CASCADE;

-- HR / Payroll
TRUNCATE TABLE hr_attendance CASCADE;
TRUNCATE TABLE hr_payroll CASCADE;
TRUNCATE TABLE hr_payroll_periods CASCADE;
TRUNCATE TABLE hr_audit_log CASCADE;
TRUNCATE TABLE hr_sync_log CASCADE;
TRUNCATE TABLE hr_advances CASCADE;
TRUNCATE TABLE hr_settings CASCADE;
TRUNCATE TABLE hr_shifts CASCADE;

-- General Payroll
TRUNCATE TABLE payroll_entries CASCADE;
TRUNCATE TABLE payroll_periods CASCADE;

-- Collection items (has sale refs, not product data)
TRUNCATE TABLE collection_items CASCADE;

-- ---------------------------------------------------------
-- 2. ZERO OUT balances on master data tables
-- ---------------------------------------------------------

UPDATE customers SET balance = 0 WHERE balance <> 0;
UPDATE payment_wallets SET balance = 0 WHERE balance <> 0;
UPDATE safes SET balance = 0 WHERE balance <> 0;

-- ---------------------------------------------------------
-- 3. VERIFICATION queries (will be printed)
-- ---------------------------------------------------------

SELECT 'sales' AS tbl, count(*) AS rows FROM sales
UNION ALL SELECT 'sale_items', count(*) FROM sale_items
UNION ALL SELECT 'shifts', count(*) FROM shifts
UNION ALL SELECT 'drawer_transactions', count(*) FROM drawer_transactions
UNION ALL SELECT 'customer_payments', count(*) FROM customer_payments
UNION ALL SELECT 'supplier_transactions', count(*) FROM supplier_transactions
UNION ALL SELECT 'purchase_orders', count(*) FROM purchase_orders
UNION ALL SELECT 'purchase_order_items', count(*) FROM purchase_order_items
UNION ALL SELECT 'purchase_price_history', count(*) FROM purchase_price_history
UNION ALL SELECT 'stock_movements', count(*) FROM stock_movements
UNION ALL SELECT 'archived_documents', count(*) FROM archived_documents
UNION ALL SELECT 'audit_log', count(*) FROM audit_log
UNION ALL SELECT 'safe_deposits', count(*) FROM safe_deposits
UNION ALL SELECT 'safe_transactions', count(*) FROM safe_transactions
UNION ALL SELECT 'wallet_transactions', count(*) FROM wallet_transactions
UNION ALL SELECT 'hr_attendance', count(*) FROM hr_attendance
UNION ALL SELECT 'hr_payroll', count(*) FROM hr_payroll
UNION ALL SELECT 'hr_advances', count(*) FROM hr_advances
UNION ALL SELECT 'payroll_entries', count(*) FROM payroll_entries
UNION ALL SELECT 'payroll_periods', count(*) FROM payroll_periods
UNION ALL SELECT 'collection_items', count(*) FROM collection_items
ORDER BY tbl;

SELECT 'customers_with_balance' AS check, count(*) FROM customers WHERE balance <> 0
UNION ALL SELECT 'wallets_with_balance', count(*) FROM payment_wallets WHERE balance <> 0
UNION ALL SELECT 'safes_with_balance', count(*) FROM safes WHERE balance <> 0;

COMMIT;
