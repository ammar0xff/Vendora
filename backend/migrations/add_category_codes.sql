-- Add `code` column to categories and subcategories (manual sort/display code).
-- Idempotent: safe to re-run.

ALTER TABLE categories   ADD COLUMN IF NOT EXISTS code VARCHAR(32) NULL;
ALTER TABLE subcategories ADD COLUMN IF NOT EXISTS code VARCHAR(32) NULL;

CREATE INDEX IF NOT EXISTS idx_categories_code   ON categories(code);
CREATE INDEX IF NOT EXISTS idx_subcategories_code ON subcategories(code);
