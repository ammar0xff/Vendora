-- Add composite indexes for common query patterns
-- Run: psql -U postgres -d egco -f migrations/add_indexes.sql

-- Stock movements: queries filtering by product + warehouse
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_warehouse
    ON stock_movements (product_id, warehouse_id);

-- Shifts: queries filtering by warehouse + status (e.g. finding open shifts)
CREATE INDEX IF NOT EXISTS idx_shifts_warehouse_status
    ON shifts (warehouse_id, status);

-- Supplier prices: enforce one price per supplier-product pair
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_supplier_product'
    ) THEN
        ALTER TABLE supplier_prices
            ADD CONSTRAINT uq_supplier_product UNIQUE (supplier_id, product_id);
    END IF;
END $$;
