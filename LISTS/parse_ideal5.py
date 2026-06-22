"""
Final clean parser for Ideal Standard PDF - fixes all edge cases.
"""
import re

with open(r'C:\eg-co-erp\LISTS\ideal_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

pages = text.split('=== PAGE ')

products = []
current_series = 'Unknown'

SERIES_NAMES = [
    'TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
    'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
    'SAN REMO', 'SAN REMO SPECIAL NEEDS', 'PLAN', 'SOPHIA', 'SPACE',
    'OTHERS', 'STUDIO ACCESSORIES', 'IOM ACCESSORIES',
    'BUILT IN CISTERN ( PROSYS )', 'PROSYS', 'URINALS',
    'ACCESSORIES & INDIVIDUAL ITEMS', 'FIXTURES COLOR',
]
series_upper = [s.upper() for s in SERIES_NAMES]

def is_code(s):
    s = s.strip()
    return bool(re.match(r'^[A-Z]\d{3,}', s)) or bool(re.match(r'^[A-Z]\s+\d{3,}', s))

for page_text in pages:
    if not page_text.strip():
        continue
    lines = page_text.strip().split('\n')
    
    # Page number/header line
    first_line = lines[0].strip()
    
    # Detect series
    for line in lines:
        ul = line.strip().upper()
        if ul in series_upper:
            current_series = SERIES_NAMES[series_upper.index(ul)]
            break
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        i += 1
        
        if not line:
            continue
        # Skip headers / non-data lines
        if line.upper() in ['PRICES', 'WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
            continue
        if re.match(r'^\d+ ===$', line):  # "13 ===" etc
            continue
        if re.match(r'^\d+[A-Za-z]', line) and not re.match(r'^\d+\.?\d*\s', line):
            # e.g. "12Ceramic Products" or "6Ceramic Products"
            continue
        # Pure numbers without letters
        if re.match(r'^\d+$', line):
            continue
        # Pure Arabic (no Latin letters/digits)
        if not re.search(r'[A-Za-z0-9]', line):
            continue
        # Lines that are only codes
        if is_code(line) and not re.match(r'\d', line):
            continue
        
        # Check if line has price data (starts with number)
        if not re.match(r'^(-?\d[\d]*\.?\d*)\s', line):
            continue
        
        # Parse the price line
        nums = []
        rest = line
        
        # Try to extract 3 numbers at start
        m = re.match(r'^(-?\d[\d]*\.?\d*)\s+(-?\d[\d]*\.?\d*)?\s+(-?\d+\.?\d*)?\s+(.+)$', line)
        if m:
            for g in [m.group(1), m.group(2), m.group(3)]:
                if g and g.strip() not in ('', '-'):
                    nums.append(g.strip())
            rest = m.group(4).strip()
        else:
            # Try 1 number
            m = re.match(r'^(-?\d[\d]*\.?\d*)\s+(.+)$', line)
            if m:
                nums.append(m.group(1).strip())
                rest = m.group(2).strip()
            else:
                continue
        
        # Clean leading dash/hyphen from description
        if rest.startswith('- '):
            rest = rest[2:]
        if rest.startswith('-- '):
            rest = rest[3:]
        
        # Extract code from description if at end
        desc = rest
        code = ''
        words = desc.split()
        if words and is_code(words[-1]):
            code = words[-1]
            desc = ' '.join(words[:-1])
        
        # Look ahead for continuation lines
        while i < len(lines):
            nxt = lines[i].strip()
            if not nxt:
                i += 1
                continue
            
            # Code-only line
            if is_code(nxt) and not re.match(r'\d', nxt):
                code = nxt.replace(' ', '')
                i += 1
                continue
            
            # Skip Arabic-only
            if not re.search(r'[A-Za-z0-9]', nxt):
                i += 1
                continue
            # Skip pure numbers
            if re.match(r'^\d+$', nxt):
                i += 1
                continue
            # Skip headers
            if nxt.upper() in ['PRICES', 'WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
                i += 1
                continue
            # Skip "N ==="
            if re.match(r'^\d+ ===$', nxt):
                i += 1
                continue
            # Check if new price line
            if re.match(r'^(-?\d[\d]*\.?\d*)\s', nxt) and re.search(r'[A-Za-z]', nxt):
                break
            
            # Continuation: check for code at end
            w = nxt.split()
            if w and is_code(w[-1]):
                code = w[-1]
                desc += ' ' + ' '.join(w[:-1])
            else:
                desc += ' ' + nxt
            
            i += 1
        
        white = nums[0] if len(nums) > 0 else '0'
        perga = nums[1] if len(nums) > 1 else white
        weight = nums[2] if len(nums) > 2 else '0'
        
        products.append({
            'series': current_series,
            'code': code,
            'description': desc.strip(),
            'white_price': white,
            'pergamon_price': perga,
            'weight': weight,
        })

print(f"Total: {len(products)}")
with_code = [p for p in products if p['code']]
without_code = [p for p in products if not p['code']]
print(f"With codes: {len(with_code)}, Without codes: {len(without_code)}")

from collections import Counter
series_counts = Counter(p['series'] for p in with_code)
for s, c in series_counts.most_common():
    print(f"  {s}: {c}")

import pandas as pd
df = pd.DataFrame(products)
df.to_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx', index=False)
print(f"\nSaved to ايديال.xlsx - {len(products)} rows")

if without_code:
    print(f"\nFirst 20 without codes:")
    for p in without_code[:20]:
        print(f"  {p['description'][:80]} [{p['white_price']}/{p['pergamon_price']}]")
