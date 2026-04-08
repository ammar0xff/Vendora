#!/usr/bin/env python3
"""
ZK device sync script — runs on the HOST (not inside Docker).
Pulls attendance from the biometric device and posts to the ERP API.

Usage:
    python3 zk_sync.py --host 192.168.1.201 --api http://localhost --user admin --password changeme

Install deps:  pip install pyzk requests
Schedule:      crontab -e  →  */30 * * * * python3 /path/to/zk_sync.py
"""
import argparse
import requests
from collections import defaultdict
from datetime import timezone

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--device-host', default='192.168.1.201')
    parser.add_argument('--device-port', type=int, default=4370)
    parser.add_argument('--api', default='http://localhost')
    parser.add_argument('--user', default='admin')
    parser.add_argument('--password', default='changeme')
    args = parser.parse_args()

    # Login
    r = requests.post(f'{args.api}/api/auth/login', json={'username': args.user, 'password': args.password})
    r.raise_for_status()
    token = r.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # Connect to ZK device
    try:
        from zk import ZK
    except ImportError:
        print("Install pyzk:  pip install pyzk")
        return

    zk = ZK(args.device_host, port=args.device_port, timeout=5)
    conn = zk.connect()
    conn.disable_device()
    punches = conn.get_attendance()
    conn.enable_device()
    conn.disconnect()
    print(f"Fetched {len(punches)} punches from device")

    # Group by (user_id, date) → first=check_in, last=check_out
    groups = defaultdict(list)
    for p in punches:
        dt = p.timestamp
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        groups[(str(p.user_id), dt.date().isoformat())].append(dt.isoformat())

    # Post to API
    added = updated = skipped = 0
    for (uid, date), times in groups.items():
        times.sort()
        payload = {
            'device_uid': uid,
            'work_date': date,
            'check_in': times[0],
            'check_out': times[-1] if len(times) > 1 else None,
        }
        r = requests.post(f'{args.api}/api/hr/attendance/from-device', json=payload, headers=headers)
        if r.status_code == 200:
            result = r.json()
            if result.get('action') == 'added': added += 1
            elif result.get('action') == 'updated': updated += 1
            else: skipped += 1
        else:
            print(f"  WARN {date} uid={uid}: {r.status_code} {r.text[:80]}")

    print(f"Done — added={added} updated={updated} skipped={skipped}")

if __name__ == '__main__':
    main()
