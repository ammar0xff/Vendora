#!/usr/bin/env python3
"""
manage.py — ERP system management script
Usage: python manage.py [deploy|stop|restart|status|backup|restore <file>|logs]
"""
import subprocess, sys, os, datetime
from pathlib import Path

ROOT = Path(__file__).parent
COMPOSE = ["docker", "compose", "-f", str(ROOT / "docker-compose.yml")]
BACKUP_DIR = ROOT / "backups"


def run(cmd, check=True, capture=False):
    return subprocess.run(cmd, check=check, capture_output=capture, text=True)


def compose(*args):
    return run(COMPOSE + list(args))


def status():
    print("\n=== Container Status ===")
    compose("ps")
    print("\n=== Health Check ===")
    try:
        r = subprocess.run(["curl", "-s", "http://localhost/api/health"], capture_output=True, text=True, timeout=5)
        if r.returncode == 0 and "ok" in r.stdout:
            print("✅ System is UP — http://localhost")
        else:
            print("❌ System is DOWN or not responding")
    except Exception:
        print("❌ Cannot reach http://localhost")


def deploy():
    """Update code only — keeps existing DB data. Safe for production updates."""
    print("🚀 Deploying code update (data preserved)...")
    print("💾 Step 1/3: Backup current data...")
    backup()
    print("🔨 Step 2/3: Build new images...")
    compose("build")
    print("▶️  Step 3/3: Restart services (volumes untouched)...")
    compose("up", "-d")
    print("\n✅ Deployed. Your data is safe.")
    status()


def deploy_fast():
    """Update code WITHOUT backup — faster, no safety net."""
    confirm = input("⚠️  Deploy without backup? Type 'yes' to confirm: ")
    if confirm.strip().lower() != "yes":
        print("Cancelled.")
        return
    print("🚀 Fast deploy...")
    compose("build")
    compose("up", "-d")
    print("\n✅ Deployed.")
    status()


def deploy_fresh():
    """
    Fresh deploy using init_data.sql from repo.
    ⚠️  WIPES ALL EXISTING DATA and loads the repo snapshot.
    Use on new machines or to reset to repo state.
    """
    confirm = input("⚠️  This will WIPE ALL DATA and load init_data.sql from repo.\nType 'yes' to confirm: ")
    if confirm.strip().lower() != "yes":
        print("Cancelled.")
        return

    init_sql = ROOT / "init_data.sql"
    if not init_sql.exists():
        print("❌ init_data.sql not found in repo root.")
        return

    print("🗑️  Step 1/4: Stop and remove volumes...")
    compose("down", "-v")
    print("🔨 Step 2/4: Build images...")
    compose("build")
    print("▶️  Step 3/4: Start (init_data.sql loads automatically)...")
    compose("up", "-d")
    print("⏳ Step 4/4: Waiting for DB to initialize...")
    import time
    for _ in range(30):
        time.sleep(2)
        try:
            result = run(["curl", "-sf", "http://localhost/api/health"], capture=True, check=False)
            if result.returncode == 0 and "ok" in result.stdout:
                break
        except Exception:
            pass
    print("\n✅ Fresh deploy complete. Data loaded from init_data.sql.")
    status()


def stop():
    print("🛑 Stopping all services...")
    compose("stop")
    print("✅ Stopped.")


def restart():
    print("🔄 Restarting all services...")
    compose("restart")
    print("✅ Restarted.")
    status()


def backup():
    BACKUP_DIR.mkdir(exist_ok=True)
    ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    out = BACKUP_DIR / f"backup_{ts}.sql"
    print(f"💾 Creating backup → {out}")
    result = subprocess.run(
        COMPOSE + ["exec", "-T", "db", "pg_dump", "-U", "postgres", "inventory_db"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"❌ Backup failed:\n{result.stderr}")
        sys.exit(1)
    out.write_text(result.stdout, encoding="utf-8")
    size = out.stat().st_size // 1024
    print(f"✅ Backup saved: {out} ({size} KB)")

    # Keep only last 10 backups
    backups = sorted(BACKUP_DIR.glob("backup_*.sql"))
    for old in backups[:-10]:
        old.unlink()
        print(f"🗑️  Removed old backup: {old.name}")


def restore(file: str):
    path = Path(file)
    if not path.exists():
        # Try in backups dir
        path = BACKUP_DIR / file
    if not path.exists():
        print(f"❌ File not found: {file}")
        print(f"Available backups:")
        for b in sorted(BACKUP_DIR.glob("backup_*.sql")):
            print(f"  {b.name}")
        sys.exit(1)

    confirm = input(f"⚠️  This will OVERWRITE all data with {path.name}. Type 'yes' to confirm: ")
    if confirm.strip().lower() != "yes":
        print("Cancelled.")
        return

    print(f"📥 Restoring from {path}...")
    # Stop backend to avoid connections
    compose("stop", "backend", "frontend")

    # Drop and recreate DB
    run(COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "-c", "DROP DATABASE IF EXISTS inventory_db;"])
    run(COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "-c", "CREATE DATABASE inventory_db;"])

    # Restore
    result = subprocess.run(
        COMPOSE + ["exec", "-T", "db", "psql", "-U", "postgres", "inventory_db"],
        input=path.read_text(encoding="utf-8"),
        capture_output=True, text=True
    )
    errors = [l for l in result.stderr.splitlines() if "ERROR" in l and "already exists" not in l]
    if errors:
        print(f"⚠️  Warnings during restore:\n" + "\n".join(errors[:5]))

    compose("start", "backend", "frontend")
    print("✅ Restore complete.")
    status()


def logs():
    print("📋 Showing last 50 lines (Ctrl+C to exit)...")
    try:
        compose("logs", "--tail=50", "-f")
    except KeyboardInterrupt:
        pass


def setup():
    """First-time setup: check Docker, build images, load initial data."""
    print("🔧 Running first-time setup...")

    # Check Docker
    try:
        run(["docker", "info"], capture=True)
    except Exception:
        print("❌ Docker is not running. Please start Docker Desktop first.")
        sys.exit(1)

    # Check init_data.sql
    init_sql = ROOT / "init_data.sql"
    if not init_sql.exists():
        print("⚠️  No init_data.sql found — starting with empty database.")

    compose("up", "-d", "--build")
    print("\n✅ Setup complete!")
    print("🌐 Open your browser at: http://localhost")
    print("👤 Login: ammar / changeme")
    status()


COMMANDS = {
    "deploy":        (deploy,        "Update code + backup first (safe, keeps your data)"),
    "deploy-fast":   (deploy_fast,   "Update code WITHOUT backup (faster, no safety net)"),
    "deploy-fresh":  (deploy_fresh,  "⚠️  WIPE data + load init_data.sql from repo (new machine / reset)"),
    "stop":          (stop,          "Stop all services"),
    "restart":       (restart,       "Restart all services"),
    "status":        (status,        "Show running status and health"),
    "backup":        (backup,        "Backup database to backups/"),
    "restore":       (restore,       "Restore database from a backup file"),
    "logs":          (logs,          "Tail live logs from all services"),
    "setup":         (setup,         "First-time setup"),
}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        print("ERP Management Script\n")
        print("Usage: python manage.py <command>\n")
        print("Commands:")
        for cmd, (_, desc) in COMMANDS.items():
            print(f"  {cmd:<12} {desc}")
        print("\nExamples:")
        print("  python manage.py setup")
        print("  python manage.py backup")
        print("  python manage.py restore backup_20260329_120000.sql")
        sys.exit(0)

    cmd = sys.argv[1]
    fn, _ = COMMANDS[cmd]

    if cmd == "restore":
        if len(sys.argv) < 3:
            # List available backups
            print("Available backups:")
            for b in sorted(BACKUP_DIR.glob("backup_*.sql")) if BACKUP_DIR.exists() else []:
                print(f"  {b.name}")
            print("\nUsage: python manage.py restore <filename>")
            sys.exit(0)
        fn(sys.argv[2])
    else:
        fn()
