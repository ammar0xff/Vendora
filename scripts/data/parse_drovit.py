"""
Parse Duravit/Drovit PDF text - extract products with model numbers and prices.
"""
import re
import pandas as pd

with open(r'C:\eg-co-erp\LISTS\drovit_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

pages = text.split('=== PAGE ')

# Duravit model number pattern: 6 digits, space, 2 digits, space, 2 digits
# e.g., "044546 00 00", "872710 00 05"
MODEL_PATTERN = re.compile(r'(\d{6}\s+\d{2}\s+\d{2})')
# Also shorter codes like "S19520", "XL6062"
SHORT_CODE = re.compile(r'([A-Z]{1,3}\d{3,})')

# Price pattern: numbers with commas (Egyptian format)
PRICE_PATTERN = re.compile(r'([\d,]+)\s*جنيه|([\d,]+)\s*LE|(\d[\d,]*\d)')

products = []
current_category = 'Unknown'

CATEGORY_NAMES = [
    'STARCK 1', 'STARCK 3', 'HAPPY D.', 'DURASTYLE', 'DARLING',
    'VERO', 'P3 COMFORTS', 'D-NEO', 'L-CUBE', 'KETHO', 'CARO',
    'X-LARGE', 'D-CODE', 'PURAVIDA', 'DURAVIT NO. 1', 'VITRIUM',
    'GOLF', 'EMILIA', 'ECHO', 'DURAPLUS', 'LOCAL CERAMICS',
    'SEPARATES', 'ACCESSORIES', 'CHROME ACCESSORIES',
    'EASY ACCESSORIES', 'CERAMIC ACCESSORIES',
    'BUILT IN CISTERN', 'PROSYS',
]

def is_price(s):
    try:
        return float(s.replace(',', '')) > 0
    except:
        return False

for page_text in pages:
    if not page_text.strip():
        continue
    
    lines = page_text.strip().split('\n')
    
    # Detect category from page
    for line in lines:
        ul = line.strip().upper()
        for cn in CATEGORY_NAMES:
            if cn.upper() in ul:
                current_category = cn
                break
    
    # Process each line for model numbers and prices
    buffer_desc = ''
    buffer_model = ''
    
    for line in lines:
        s = line.strip()
        if not s:
            continue
        
        # Skip header lines
        if any(h in s.upper() for h in ['PL_50_DEGY', 'PL_50_EGY', 'DESCRIPTIONالصنف', 
                                          'ملليميتر', 'MODEL-NO.', 'الموديل رقم',
                                          'LE', 'مصري جنيه', 'WHITE', 'INFOBOX']):
            continue
        # Skip pure page numbers
        if re.match(r'^\d+$', s):
            continue
        # Skip pure Arabic
        if not re.search(r'[A-Za-z0-9]', s):
            continue
        
        # Look for model numbers
        models = MODEL_PATTERN.findall(s)
        if models:
            model = models[0].replace(' ', '')
            # Find price - try to get a number near the model
            # Prices are typically after the model number
            after_model = s[s.find(models[0]) + len(models[0]):].strip()
            
            # Try to parse price from after_model
            price_match = re.search(r'([\d,]+)\s*$', after_model)
            if price_match:
                try:
                    price = float(price_match.group(1).replace(',', ''))
                except:
                    price = 0
            else:
                # Try to find any price-like number
                nums = re.findall(r'([\d,]+)', after_model)
                prices = [float(n.replace(',', '')) for n in nums if is_price(n)]
                price = prices[0] if prices else 0
            
            products.append({
                'category': current_category,
                'model': model,
                'description': s[:s.find(models[0])].strip()[:100],
                'price': price,
            })
        
        # Also look for short codes
        codes = SHORT_CODE.findall(s)
        for code in codes:
            if code in ['PL', 'XL', 'mm']:
                continue
            # Check if this code has a price on the same line
            nums = re.findall(r'([\d,]+)', s)
            prices = [float(n.replace(',', '')) for n in nums if is_price(n)]
            if prices:
                products.append({
                    'category': current_category,
                    'model': code,
                    'description': s[:100],
                    'price': prices[0],
                })

print(f"Total products found: {len(products)}")

# Deduplicate by model
seen = {}
unique = []
for p in products:
    if p['model'] not in seen:
        seen[p['model']] = True
        unique.append(p)

print(f"Unique: {len(unique)}")

from collections import Counter
cats = Counter(p['category'] for p in unique)
for c, n in cats.most_common():
    print(f"  {c}: {n}")

df = pd.DataFrame(unique)
# Remove entries with 0 price or very low price
df = df[df['price'] > 100].copy()
print(f"After filtering (price > 100): {len(df)}")

df.to_excel(r'C:\eg-co-erp\LISTS\دروفيت.xlsx', index=False)
print(f"Saved to دروفيت.xlsx")
print(df.head(10).to_string())
