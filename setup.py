#!/usr/bin/env python3
"""
setup.py — Full project setup for a new machine.

Usage:
  python setup.py [--domain eg-co.duckdns.org] [--db-dump eg_co_erp_db.dump]

What it does:
  1. Checks prerequisites (Docker, git, curl)
  2. Prompts for domain (default: eg-co.duckdns.org)
  3. Updates store_settings with the domain
  4. Loads the production DB dump as initial data
  5. Builds & starts all Docker services
  6. Prints Nginx Proxy Manager config instructions
"""

from __future__ import annotations

import argparse
import logging
import shutil
import subprocess
import sys
import time
from pathlib import Path

logging.basicConfig(
    format="%(message)s",
    level=logging.INFO,
)
log = logging.getLogger("setup")

REPO_ROOT = Path(__file__).parent.resolve()

COMPOSE_FILE = REPO_ROOT / "docker-compose.yml"
INIT_SQL = REPO_ROOT / "init_data.sql"
DB_DUMP = REPO_ROOT / "eg_co_erp_db.dump"


def check_prereqs() -> None:
    for cmd in ("docker", "git", "curl"):
        if not shutil.which(cmd):
            log.error("❌ %s not found in PATH. Install it first.", cmd)
            sys.exit(1)
    log.info("✅ Prerequisites: docker, git, curl")


def prompt_domain() -> str:
    default = "eg-co.duckdns.org"
    try:
        val = input(f"Enter domain [{default}]: ").strip()
        return val or default
    except (EOFError, KeyboardInterrupt):
        return default


def get_db_dump_path(custom: str | None) -> Path:
    if custom:
        p = Path(custom)
        if not p.exists():
            p = REPO_ROOT / custom
        if not p.exists():
            log.error("❌ DB dump not found: %s", custom)
            sys.exit(1)
        return p.resolve()
    if DB_DUMP.exists():
        return DB_DUMP
    log.warning("⚠️  No DB dump found — will use empty database.")
    return None


def update_init_sql(domain: str) -> None:
    store_settings_sql = f"""
-- Store settings (domain-aware)
INSERT INTO store_settings (key, value) VALUES
  ('store_name', 'EG-CO'),
  ('store_phone', ''),
  ('store_address', ''),
  ('domain', '{domain}'),
  ('tax_number', ''),
  ('currency', 'EGP'),
  ('paper_size', 'A4')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
"""
    INIT_SQL.write_text(store_settings_sql, encoding="utf-8")
    log.info("✅ init_data.sql written with domain: %s", domain)


def init_from_dump(dump_path: Path) -> None:
    log.info("📥 Loading production DB dump as init data...")
    db_service = "db"
    db_user = "postgres"
    db_name = "inventory_db"

    log.info("   Copying dump into container...")
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE),
         "cp", str(dump_path), f"{db_service}:/tmp/setup_dump.dump"],
        check=True, capture_output=True,
    )

    log.info("   Dropping & recreating database...")
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE),
         "exec", "-T", db_service, "psql", "-U", db_user,
         "-c", f"DROP DATABASE IF EXISTS {db_name};"],
        check=True, capture_output=True,
    )
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE),
         "exec", "-T", db_service, "psql", "-U", db_user,
         "-c", f"CREATE DATABASE {db_name};"],
        check=True, capture_output=True,
    )

    log.info("   Restoring from dump...")
    result = subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE),
         "exec", "-T", db_service,
         "pg_restore", "-U", db_user, "-d", db_name,
         "--no-owner", "--no-acl", "/tmp/setup_dump.dump"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        errors = [l for l in result.stderr.splitlines()
                  if "ERROR" in l and "already exists" not in l]
        if errors:
            log.warning("⚠️  Restore warnings:\n%s", "\n".join(errors[:5]))

    log.info("   Cleaning up temp file...")
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE),
         "exec", "-T", db_service, "rm", "-f", "/tmp/setup_dump.dump"],
        capture_output=True,
    )

    log.info("✅ Production data loaded as initial state.")


def ensure_init_sql_exists(domain: str) -> None:
    if not INIT_SQL.exists() or INIT_SQL.stat().st_size < 100:
        update_init_sql(domain)


def build_and_start() -> None:
    log.info("🔨 Building Docker images...")
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE), "build", "--no-cache"],
        check=True,
    )

    log.info("▶️  Starting services...")
    subprocess.run(
        ["docker", "compose", "-f", str(COMPOSE_FILE), "up", "-d"],
        check=True,
    )

    log.info("⏳ Waiting for services to be healthy...")
    for i in range(30):
        try:
            r = subprocess.run(
                ["curl", "-sf", "http://localhost/api/health"],
                capture_output=True, text=True, timeout=5,
            )
            if r.returncode == 0 and "ok" in r.stdout:
                log.info("✅ System is healthy!")
                return
        except Exception:
            pass
        if i == 15:
            log.info("   Still waiting... (this can take ~60s on first boot)")
        time.sleep(2)

    log.warning("⚠️  Health check timed out — check 'docker compose ps'")


def print_nginxpm_instructions(domain: str) -> None:
    log.info("")
    log.info("=" * 60)
    log.info("🌐 Nginx Proxy Manager Configuration")
    log.info("=" * 60)
    log.info("")
    log.info("1. Open http://YOUR_SERVER_IP:81")
    log.info("   Default login: admin@example.com / changeme")
    log.info("")
    log.info("2. Add Proxy Host:")
    log.info(f"   Domain: {domain}")
    log.info("   Scheme: http")
    log.info("   Forward IP: localhost or 127.0.0.1")
    log.info("   Forward Port: 8080")
    log.info("")
    log.info("3. Enable SSL:")
    log.info("   - Force SSL: ✅")
    log.info("   - SSL Certificate: Request a new Let's Encrypt cert")
    log.info(f"   - Domain: {domain}")
    log.info("")
    log.info("4. (Optional) Add another Proxy Host for NPM itself:")
    log.info(f"   Domain: npm.{domain}")
    log.info("   Forward Port: 81")
    log.info("")
    log.info("=" * 60)
    log.info("🌐 System is ready!")
    log.info(f"   URL: https://{domain}")
    log.info("   Admin: ammar / changeme")
    log.info("   NPM:  http://YOUR_SERVER_IP:81")
    log.info("=" * 60)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Full EG-CO ERP setup for a new machine",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python setup.py\n"
            "  python setup.py --domain eg-co.duckdns.org\n"
            "  python setup.py --db-dump /path/to/dump.dump\n"
        ),
    )
    parser.add_argument("--domain", help="Domain for the ERP (e.g. eg-co.duckdns.org)")
    parser.add_argument(
        "--db-dump", default=str(DB_DUMP),
        help=f"Path to production DB dump (default: {DB_DUMP})",
    )
    parser.add_argument("--skip-build", action="store_true", help="Skip Docker build step")
    args = parser.parse_args()

    log.info("=" * 60)
    log.info("🚀 EG-CO ERP — Full Setup")
    log.info("=" * 60)
    log.info("")

    check_prereqs()

    domain = args.domain or prompt_domain()
    dump_path = get_db_dump_path(args.db_dump)

    if not COMPOSE_FILE.exists():
        log.error("❌ docker-compose.yml not found at %s", COMPOSE_FILE)
        sys.exit(1)

    if dump_path:
        log.info("")
        log.info("⚙️  Step 1: Start DB service to load dump...")
        subprocess.run(
            ["docker", "compose", "-f", str(COMPOSE_FILE), "up", "-d", "db"],
            check=True,
        )

        log.info("⏳ Waiting for DB to be ready...")
        for _ in range(30):
            r = subprocess.run(
                ["docker", "compose", "-f", str(COMPOSE_FILE),
                 "exec", "-T", "db", "pg_isready", "-U", "postgres"],
                capture_output=True, text=True,
            )
            if r.returncode == 0:
                break
            time.sleep(2)
        else:
            log.error("❌ Database did not become ready")
            sys.exit(1)

        init_from_dump(dump_path)

        log.info("")
        log.info("⚙️  Step 2: Updating store settings with domain...")
        subprocess.run(
            ["docker", "compose", "-f", str(COMPOSE_FILE),
             "exec", "-T", "db", "psql", "-U", "postgres", "-d", "inventory_db",
             "-c", f"""
INSERT INTO store_settings (key, value) VALUES
  ('store_name', 'EG-CO'),
  ('store_phone', ''),
  ('store_address', ''),
  ('domain', '{domain}'),
  ('tax_number', ''),
  ('currency', 'EGP'),
  ('paper_size', 'A4')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
"""],
            capture_output=True,
        )
        log.info("✅ Store settings updated for domain: %s", domain)

        log.info("")
        log.info("⚙️  Step 3: Snapshot DB to init_data.sql for future fresh deploys...")
        raw = subprocess.run(
            ["docker", "compose", "-f", str(COMPOSE_FILE),
             "exec", "-T", "db",
             "pg_dump", "-U", "postgres", "--no-owner", "--no-acl", "inventory_db"],
            capture_output=True,
        ).stdout
        INIT_SQL.write_bytes(raw)
        lines = str(raw.count(b"\n"))
        log.info("✅ init_data.sql created (%s lines)", lines)

        log.info("")
        log.info("⚙️  Step 4: Rebuild all services...")
        subprocess.run(
            ["docker", "compose", "-f", str(COMPOSE_FILE), "down"],
            check=True,
        )
    else:
        ensure_init_sql_exists(domain)

    if not args.skip_build:
        build_and_start()
    else:
        log.info("⏭️  Skipping build (--skip-build)")

    print_nginxpm_instructions(domain)


if __name__ == "__main__":
    main()
