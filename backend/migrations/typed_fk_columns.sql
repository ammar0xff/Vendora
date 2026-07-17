-- Migration: Add typed FK columns to drawer_transactions and stock_movements
-- Replaces polymorphic ref_id/ref_type with proper foreign keys
-- Safe: all columns nullable, no data loss, backward compatible
-- Run: psql -U postgres -d egco -f backend/migrations/typed_fk_columns.sql

BEGIN;

-- ─── 1. DrawerTransaction: add FK constraint on existing ref_id ─────────────
-- ref_id always points to sales.id (or NULL). Add FK + index.
ALTER TABLE drawer_transactions
    ADD CONSTRAINT fk_drawer_tx_sale FOREIGN KEY (ref_id) REFERENCES sales(id) ON DELETE SET NULL;

-- ─── 2. StockMovement: add typed FK columns ─────────────────────────────────
ALTER TABLE stock_movements
    ADD COLUMN sale_id     UUID REFERENCES sales(id) ON DELETE SET NULL,
    ADD COLUMN purchase_id UUID REFERENCES purchase_orders(id) ON DELETE SET NULL,
    ADD COLUMN operation_id UUID;

CREATE INDEX IF NOT EXISTS idx_stock_movements_sale_id     ON stock_movements(sale_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_purchase_id ON stock_movements(purchase_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_operation_id ON stock_movements(operation_id);

-- ─── 3. Backfill StockMovement.typed columns from existing ref_type/ref_id ──
-- All sale-related ref_types → sale_id
UPDATE stock_movements SET sale_id = ref_id
WHERE ref_type IN ('sale', 'return', 'partial_return', 'sale_adjustment', 'item_deleted', 'sale_cancel')
  AND ref_id IS NOT NULL
  AND sale_id IS NULL;

-- Purchase ref_type → purchase_id
UPDATE stock_movements SET purchase_id = ref_id
WHERE ref_type = 'purchase'
  AND ref_id IS NOT NULL
  AND purchase_id IS NULL;

-- Dispatch/goods_receipt ref_type → operation_id (ephemeral UUIDs, no FK)
UPDATE stock_movements SET operation_id = ref_id
WHERE ref_type IN ('dispatch', 'goods_receipt')
  AND ref_id IS NOT NULL
  AND operation_id IS NULL;

COMMIT;
