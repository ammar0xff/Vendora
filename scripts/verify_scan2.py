import json
from collections import defaultdict

with open(r'C:\Users\RIGHTC~1\AppData\Local\Temp\products_extracted.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Count how many have qty=0
zero_qty = [p for p in data if p['qty'] == 0]
print('Products with qty=0: %d' % len(zero_qty))
for p in zero_qty[:20]:
    print('  [%-50s] file=%s' % (p['name'][:50], p['file']))

# Names look clean? check for unusual ones
print()
print('Short names (<=3 chars):')
for p in data:
    if len(p['name'].strip()) <= 3:
        print('  [%s] qty=%s file=%s' % (p['name'], p['qty'], p['file']))

# Check رف 7 specifically
print()
print('رف 7 products sample:')
for p in data:
    if 'رف 7' in p['file']:
        print('  [%-50s] qty=%-10s' % (p['name'][:50], p['qty']))

# Check رف 3
print()
print('رف 3 products sample:')
for p in data:
    if 'رف 3' in p['file']:
        print('  [%-50s] qty=%-10s' % (p['name'][:50], p['qty']))
