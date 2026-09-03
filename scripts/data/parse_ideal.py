"""
Parse Ideal Standard PDF text into structured product data and generate import SQL.
"""
import re
import os

# Read the extracted text
with open(r'C:\eg-co-erp\LISTS\ideal_text.txt', 'r', encoding='utf-8') as f:
    raw = f.read()

# Split into pages
pages = raw.split('=== PAGE ')[1:]  # skip empty before first

# Pattern for product data lines:
# Starts with number or "-", then number or "-", then number or "-", then description, then code at end
# The code is like K3104, G3121, T0878, G0093AC, etc - capital letter followed by digits, optionally prefixed

# Collect all product lines across all pages
all_lines = []
current_subcategory = "أخرى"

for page_text in pages:
    lines = page_text.strip().split('\n')
    # First line has page number info
    header = lines[0] if lines else ""
    
    # Determine subcategory from common patterns
    for line in lines:
        # Check for product series/subcategory headers
        line_clean = line.strip()
        if line_clean.upper() in [
            'TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
            'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
            'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'OTHERS',
            'STUDIO ACCESSORIES', 'IOM ACCESSORIES', 'BUILT IN CISTERN ( PROSYS )',
            'URINALS', 'ACCESSORIES & INDIVIDUAL ITEMS',
            'CERAMIC PRODUCTS', 'FIXTURES COLOR AVAILABILITY',
        ]:
            # Skip these - they are section headers, not product series
            pass
        elif line_clean.upper() in ['PRICES', 'WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
            pass
        elif line_clean.upper().startswith('K') or line_clean.upper().startswith('G') or line_clean.upper().startswith('T') or line_clean.upper().startswith('R'):
            # Could be a product code line or a series header
            # Check if it's a series header like "K3104 - G3121"
            if ' - ' in line_clean or ' / ' in line_clean:
                # Might be code range
                pass
    
    # Process actual data lines
    data_lines = [l for l in lines if re.match(r'^[\d\s\-]+[A-Z]', l.strip())]
    for dl in data_lines:
        all_lines.append(dl.strip())

# Better approach: iterate through all lines and parse products
# A product line starts with: optional "-", number, space, optional "-", number, space, optional "-", number

products = []
current_series = ""

for page_text in pages:
    lines = page_text.strip().split('\n')
    
    for i, line in enumerate(lines):
        s = line.strip()
        if not s:
            continue
        
        # Detect series name (appears as a bold header before data)
        # Series names are uppercase single words like TONIC, MANTA, CONNECT, etc.
        if s.upper() in [
            'TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
            'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
            'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE',
            'STUDIO ACCESSORIES', 'IOM ACCESSORIES', 'BUILT IN CISTERN ( PROSYS )',
        ]:
            current_series = s.upper()
            if current_series == 'I.LIFE':
                current_series = 'i.Life'
            continue
        
        if s.upper() in ['OTHERS', 'URINALS', 'ACCESSORIES & INDIVIDUAL ITEMS']:
            current_series = s.upper()
            continue
        
        if s.startswith('PRICES') or s.upper() in ['WHITE', 'PERGAMON', 'W.T KG', 'CODE', 'DESCRIPTION']:
            continue
        
        if s.upper().startswith('PAGE') and s[0].isdigit():
            continue
        
        # Try to parse as product data line
        # Pattern: optional "-" NUMERIC WHITE_PRICE optional "-" NUMERIC PERGA_PRICE optional "-" NUMERIC WEIGHT DESCRIPTION... CODE
        m = re.match(r'^(-?\d[\d.]*)\s+(-?\d[\d.]*)\s+(-?[\d.]+)\s+(.+)$', s)
        if m:
            white_price = m.group(1)
            perga_price = m.group(2)
            weight = m.group(3)
            rest = m.group(4).strip()
            
            # Last word is usually the product code
            words = rest.split()
            if words and re.match(r'^[A-Z]\d+', words[-1]):
                code = words[-1]
                desc = ' '.join(words[:-1])
            else:
                code = ''
                desc = rest
            
            products.append({
                'series': current_series,
                'code': code,
                'description': desc,
                'white_price': white_price,
                'pergamon_price': perga_price,
                'weight': weight,
            })

print(f"Found {len(products)} products")

# Group by series
from collections import Counter
series_counts = Counter(p['series'] for p in products)
for s, c in series_counts.most_common():
    print(f"  {s}: {c}")

# Save to Excel
import pandas as pd
df = pd.DataFrame(products)
df.to_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx', index=False)
print(f"\nSaved {len(products)} products to ايديال.xlsx")
