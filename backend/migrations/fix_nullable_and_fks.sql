-- Fix nullable columns + add missing FKs
-- Run: psql -U postgres -d egco -f migrations/fix_nullable_and_fks.sql
-- IMPORTANT: Back up database before running!

-- 1. Set NOT NULL + DEFAULT 0 on sales.paid_amount and sales.returns_total
-- (existing NULLs → 0 first)
UPDATE sales SET paid_amount = 0 WHERE paid_amount IS NULL;
UPDATE sales SET returns_total = 0 WHERE returns_total IS NULL;

DO $$
BEGIN
    ALTER TABLE sales ALTER COLUMN paid_amount SET DEFAULT 0;
    ALTER TABLE sales ALTER COLUMN paid_amount SET NOT NULL;

    ALTER TABLE sales ALTER COLUMN returns_total SET DEFAULT 0;
    ALTER TABLE sales ALTER COLUMN returns_total SET NOT NULL;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ALTER skipped: %', SQLERRM;
END $$;

-- 2. DrawerTransaction.category_id FK → financial_categories
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_drawer_txn_category'
    ) THEN
        ALTER TABLE drawer_transactions
            ADD CONSTRAINT fk_drawer_txn_category
            FOREIGN KEY (category_id) REFERENCES financial_categories(id) ON DELETE SET NULL;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'FK drawer_txn→category skipped: %', SQLERRM;
END $$;

-- Note: DrawerTransaction.ref_id and StockMovement.ref_id are polymorphic
-- (refer to different tables based on ref_type). These cannot have a single FK.
-- Consider adding application-level validation instead.
