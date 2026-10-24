"""
migrate.py — Safe incremental DB migrations.
Run after deploy on existing databases to apply new columns/tables.
Each migration is idempotent (safe to run multiple times).
"""
import subprocess, sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
COMPOSE = ["docker", "compose", "-f", str(ROOT / "docker-compose.yml")]

def psql(sql: str):
    result = subprocess.run(
        COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "-d", "inventory_db"],
        input=sql, capture_output=True, text=True
    )
    errors = [l for l in result.stderr.splitlines() if "ERROR" in l and "already exists" not in l and "duplicate" not in l.lower()]
    if errors:
        print(f"  ⚠️  {errors[0]}")
    return result.returncode == 0

MIGRATIONS = [
    # v0 — migration tracking table
    ("v0_schema_migrations", """
        CREATE TABLE IF NOT EXISTS schema_migrations (
            id text PRIMARY KEY,
            applied_at timestamptz DEFAULT now()
        );
    """),

    # v1.1 — accounting_periods: add id column and make it PK (live DB has month as PK)
    ("v1.1_accounting_periods_pk", """
        ALTER TABLE accounting_periods ADD COLUMN IF NOT EXISTS id uuid;
        UPDATE accounting_periods SET id = gen_random_uuid() WHERE id IS NULL;
        ALTER TABLE accounting_periods ALTER COLUMN id SET NOT NULL;
        ALTER TABLE accounting_periods DROP CONSTRAINT IF EXISTS accounting_periods_pkey;
        ALTER TABLE accounting_periods ADD PRIMARY KEY (id);
        CREATE UNIQUE INDEX IF NOT EXISTS idx_accounting_periods_month ON accounting_periods(month);
    """),

    # v1 — stock_status on products
    ("v1_stock_status", """
        ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_status text NOT NULL DEFAULT 'tracked';
    """),

    # v2 — safe_transactions table
    ("v2_safe_transactions", """
        CREATE TABLE IF NOT EXISTS safe_transactions (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          safe_id uuid NOT NULL REFERENCES safes(id),
          tx_type text NOT NULL CHECK (tx_type IN ('deposit','withdraw')),
          amount numeric(14,2) NOT NULL,
          balance_after numeric(14,2) NOT NULL,
          note text,
          created_by uuid,
          created_at timestamptz DEFAULT now()
        );
    """),

    # v3 — safe_type on safes
    ("v3_safe_type", """
        ALTER TABLE safes ADD COLUMN IF NOT EXISTS safe_type text NOT NULL DEFAULT 'permanent';
    """),

    # v4 — product_collections
    ("v4_collections", """
        CREATE TABLE IF NOT EXISTS product_collections (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          name text NOT NULL,
          description text,
          retail_price numeric(12,2) DEFAULT 0,
          wholesale_price numeric(12,2) DEFAULT 0,
          is_active boolean DEFAULT true,
          created_at timestamptz DEFAULT now()
        );
        CREATE TABLE IF NOT EXISTS collection_items (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          collection_id uuid NOT NULL REFERENCES product_collections(id) ON DELETE CASCADE,
          product_id uuid NOT NULL REFERENCES products(id),
          qty numeric(12,3) NOT NULL DEFAULT 1
        );
        CREATE INDEX IF NOT EXISTS idx_collection_items_collection ON collection_items(collection_id);
    """),

    # v5 — paper_size setting
    ("v5_paper_size", """
        INSERT INTO store_settings (key, value) VALUES ('paper_size', '"A4"') ON CONFLICT (key) DO NOTHING;
    """),

    # v7 — wallet_transactions audit table
    ("v7_wallet_transactions", """
        CREATE TABLE IF NOT EXISTS wallet_transactions (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          wallet_id uuid NOT NULL REFERENCES payment_wallets(id),
          amount numeric(14,2) NOT NULL,
          tx_type text NOT NULL,
          ref_id uuid,
          note text,
          created_by uuid,
          created_at timestamptz DEFAULT now()
        );
        CREATE INDEX IF NOT EXISTS idx_wallet_tx_wallet ON wallet_transactions(wallet_id);
    """),

    # v6 — wallet_id on sales
    ("v6_wallet_id_sales", """
        ALTER TABLE sales ADD COLUMN IF NOT EXISTS wallet_id uuid REFERENCES payment_wallets(id) ON DELETE SET NULL;
        ALTER TABLE sales ADD COLUMN IF NOT EXISTS payment_method text DEFAULT 'cash';
    """),

    # v7 — ZK device sync log + device settings
    ("v7_hr_sync_log", """
        CREATE TABLE IF NOT EXISTS hr_sync_log (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            synced_at timestamptz DEFAULT now(),
            status text NOT NULL,
            fetched int DEFAULT 0,
            added int DEFAULT 0,
            updated int DEFAULT 0,
            message text
        );
        INSERT INTO hr_settings (key, value) VALUES ('device_host', '192.168.1.201') ON CONFLICT (key) DO NOTHING;
        INSERT INTO hr_settings (key, value) VALUES ('device_port', '4370') ON CONFLICT (key) DO NOTHING;
        INSERT INTO hr_settings (key, value) VALUES ('device_timeout', '5') ON CONFLICT (key) DO NOTHING;
    """),

    ("v8_warehouse_product_status", """
         CREATE TABLE IF NOT EXISTS warehouse_product_status (
             warehouse_id uuid NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
             product_id   uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
             status       text NOT NULL DEFAULT 'untracked',
             PRIMARY KEY (warehouse_id, product_id)
         );
         INSERT INTO warehouse_product_status (warehouse_id, product_id, status)
         SELECT DISTINCT warehouse_id, product_id, 'tracked'
         FROM stock_movements
         ON CONFLICT DO NOTHING;
     """),

    ("v9_product_barcodes", """
         CREATE TABLE IF NOT EXISTS product_barcodes (
             id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
             product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
             barcode text NOT NULL,
             is_primary boolean NOT NULL DEFAULT false,
             created_at timestamptz DEFAULT now(),
             UNIQUE(barcode)
         );
         CREATE INDEX IF NOT EXISTS idx_product_barcodes_product ON product_barcodes(product_id);
         CREATE INDEX IF NOT EXISTS idx_product_barcodes_barcode ON product_barcodes(barcode);
         -- Migrate existing barcodes from products table if they exist
         INSERT INTO product_barcodes (product_id, barcode, is_primary)
         SELECT id, barcode, true FROM products WHERE barcode IS NOT NULL
         ON CONFLICT (barcode) DO NOTHING;
     """),

    ("v10_supplier_prices", """
         CREATE TABLE IF NOT EXISTS supplier_prices (
             id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
             supplier_id uuid NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
             product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
             price numeric(12,2) NOT NULL,
             currency text DEFAULT 'EGP',
             min_qty numeric(12,3) DEFAULT 1,
             last_purchase_date timestamptz,
             notes text,
             is_active boolean DEFAULT true,
             created_at timestamptz DEFAULT now(),
             updated_at timestamptz DEFAULT now(),
             UNIQUE(supplier_id, product_id)
         );
         CREATE INDEX IF NOT EXISTS idx_supplier_prices_supplier ON supplier_prices(supplier_id);
         CREATE INDEX IF NOT EXISTS idx_supplier_prices_product ON supplier_prices(product_id);
         -- Best-effort seed from existing purchase orders if tables exist.
         DO $$
         BEGIN
           IF to_regclass('purchase_orders') IS NOT NULL AND to_regclass('purchase_order_items') IS NOT NULL THEN
             INSERT INTO supplier_prices (supplier_id, product_id, price, last_purchase_date)
             SELECT po.supplier_id, poi.product_id, poi.unit_cost, po.created_at
             FROM purchase_orders po
             JOIN purchase_order_items poi ON poi.po_id = po.id
             WHERE po.supplier_id IS NOT NULL
             ON CONFLICT (supplier_id, product_id) DO NOTHING;
           END IF;
         END $$;
     """),

    # v11 — HR payroll period workflow
    ("v11_hr_payroll_periods", """
        CREATE TABLE IF NOT EXISTS hr_payroll_periods (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            month text UNIQUE NOT NULL,
            status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','review','approved','paid')),
            submitted_by uuid REFERENCES users(id),
            submitted_at timestamptz,
            approved_by uuid REFERENCES users(id),
            approved_at timestamptz,
            paid_by uuid REFERENCES users(id),
            paid_at timestamptz,
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now()
        );
        CREATE INDEX IF NOT EXISTS idx_hr_payroll_periods_status ON hr_payroll_periods(status);
        CREATE INDEX IF NOT EXISTS idx_hr_payroll_periods_month ON hr_payroll_periods(month);
    """),

    # v12 — suppliers soft-delete
    ("v12_suppliers_soft_delete", """
        ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
        UPDATE suppliers SET is_active = true WHERE is_active IS NULL;
        CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);
    """),

    # v13 — sales total/net_total/paid_amount columns (added after model refactor)
    ("v13_sales_amount_columns", """
        ALTER TABLE sales ADD COLUMN IF NOT EXISTS total numeric(12,2) NOT NULL DEFAULT 0;
        ALTER TABLE sales ADD COLUMN IF NOT EXISTS net_total numeric(12,2) NOT NULL DEFAULT 0;
        ALTER TABLE sales ADD COLUMN IF NOT EXISTS paid_amount numeric(12,2) DEFAULT 0;
        ALTER TABLE sales ALTER COLUMN total SET DEFAULT 0;
        ALTER TABLE sales ALTER COLUMN net_total SET DEFAULT 0;
    """),

    # v14 — sale_payments split-payment table
    ("v14_sale_payments", """
        CREATE TABLE IF NOT EXISTS sale_payments (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            sale_id uuid NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
            method text NOT NULL,
            amount numeric(12,2) NOT NULL,
            wallet_id uuid REFERENCES payment_wallets(id) ON DELETE SET NULL
        );
        CREATE INDEX IF NOT EXISTS idx_sale_payments_sale ON sale_payments(sale_id);
    """),

    # v15 — shift model: expected_balance, difference, deposit tracking
    ("v15_shift_expected_balance", """
        ALTER TABLE shifts ADD COLUMN IF NOT EXISTS expected_balance numeric(12,2);
        ALTER TABLE shifts ADD COLUMN IF NOT EXISTS difference numeric(12,2);
        ALTER TABLE shifts ADD COLUMN IF NOT EXISTS deposit_received_by uuid REFERENCES users(id);
        ALTER TABLE shifts ADD COLUMN IF NOT EXISTS deposit_amount numeric(12,2);
    """),

    # v16 — hr_payroll_entries: add missing columns from old hr_payroll table
    ("v16_hr_payroll_entries_full", """
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS working_days integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS actual_working_days integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS absent_days integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS vacation_days integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS total_hours numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS lateness_minutes integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS early_leave_minutes integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS missing_scan_minutes integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS lateness_deduction numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS overtime_hours numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS overtime_pay numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS bonus_days integer;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS bonus_payment numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS bonus numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS deductions numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS advances numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS drawer_variance numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS net_salary numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS hourly_rate numeric(12,2);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS daily_breakdown jsonb;
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES users(id);
        ALTER TABLE hr_payroll_entries ADD COLUMN IF NOT EXISTS status text DEFAULT 'draft';
    """),

    # v17 — unique constraint on (period_id, employee_id) for upsert
    ("v17_hr_payroll_entries_unique", """
        ALTER TABLE hr_payroll_entries DROP CONSTRAINT IF EXISTS hr_payroll_entries_period_id_employee_id_key;
        ALTER TABLE hr_payroll_entries ADD CONSTRAINT hr_payroll_entries_period_id_employee_id_key UNIQUE (period_id, employee_id);
    """),

    # v18 — hr_payroll_periods: add default for id column
    ("v18_hr_payroll_periods_id_default", """
        ALTER TABLE hr_payroll_periods ALTER COLUMN id SET DEFAULT gen_random_uuid();
    """),
]

def run():
    print("🔄 Running DB migrations...")
    ok = 0
    for name, sql in MIGRATIONS:
        # Check if already applied
        check = subprocess.run(
            COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "-d", "inventory_db", "-t", "-c",
                       f"SELECT 1 FROM schema_migrations WHERE id='{name}'"],
            capture_output=True, text=True
        )
        if check.returncode == 0 and check.stdout.strip():
            print(f"  ⏭️  {name} (already applied)")
            ok += 1
            continue
        result = psql(sql)
        status = "✅" if result else "⚠️ "
        print(f"  {status} {name}")
        if result:
            ok += 1
            # Record as applied
            subprocess.run(
                COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "-d", "inventory_db", "-c",
                           f"INSERT INTO schema_migrations (id) VALUES ('{name}') ON CONFLICT DO NOTHING"],
                capture_output=True, text=True
            )
    print(f"\n✅ Done — {ok}/{len(MIGRATIONS)} migrations applied.")

if __name__ == "__main__":
    run()
