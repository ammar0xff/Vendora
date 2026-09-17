-- E2E hardening: DB-side id defaults + missing enum value.
-- Several raw INSERT ... (no id) statements rely on a DB default that was
-- never created (the live schema came from ORM create_all, which does not add
-- server defaults). Add gen_random_uuid() defaults for all uuid `id` PKs,
-- and add the revenue_delivery drawer transaction type. Idempotent.

DO $$
DECLARE t text;
BEGIN
  FOR t IN
    SELECT c.relname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = 'public'
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attname = 'id'
      AND a.attnum > 0 AND NOT a.attisdropped
    LEFT JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = a.attnum
    WHERE c.relkind = 'r'
      AND format_type(a.atttypid, a.atttypmod) = 'uuid'
      AND d.adbin IS NULL
      AND c.relname NOT IN ('employees', 'payroll_entries', 'payroll_periods')
  LOOP
    EXECUTE format('ALTER TABLE public.%I ALTER COLUMN id SET DEFAULT gen_random_uuid()', t);
  END LOOP;
END $$;

ALTER TYPE public.drawer_tx_type_enum ADD VALUE IF NOT EXISTS 'revenue_delivery';

-- NOT NULL columns that raw INSERTs omit but the ORM models treat as
-- optional/defaulted (server defaults were never created).
ALTER TABLE public.expenses ALTER COLUMN recurring_end_date DROP NOT NULL;
ALTER TABLE public.expenses ALTER COLUMN is_recurring SET DEFAULT false;
ALTER TABLE public.expense_vendors ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE public.customers ALTER COLUMN is_cash SET DEFAULT false;
ALTER TABLE public.products ALTER COLUMN subcategory_id DROP NOT NULL;
ALTER TABLE public.device_tokens ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE public.hr_payroll_periods ALTER COLUMN status SET DEFAULT 'draft';
ALTER TABLE public.hr_payroll_entries ALTER COLUMN bonuses SET DEFAULT 0;
ALTER TABLE public.hr_payroll_entries ALTER COLUMN deductions SET DEFAULT 0;

-- hr_sync_log is referenced by hr import/device-sync routes but never existed
-- in the live schema (only in the ORM). Create it (idempotent).
CREATE TABLE IF NOT EXISTS public.hr_sync_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    synced_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL,
    fetched integer NOT NULL DEFAULT 0,
    added integer NOT NULL DEFAULT 0,
    updated integer NOT NULL DEFAULT 0,
    message text
);
