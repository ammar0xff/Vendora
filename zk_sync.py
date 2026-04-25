#!/usr/bin/env python3
"""
ZK device sync — uses the old system's device adapter and attendance pairing logic directly.

Usage:
    python3 zk_sync.py
    python3 zk_sync.py --device-host 192.168.1.201 --api http://localhost --user ammar --password changeme

Install deps:  pip install pyzk requests
Schedule:      crontab -e  →  */30 * * * * python3 /path/to/zk_sync.py
"""
import sys
import argparse
import requests
import os

# Try to import from old system path (Linux or Windows)
_old_paths = [
    r'C:\موظفين',
    r'C:\Users\Right click\Desktop\موظفين',
    '/home/ammar/Desktop/AMMAR/موظفين',
]
for _p in _old_paths:
    if os.path.isdir(_p):
        sys.path.insert(0, _p)
        break

try:
    from device_adapters.k14_pro import DeviceAdapter, DeviceAdapterError
except ModuleNotFoundError:
    # Fallback: built-in minimal ZK adapter (no old system needed)
    try:
        from zk import ZK
    except ImportError:
        print("Install pyzk:  pip install pyzk requests")
        sys.exit(1)
    from collections import defaultdict
    from datetime import timezone

    class DeviceAdapterError(Exception): pass

    class DeviceAdapter:
        def __init__(self, host, port=4370, timeout=5):
            self.host = host; self.port = port; self.timeout = timeout; self.conn = None
        def connect(self):
            zk = ZK(self.host, port=self.port, timeout=self.timeout)
            try: self.conn = zk.connect()
            except Exception as e: raise DeviceAdapterError(str(e))
        def fetch_attendance(self):
            punches = self.conn.get_attendance()
            groups = defaultdict(list)
            for p in punches:
                dt = p.timestamp
                if dt.tzinfo is None: dt = dt.replace(tzinfo=timezone.utc)
                groups[(str(p.user_id), dt.date().isoformat())].append(dt)
            records = []
            for (uid, date), times in groups.items():
                times.sort()
                records.append({'emp_id': uid, 'check_in': times[0].isoformat(),
                                 'check_out': times[-1].isoformat() if len(times) > 1 else None})
            return records

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--device-host', default='192.168.1.201')
    parser.add_argument('--device-port', type=int, default=4370)
    parser.add_argument('--api', default='http://localhost')
    parser.add_argument('--user', default='ammar')
    parser.add_argument('--password', default='changeme')
    args = parser.parse_args()

    # Login to ERP
    r = requests.post(f'{args.api}/api/auth/login',
                      json={'username': args.user, 'password': args.password})
    r.raise_for_status()
    token = r.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # Fetch from device using old system's adapter (handles all ZK quirks + pairing)
    adapter = DeviceAdapter(host=args.device_host, port=args.device_port)
    adapter.connect()
    records = adapter.fetch_attendance()  # already paired check_in/check_out per day
    adapter.conn.disconnect()
    print(f"Fetched {len(records)} attendance records from device")

    # Post each record to ERP
    added = updated = skipped = 0
    for rec in records:
        r = requests.post(f'{args.api}/api/hr/attendance/from-device', json=rec, headers=headers)
        if r.status_code == 200:
            action = r.json().get('action', '')
            if action == 'added':    added += 1
            elif action == 'updated': updated += 1
            else:                    skipped += 1
        else:
            print(f"  WARN emp={rec['emp_id']} {rec.get('check_in','')[:10]}: {r.status_code} {r.text[:80]}")

    print(f"Done — added={added} updated={updated} skipped={skipped}")

if __name__ == '__main__':
    main()
