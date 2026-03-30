#!/usr/bin/env python3
"""
migrate_json_to_pg.py
─────────────────────────────────────────────────────────────────────────────
Migrates all legacy JSON data into the PostgreSQL database.

Sources:
  - data.json              → categories, subcategories, products
  - data_stock_movements.json → stock_movements
  - data/users.json        → users
  - data/drawer_history.json → shifts, drawer_transactions
  - archive/index.json     → archived_documents
  - config.json            → store_settings

Usage:
  cd /home/ammar/Desktop/AMMAR/inventory-web/backend
  python migrate_json_to_pg.py --source /home/ammar/Desktop/AMMAR/جرد

Requirements: pip install psycopg2-binary python-dotenv
"""

import argparse
import json
import os
import sys
import uuid
from datetime import datetime
from pathlib import Path

import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

load_dotenv()

# ── helpers ──────────────────────────────────────────────────────────────────

def pg_url_to_psycopg2(url: str) -> str:
    """Convert asyncpg URL to psycopg2 URL."""
    return url.replace("postgresql+asyncpg://", "postgresql://")


def ts(val):
    """Normalize timestamp to ISO string or None."""
    if not val:
        return None
    if isinstance(val, str):
        return val
    return None


def dec(val, default=0.0):
    try:
        return float(val or default)
    except (TypeError, ValueError):
        return default


def safe_uuid(val):
    """Return val if valid UUID string, else generate new one."""
    if not val:
        return str(uuid.uuid4())
    try:
        uuid.UUID(str(val))
        return str(val)
    except ValueError:
        return str(uuid.uuid4())


# ── main migration ────────────────────────────────────────────────────────────

def migrate(source_dir: str, db_url: str, dry_run: bool = False):
    source = Path(source_dir)

    print(f"Source: {source}")
    print(f"DB:     {db_url}")
    print(f"Dry run: {dry_run}")
    print()

    # Load all JSON files
    data_json        = json.loads((source / "data.json").read_text(encoding="utf-8"))
    movements_json   = json.loads((source / "data_stock_movements.json").read_text(encoding="utf-8"))
    users_json       = json.loads((source / "data" / "users.json").read_text(encoding="utf-8"))
    drawer_json      = json.loads((source / "data" / "drawer_history.json").read_text(encoding="utf-8"))
    archive_json     = json.loads((source / "archive" / "index.json").read_text(encoding="utf-8"))
    config_json      = json.loads((source / "config.json").read_text(encoding="utf-8"))

    if dry_run:
        print("[DRY RUN] Would migrate:")
        cats = data_json.get("categories", {})
        total_products = sum(len(p) for subs in cats.values() for p in subs.values())
        print(f"  {len(cats)} categories")
        print(f"  {sum(len(s) for s in cats.values())} subcategories")
        print(f"  {total_products} products")
        print(f"  {len(movements_json)} stock movements")
        print(f"  {len(users_json)} users")
        print(f"  {len(drawer_json)} shifts")
        print(f"  {len(archive_json)} archived documents")
        return

    conn = psycopg2.connect(pg_url_to_psycopg2(db_url))
    conn.autocommit = False
    cur = conn.cursor()

    try:
        # ── 1. Store settings ─────────────────────────────────────────────
        print("Migrating store settings...")
        store = config_json.get("store_settings", {})
        settings_rows = [
            ("store_name",    store.get("name", "متجري")),
            ("store_address", store.get("address", "")),
            ("store_phone",   store.get("phone", "")),
            ("printer",       store.get("printer", "")),
            ("currency",      "ريال"),
            ("low_stock_threshold", "5"),
        ]
        execute_values(cur,
            "INSERT INTO store_settings (key, value) VALUES %s ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value",
            settings_rows
        )
        print(f"  ✓ {len(settings_rows)} settings")

        # ── 2. Users ──────────────────────────────────────────────────────
        print("Migrating users...")
        # We need to insert users with bcrypt hashes.
        # The old system used sha256(password+salt). We'll store a placeholder
        # bcrypt hash and flag the user to reset password on first login.
        # For the admin/ammar users we know the original hash — we store it
        # in a legacy_hash column for reference, and set a known bcrypt hash.
        import hashlib, secrets

        # Create a bcrypt hash for a temporary password "changeme"
        # Users will need to reset their passwords after migration.
        import bcrypt as _bcrypt
        temp_hash = _bcrypt.hashpw(b"changeme", _bcrypt.gensalt()).decode()

        user_rows = []
        user_id_map = {}  # username -> uuid

        for username, u in users_json.items():
            uid = safe_uuid(u.get("id") if u.get("id") != username else None)
            # Use a stable UUID derived from username for consistency
            uid = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"user:{username}"))
            user_id_map[username] = uid
            user_rows.append((
                uid,
                u.get("username", username),
                u.get("name", username),
                u.get("role", "cashier"),
                temp_hash,
                True,
                ts(u.get("created_at")) or datetime.utcnow().isoformat(),
            ))

        # Deduplicate by username — for duplicate usernames, keep the one
        # whose key matches the username (canonical entry), else keep last.
        seen_usernames = {}
        for username, row in zip(users_json.keys(), user_rows):
            uname = row[1]
            if uname not in seen_usernames:
                seen_usernames[uname] = row
            else:
                # prefer the entry whose dict key == username (canonical)
                if username == uname:
                    seen_usernames[uname] = row
        user_rows = list(seen_usernames.values())

        execute_values(cur,
            """INSERT INTO users (id, username, full_name, role, password_hash, is_active, created_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            user_rows
        )
        print(f"  ✓ {len(user_rows)} users (passwords reset to 'changeme')")

        # ── 3. Warehouse ──────────────────────────────────────────────────
        print("Migrating warehouses...")
        main_wh_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, "warehouse:main"))
        cur.execute(
            """INSERT INTO warehouses (id, code, name, is_active)
               VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING""",
            (main_wh_id, "main", "المستودع الرئيسي", True)
        )
        print(f"  ✓ 1 warehouse (main)")

        # ── 4. Categories & Subcategories & Products ──────────────────────
        print("Migrating products catalog...")
        categories = data_json.get("categories", {})

        cat_rows = []
        sub_rows = []
        prod_rows = []

        # Maps for FK resolution
        cat_id_map = {}   # cat_name -> uuid
        sub_id_map = {}   # (cat_name, sub_name) -> uuid

        for cat_name, subs in categories.items():
            cat_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"cat:{cat_name}"))
            cat_id_map[cat_name] = cat_id
            cat_rows.append((cat_id, cat_name))

            for sub_name, products in subs.items():
                sub_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"sub:{cat_name}:{sub_name}"))
                sub_id_map[(cat_name, sub_name)] = sub_id
                sub_rows.append((sub_id, cat_id, sub_name))

                if not isinstance(products, list):
                    continue
                for p in products:
                    pid = safe_uuid(p.get("id"))
                    prod_rows.append((
                        pid,
                        sub_id,
                        p.get("name", ""),
                        p.get("barcode") or None,
                        p.get("unit", "عدد"),
                        dec(p.get("retail_price", p.get("price", 0))),
                        dec(p.get("wholesale_price", 0)),
                        dec(p.get("cost_price", 0)),
                        p.get("company") or None,
                        p.get("size") or None,
                        p.get("type") or None,
                        p.get("material") or None,
                        p.get("image_path") or None,
                        True,
                        ts(p.get("created_at")) or datetime.utcnow().isoformat(),
                        ts(p.get("updated_at")) or datetime.utcnow().isoformat(),
                    ))

        execute_values(cur,
            "INSERT INTO categories (id, name) VALUES %s ON CONFLICT (id) DO NOTHING",
            cat_rows
        )
        execute_values(cur,
            "INSERT INTO subcategories (id, category_id, name) VALUES %s ON CONFLICT (id) DO NOTHING",
            sub_rows
        )
        execute_values(cur,
            """INSERT INTO products
               (id, subcategory_id, name, barcode, unit,
                retail_price, wholesale_price, cost_price,
                company, size, type, material, image_url,
                is_active, created_at, updated_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            prod_rows
        )
        print(f"  ✓ {len(cat_rows)} categories, {len(sub_rows)} subcategories, {len(prod_rows)} products")

        # ── 5. Stock Movements ────────────────────────────────────────────
        print("Migrating stock movements...")
        # Collect valid product IDs already inserted
        cur.execute("SELECT id::text FROM products")
        valid_product_ids = {row[0] for row in cur.fetchall()}

        mv_rows = []
        skipped_mv = 0
        for mv in movements_json:
            pid = mv.get("product_id", "")
            if pid not in valid_product_ids:
                skipped_mv += 1
                continue
            mv_rows.append((
                safe_uuid(mv.get("id")),
                pid,
                main_wh_id,
                mv.get("movement_type", "opening_stock"),
                dec(mv.get("qty", 0)),
                dec(mv.get("unit_cost", 0)),
                dec(mv.get("unit_price", 0)),
                mv.get("ref_id") or None,
                mv.get("ref_type") or None,
                mv.get("note") or None,
                user_id_map.get(mv.get("created_by", ""), None),
                ts(mv.get("created_at")) or datetime.utcnow().isoformat(),
            ))

        execute_values(cur,
            """INSERT INTO stock_movements
               (id, product_id, warehouse_id, movement_type, qty,
                unit_cost, unit_price, ref_id, ref_type, note, created_by, created_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            mv_rows
        )
        print(f"  ✓ {len(mv_rows)} stock movements ({skipped_mv} skipped — orphaned product refs)")

        # ── 6. Shifts & Drawer Transactions ───────────────────────────────
        print("Migrating shifts and drawer transactions...")
        # Collect valid user IDs
        cur.execute("SELECT id::text FROM users")
        valid_user_ids = {row[0] for row in cur.fetchall()}

        shift_rows = []
        tx_rows = []

        for shift in drawer_json:
            sid = safe_uuid(shift.get("id"))
            cashier_id = user_id_map.get(shift.get("user_id", ""), None)
            if cashier_id not in valid_user_ids:
                cashier_id = None
            closed_by_id = user_id_map.get(shift.get("closed_by", ""), None)
            if closed_by_id not in valid_user_ids:
                closed_by_id = None
            status = shift.get("status", "closed")

            shift_rows.append((
                sid,
                cashier_id,
                status,
                dec(shift.get("initial_amount", 0)),
                dec(shift.get("closing_balance", 0)) if status != "open" else None,
                dec(shift.get("next_day_drawer", 0)) if status != "open" else None,
                closed_by_id,
                shift.get("notes") or None,
                ts(shift.get("start_time")) or datetime.utcnow().isoformat(),
                ts(shift.get("end_time")) if status != "open" else None,
            ))

            for tx in shift.get("transactions", []):
                tx_type = tx.get("type", "sale")
                # map old type names to enum values
                type_map = {"sale": "sale", "return": "return", "expense": "expense"}
                tx_type = type_map.get(tx_type, "sale")
                tx_rows.append((
                    safe_uuid(tx.get("id")),
                    sid,
                    tx_type,
                    dec(tx.get("amount", 0)),
                    tx.get("notes") or None,
                    None,  # created_by — not stored in old format
                    ts(tx.get("time")) or datetime.utcnow().isoformat(),
                ))

        execute_values(cur,
            """INSERT INTO shifts
               (id, cashier_id, status, initial_amount, closing_balance,
                next_day_drawer, closed_by, notes, started_at, closed_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            shift_rows
        )
        execute_values(cur,
            """INSERT INTO drawer_transactions
               (id, shift_id, type, amount, note, created_by, created_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            tx_rows
        )
        print(f"  ✓ {len(shift_rows)} shifts, {len(tx_rows)} drawer transactions")

        # ── 7. Archive ────────────────────────────────────────────────────
        print("Migrating archive...")
        archive_rows = []
        for doc in archive_json:
            archive_rows.append((
                str(uuid.uuid5(uuid.NAMESPACE_DNS, f"doc:{doc['id']}")),
                doc.get("id", ""),
                "sale_invoice",
                doc.get("customer", "") or None,
                dec(doc.get("amount", 0)) or None,
                doc.get("filename") or None,
                json.dumps(doc.get("metadata", {}), ensure_ascii=False),
                None,  # created_by
                ts(doc.get("date")) or datetime.utcnow().isoformat(),
            ))

        execute_values(cur,
            """INSERT INTO archived_documents
               (id, doc_number, doc_type, customer_name, amount,
                file_path, metadata, created_by, created_at)
               VALUES %s ON CONFLICT (id) DO NOTHING""",
            archive_rows
        )
        print(f"  ✓ {len(archive_rows)} archived documents")

        conn.commit()
        print()
        print("✅ Migration complete!")
        print()
        print("⚠️  All user passwords have been reset to: changeme")
        print("    Ask each user to change their password after first login.")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Migration failed: {e}")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Migrate JSON data to PostgreSQL")
    parser.add_argument("--source", default="/home/ammar/Desktop/AMMAR/جرد", help="Path to old system directory")
    parser.add_argument("--db-url", default=os.getenv("DATABASE_URL", ""), help="PostgreSQL connection URL")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be migrated without writing")
    args = parser.parse_args()

    if not args.db_url:
        print("ERROR: --db-url or DATABASE_URL env var required")
        sys.exit(1)

    migrate(args.source, args.db_url, args.dry_run)
