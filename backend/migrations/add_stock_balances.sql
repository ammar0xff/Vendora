-- Migration: Add stock_balances maintained table for O(1) balance reads
-- Run after all models are registered

-- Create stock_balances table with composite PK (product_id, warehouse_id)
CREATE TABLE IF NOT EXISTS stock_balances (
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id uuid NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    qty numeric(12,3) NOT NULL DEFAULT 0,
    updated_at timestamptz DEFAULT now(),
    PRIMARY KEY (product_id, warehouse_id)
);

-- Create index for warehouse-scoped queries
CREATE INDEX IF NOT EXISTS idx_stock_balances_warehouse ON stock_balances(warehouse_id);

-- Backfill from stock_movements: compute current balance per product/warehouse
INSERT INTO stock_balances (product_id, warehouse_id, qty, updated_at)
SELECT 
    product_id,
    warehouse_id,
    COALESCE(SUM(
        CASE 
            WHEN movement_type IN ('opening_stock','purchase','return_in','adjustment_in','transfer_in') THEN qty
            ELSE -qty
        END
    ), 0) as qty,
    now() as updated_at
FROM stock_movements
GROUP BY product_id, warehouse_id
ON CONFLICT (product_id, warehouse_id) DO UPDATE SET
    qty = EXCLUDED.qty,
    updated_at = now();
