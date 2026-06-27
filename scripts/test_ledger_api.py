import urllib.request, json

req = urllib.request.Request('http://localhost:8000/reports/ledger/daily-items?target_date=2026-06-24')
req.add_header('Authorization', 'Bearer test')
try:
    r = urllib.request.urlopen(req)
    d = json.loads(r.read())
    print('items:', len(d.get('items',[])), 'expenses:', len(d.get('expenses',[])))
except urllib.error.HTTPError as e:
    print('HTTP', e.code, e.reason)
    print(e.read().decode())
