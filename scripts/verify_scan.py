import json
from collections import defaultdict

with open(r'C:\Users\RIGHTC~1\AppData\Local\Temp\products_extracted.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

by_file = defaultdict(list)
for p in data:
    by_file[p['file']].append(p)

for fn in sorted(by_file.keys()):
    items = by_file[fn]
    print('%s: %d products' % (fn, len(items)))
    for p in items[:3]:
        n = p['name'][:60]
        q = p['qty']
        print('    [%-60s]  qty=%s' % (n, q))
    print()
