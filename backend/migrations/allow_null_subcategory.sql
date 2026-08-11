-- Allow subcategory_id to be NULL so soft-deleted (is_active=false) products
-- don't block subcategory/category deletion via FK RESTRICT.
ALTER TABLE products ALTER COLUMN subcategory_id DROP NOT NULL;