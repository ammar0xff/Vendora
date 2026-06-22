"""
Clean parser for Ideal Standard PDF - focuses on data lines with prices.
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
    'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'OTHERS',
    'STUDIO ACCESSORIES', 'IOM ACCESSORIES',
    'BUILT IN CISTERN ( PROSYS )', 'PROSYS', 'URINALS',
    'ACCESSORIES & INDIVIDUAL ITEMS', 'FIXTURES COLOR',
]
series_upper = [s.upper() for s in SERIES_NAMES]

def is_code(s):
    return bool(re.match(r'^[A-Z]\d{3,}', s.strip()))

def is_price_start(s):
    """True if line starts with a number (price) followed by space."""
    return bool(re.match(r'^\d+[\.,]?\d*\s', s)) or bool(re.match(r'^-\s+\d', s))

for page_text in pages:
    if not page_text.strip():
        continue
    lines = page_text.strip().split('\n')
    
    # Detect series
    for line in lines:
        ul = line.strip().upper()
        if ul in series_upper:
            current_series = SERIES_NAMES[series_upper.index(ul)]
            break
    
    # Accumulate multi-line products
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        i += 1
        
        if not line:
            continue
        if line.upper() in ['PRICES', 'WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
            continue
        # Skip lines like "=== PAGE N ===" or just numbers
        if line.startswith('===') or line.startswith('PAGE'):
            continue
        # Skip pure Arabic
        if not re.search(r'[A-Za-z0-9]', line):
            continue
        # Skip lines without English letters (pure numbers or arabic)
        if not re.search(r'[A-Za-z]', line):
            continue
        
        # Check if line has price data pattern
        # Format: PRICE_WHITE [PRICE_PERGA] [WEIGHT] DESCRIPTION... [CODE]
        m = re.match(r'^(-?\d[\d]*\.?\d*)\s+(-?\d[\d]*\.?\d*)?\s+(-?\d+\.?\d*)?\s+(.+)$', line)
        if not m:
            continue
        
        nums = []
        for g in [m.group(1), m.group(2), m.group(3)]:
            if g and g.strip() not in ('', '-'):
                nums.append(g.strip())
        
        rest = m.group(4).strip()
        
        # Build description by collecting continuation lines
        desc = rest
        code = ''
        
        # Check if last word of first line is a code
        words = desc.split()
        if words and is_code(words[-1]):
            code = words[-1]
            desc = ' '.join(words[:-1])
        
        # Look ahead for continuation lines and code lines
        while i < len(lines):
            next_line = lines[i].strip()
            if not next_line:
                i += 1
                continue
            
            # Check for code-only lines
            if is_code(next_line) and not is_price_start(next_line):
                code = next_line
                i += 1
                continue
            
            # Check if next line is a price line (new product)
            if is_price_start(next_line) or next_line.startswith('PRICES'):
                break
            
            # Check for Arabic-only line
            if not re.search(r'[A-Za-z0-9]', next_line):
                i += 1
                continue
            
            if not re.search(r'[A-Za-z]', next_line):
                i += 1
                continue
            
            # Continuation: check if it has a code at end
            w = next_line.split()
            if w and is_code(w[-1]) and not is_price_start(next_line):
                code = w[-1]
                desc += ' ' + ' '.join(w[:-1])
            else:
                desc += ' ' + next_line
            
            i += 1
        
        # Get prices
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

# Save
import pandas as pd
df = pd.DataFrame(products)
df.to_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx', index=False)
print(f"\nSaved to ايديال.xlsx - {len(products)} rows")

# Show products without codes
if without_code:
    print(f"\nFirst 10 without codes:")
    for p in without_code[:10]:
        print(f"  {p['description'][:80]} [{p['white_price']}/{p['pergamon_price']}]")
