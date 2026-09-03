#!/usr/bin/env python3
"""
Deploy updater + manifest to server.
Run from project root:  python deploy_updater.py
"""
import subprocess, sys, json, os

UPDATES_DIR = "updates"
WINDOWS_DIR = os.path.join(UPDATES_DIR, "windows-x86_64")

os.makedirs(WINDOWS_DIR, exist_ok=True)

manifest = {
    "version": "0.2.0",
    "notes": "تم إصلاح تنبيهات المخزون السالب وتحسين الطباعة",
    "pub_date": "2026-07-19T00:00:00Z",
    "platforms": {
        "windows-x86_64": {
            "url": "https://eg-co.duckdns.org/updates/windows-x86_64/EG-CO-ERP_0.2.0_x64-setup.exe",
            "signature": "dGVzdHNpZ25hdHVyZQ=="
        }
    }
}

with open(os.path.join(UPDATES_DIR, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)

print("Created updates/manifest.json\n")

steps = [
    "cd C:\\eg-co-erp && git pull",
    "docker exec eg-co-erp-backend-1 pip install packaging",
    "docker cp backend\\app\\api\\routers\\updater.py eg-co-erp-backend-1:/app/app/api/routers/updater.py",
    "docker cp backend\\app\\api\\router.py eg-co-erp-backend-1:/app/app/api/router.py",
    "docker cp backend\\main.py eg-co-erp-backend-1:/app/main.py",
    "docker cp backend\\requirements.txt eg-co-erp-backend-1:/app/requirements.txt",
    "docker cp C:\\eg-co-erp\\updates eg-co-erp-backend-1:/app/updates",
    "docker restart eg-co-erp-backend-1",
]

for cmd in steps:
    print(f"> {cmd}")
    subprocess.run(["powershell", "-Command", cmd], timeout=120)
    print()

print("Waiting for backend to start...")
import time; time.sleep(10)

print("=== Test endpoint ===")
subprocess.run(["powershell", "-Command",
    'docker exec eg-co-erp-backend-1 curl -s http://localhost:8000/api/updater/windows-x86_64/0.1.0'], timeout=30)

print("\n=== Verify containers ===")
subprocess.run(["powershell", "-Command",
    'docker ps --format "table {{.Names}}\\t{{.Status}}"'], timeout=15)

print("\nDone!")
