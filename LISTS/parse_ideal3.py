"""
Multi-line parser for Ideal Standard PDF data - handles wrapped descriptions and codes on separate lines.
"""
import re

with open(r'C:\eg-co-erp\LISTS\ideal_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

pages = text.split('=== PAGE ')

SERIES_NAMES = [
    'TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
    'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
    'SAN REMO', 'SAN REMO SPECIAL NEEDS', 'PLAN', 'SOPHIA', 'SPACE',
    'OTHERS', 'STUDIO ACCESSORIES', 'IOM ACCESSORIES',
    'BUILT IN CISTERN', 'PROSYS', 'URINALS', 'ACCESSORIES',
    'FIXTURES COLOR',
]

def is_code_line(s):
    """Check if line is a product code like K3104, G3121, E803701, G0093AC"""
    return bool(re.match(r'^[A-Z]\d+', s)) and len(s) >= 4

def is_price_line(s):
    """Check if line starts with price data."""
    return bool(re.match(r'^(-?\d[\d]*\.?\d*)\s', s))

def strip_arabic(s):
    """Remove Arabic-only lines (no Latin letters or digits)."""
    if re.search(r'[A-Za-z0-9]', s):
        return s
    return ''

series_names_upper = [s.upper() for s in SERIES_NAMES]

products = []
current_series = 'Unknown'

for page in pages:
    if not page.strip():
        continue
    lines = page.strip().split('\n')
    
    # Detect series from page
    for line in lines:
        s = line.strip().upper()
        if s in series_names_upper:
            idx = series_names_upper.index(s)
            current_series = SERIES_NAMES[idx]
            break
    
    # Multi-line parsing: accumulate product data
    buffer_desc = ''
    buffer_prices = []
    pending_code = ''
    
    for line in lines:
        s = line.strip()
        if not s:
            continue
        
        # Skip header lines
        if s.upper() in ['PRICES', 'WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
            continue
        if s.upper().startswith('CERAMIC PRODUCTS'):
            continue
        
        # Skip pure Arabic lines
        if not re.search(r'[A-Za-z0-9]', s):
            # Check if it has product codes or data
            if re.search(r'\d', s):
                # Arabic numbers - keep? might have data
                pass
            continue
        
        # Check if this is a product code line
        if is_code_line(s) and not is_price_line(s):
            if buffer_desc:
                # Code for current pending product
                pending_code = s
                # Emit product
                if buffer_prices:
                    white = buffer_prices[0] if len(buffer_prices) > 0 else '0'
                    perga = buffer_prices[1] if len(buffer_prices) > 1 else white
                    weight = buffer_prices[2] if len(buffer_prices) > 2 else '0'
                    products.append({
                        'series': current_series,
                        'code': pending_code,
                        'description': buffer_desc.strip(),
                        'white_price': white,
                        'pergamon_price': perga,
                        'weight': weight,
                    })
                buffer_desc = ''
                buffer_prices = []
                pending_code = ''
            continue
        
        # Check if line starts with price data
        m = re.match(r'^(-?\d[\d]*\.?\d*)\s+(-?\d[\d]*\.?\d*)?\s+(-?\d+\.?\d*)?\s+(.+)$', s)
        if m:
            # If we have existing buffer, save it first
            if buffer_prices and buffer_desc:
                white = buffer_prices[0] if len(buffer_prices) > 0 else '0'
                perga = buffer_prices[1] if len(buffer_prices) > 1 else white
                weight = buffer_prices[2] if len(buffer_prices) > 2 else '0'
                products.append({
                    'series': current_series,
                    'code': pending_code,
                    'description': buffer_desc.strip(),
                    'white_price': white,
                    'pergamon_price': perga,
                    'weight': weight,
                })
            
            # Start new product
            groups = m.groups()
            nums = [g for g in groups[:3] if g and g != '-']
            buffer_prices = nums
            buffer_desc = groups[3].strip() if groups[3] else ''
            pending_code = ''
            continue
        
        # Line with fewer numbers or different format
        m2 = re.match(r'^(-?\d[\d]*\.?\d*)\s+(-?\d+\.?\d*)?\s+(.+)$', s)
        if m2:
            if buffer_prices and buffer_desc:
                white = buffer_prices[0] if len(buffer_prices) > 0 else '0'
                perga = buffer_prices[1] if len(buffer_prices) > 1 else white
                weight = buffer_prices[2] if len(buffer_prices) > 2 else '0'
                products.append({
                    'series': current_series,
                    'code': pending_code,
                    'description': buffer_desc.strip(),
                    'white_price': white,
                    'pergamon_price': perga,
                    'weight': weight,
                })
            
            nums = [g for g in m2.groups()[:2] if g and g != '-']
            buffer_prices = nums
            buffer_desc = m2.group(3).strip() if m2.group(3) else ''
            pending_code = ''
            continue
        
        m3 = re.match(r'^(-?\d[\d]*\.?\d*)\s+(.+)$', s)
        if m3:
            if buffer_prices and buffer_desc:
                white = buffer_prices[0] if len(buffer_prices) > 0 else '0'
                perga = buffer_prices[1] if len(buffer_prices) > 1 else white
                weight = buffer_prices[2] if len(buffer_prices) > 2 else '0'
                products.append({
                    'series': current_series,
                    'code': pending_code,
                    'description': buffer_desc.strip(),
                    'white_price': white,
                    'pergamon_price': perga,
                    'weight': weight,
                })
            
            buffer_prices = [m3.group(1)]
            buffer_desc = m3.group(2).strip()
            pending_code = ''
            continue
        
        # Continuation line (description continues)
        if buffer_desc:
            # Check if this continuation line contains a code at the end
            words = s.split()
            if words and is_code_line(words[-1]) and not is_price_line(words[-1]):
                pending_code = words[-1]
                buffer_desc += ' ' + ' '.join(words[:-1])
            else:
                buffer_desc += ' ' + s
    
    # Flush last product
    if buffer_prices and buffer_desc:
        white = buffer_prices[0] if len(buffer_prices) > 0 else '0'
        perga = buffer_prices[1] if len(buffer_prices) > 1 else white
        weight = buffer_prices[2] if len(buffer_prices) > 2 else '0'
        products.append({
            'series': current_series,
            'code': pending_code,
            'description': buffer_desc.strip(),
            'white_price': white,
            'pergamon_price': perga,
            'weight': weight,
        })

print(f"Total products parsed: {len(products)}")

# Remove duplicates by code
seen = {}
unique = []
for p in products:
    code = p['code']
    if code and code not in seen:
        seen[code] = True
        unique.append(p)
    elif not code:
        unique.append(p)

print(f"Unique products (with codes): {len(unique)}")
print(f"Without codes: {sum(1 for p in unique if not p['code'])}")

from collections import Counter
series_counts = Counter(p['series'] for p in unique)
for s, c in series_counts.most_common():
    print(f"  {s}: {c}")

import pandas as pd
df = pd.DataFrame(unique)
df.to_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx', index=False)
print(f"\nSaved to ايديال.xlsx - first rows:")
print(df.head(3).to_string())
