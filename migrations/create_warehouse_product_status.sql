-- Restore missing warehouse_product_status table (was absent from the live
-- DB but required by stock_service.record_movement, stock router
-- balance/bulk + reset, collections availability, and sale_service).
-- Matches the schema in data/sql/prod_db.sql. Idempotent.
CREATE TABLE IF NOT EXISTS public.warehouse_product_status (
    warehouse_id uuid NOT NULL,
    product_id   uuid NOT NULL,
    status       text NOT NULL DEFAULT 'untracked'::text
);

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_pkey PRIMARY KEY (warehouse_id, product_id);

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_warehouse_id_fk FOREIGN KEY (warehouse_id)
        REFERENCES public.warehouses(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES public.products(id) ON DELETE CASCADE;