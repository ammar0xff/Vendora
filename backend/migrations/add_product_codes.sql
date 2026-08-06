-- Add `code` column to products (manual display/search code).
-- Idempotent: safe to re-run.

ALTER TABLE products ADD COLUMN IF NOT EXISTS code VARCHAR(32) NULL;

CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
