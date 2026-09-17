-- Schema drift repair: live DB was created via ORM create_all which never
-- alters existing tables. These columns exist in the model (and in
-- data/sql/prod_db.sql) but were missing from the deployed database, which
-- 500'd every stock movement insert (and shift summary / customer payment
-- flows). Idempotent.
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS credit_limit numeric(14,2);

ALTER TABLE public.suppliers ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

ALTER TABLE public.shifts ADD COLUMN IF NOT EXISTS expected_balance numeric(12,2);
ALTER TABLE public.shifts ADD COLUMN IF NOT EXISTS difference numeric(12,2);

ALTER TABLE public.customer_payments ADD COLUMN IF NOT EXISTS sale_id uuid;
ALTER TABLE public.stock_movements ADD COLUMN IF NOT EXISTS sale_id uuid;
ALTER TABLE public.stock_movements ADD COLUMN IF NOT EXISTS purchase_id uuid;
ALTER TABLE public.stock_movements ADD COLUMN IF NOT EXISTS operation_id uuid;

-- keep in sync with prod_db.sql: stock_movements_operation_id etc.
CREATE INDEX IF NOT EXISTS idx_stock_movements_sale_id ON public.stock_movements (sale_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_purchase_id ON public.stock_movements (purchase_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_operation_id ON public.stock_movements (operation_id);

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_sale_id_fkey FOREIGN KEY (sale_id)
        REFERENCES public.sales(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_sale_id_fkey FOREIGN KEY (sale_id)
        REFERENCES public.sales(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_purchase_id_fkey FOREIGN KEY (purchase_id)
        REFERENCES public.purchase_orders(id) ON DELETE SET NULL;