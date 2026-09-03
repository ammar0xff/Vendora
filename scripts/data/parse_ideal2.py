"""
Comprehensive parser for Ideal Standard PDF - extracts all product data lines.
"""
import re

with open(r'C:\eg-co-erp\LISTS\ideal_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Find all pages with product data patterns
pages = text.split('=== PAGE ')

products = []
current_series = "Unknown"

# Known series names
SERIES_NAMES = [
    'TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
    'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
    'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'OTHERS',
    'STUDIO ACCESSORIES', 'IOM ACCESSORIES', 'BUILT IN CISTERN',
    'URINALS', 'ACCESSORIES', 'FIXTURES COLOR',
    'CERAMIC PRODUCTS', 'PROSYS',
]

def find_series_in_text(txt):
    """Detect which series a block of text belongs to."""
    lines = txt.split('\n')
    for line in lines:
        s = line.strip().upper()
        if s in [x.upper() for x in SERIES_NAMES]:
            idx = [x.upper() for x in SERIES_NAMES].index(s)
            return SERIES_NAMES[idx]
    return None

def clean_text(txt):
    """Remove Arabic lines that are just translations."""
    # Arabic lines typically have no Latin characters or product codes
    lines = txt.split('\n')
    cleaned = []
    for line in lines:
        s = line.strip()
        # Keep lines that have Latin letters or digits
        if re.search(r'[A-Za-z0-9]', s):
            cleaned.append(s)
    return '\n'.join(cleaned)

def parse_product_data(txt):
    """Parse product data lines from text."""
    results = []
    # Regex pattern for lines starting with price data
    # Various formats:
    # 1. "6550 6170 34 Bowl P K3104" - 3 numbers then desc then code
    # 2. "5160 30 Close Coupled E803701" - 2 numbers then desc then code
    # 3. "5560 Wall Hung Bowl E785001" - 1 number then desc then code
    # 4. "- 1320 6 Chair Support G0093AC" - dash for missing price
    
    lines = txt.split('\n')
    for line in lines:
        s = line.strip()
        if not s:
            continue
        
        # Check if line starts with a number (price) or dash
        m = re.match(r'^(-?\d[\d]*\.?\d*)\s+(-?\d[\d]*\.?\d*)?\s+(-?\d+\.?\d*)?\s+(.+)$', s)
        if m:
            groups = m.groups()
            # Determine how many numeric groups we have
            nums = [g for g in groups[:3] if g and g != '-']
            rest = groups[3].strip() if groups[3] else ''
            
            if rest:
                # Extract product code - typically last word matching pattern like K3104, G3121, etc
                words = rest.split()
                code = ''
                desc_parts = words
                
                # Last word might be a code like K3104, E803701, G0093AC
                if words and re.match(r'^[A-Z]\d+', words[-1]):
                    code = words[-1]
                    desc_parts = words[:-1]
                # Or might be on its own line (code only)
                
                # Try to extract product code from rest even if it was in 2nd part
                desc = ' '.join(desc_parts)
                
                white = nums[0] if len(nums) > 0 else '0'
                perga = nums[1] if len(nums) > 1 else white  # if no perga price, same as white
                weight = nums[2] if len(nums) > 2 else '0'
                
                results.append({
                    'code': code,
                    'description': desc,
                    'white_price': white,
                    'pergamon_price': perga,
                    'weight': weight,
                })
                # print(f"  {white:>6} {perga:>6} {weight:>5} {desc[:50]:<50} {code}")
    
    return results

# Parse each page
page_num = 0
for page in pages:
    page_num += 1
    page_clean = page.strip()
    if not page_clean:
        continue
    
    # Find series name for this page
    series = find_series_in_text(page_clean)
    if series:
        current_series = series
    
    # Clean Arabic text
    eng_text = clean_text(page_clean)
    
    # Parse products
    page_products = parse_product_data(eng_text)
    for p in page_products:
        p['series'] = current_series
        products.append(p)

# Remove duplicates by code
seen_codes = {}
unique_products = []
for p in products:
    code = p['code']
    if code and code not in seen_codes:
        seen_codes[code] = True
        unique_products.append(p)
    elif not code:
        unique_products.append(p)

print(f"Total parsed: {len(products)}, unique with codes: {len(unique_products)}")

# Group by series
from collections import Counter
series_counts = Counter(p['series'] for p in unique_products)
for s, c in series_counts.most_common():
    print(f"  {s}: {c}")

# Save to Excel
import pandas as pd
df = pd.DataFrame(unique_products)
df.to_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx', index=False)
print(f"\nSaved {len(unique_products)} products to ايديال.xlsx")
