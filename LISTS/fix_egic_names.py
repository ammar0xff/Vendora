import sys, psycopg2, uuid, re
from decimal import Decimal
sys.stdout.reconfigure(encoding='utf-8')

DB_PARAMS = {
    'host': 'localhost', 'port': 5432, 'dbname': 'inventory_db',
    'user': 'postgres', 'password': 'postgres',
}

conn = psycopg2.connect(**DB_PARAMS)
cur = conn.cursor()

# Step 1: Remove [code] from all names
print("Step 1: Removing [code] from names...")
cur.execute("""
    UPDATE products 
    SET name = regexp_replace(name, '\\[[0-9]+\\]$', '') 
    WHERE company = 'بي ار' AND name ~ '\\[[0-9]+\\]$'
""")
print(f"  Updated {cur.rowcount} products")
conn.commit()

# Step 2: Clean up trailing spaces after removing code
cur.execute("""
    UPDATE products 
    SET name = trim(name) 
    WHERE company = 'بي ار'
""")
conn.commit()
print("  Trimmed whitespace")

# Step 3: Read all products from the Excel file for classification reference
import openpyxl, os

d = r'C:\eg-co-erp\LISTS\done'
egic_path = None
for f in os.listdir(d):
    if f.endswith('.xlsx') and 'شريف' not in repr(f):
        egic_path = os.path.join(d, f)
        break

wb = openpyxl.load_workbook(egic_path, data_only=True)
ws = wb['Sheet1']

# Build reference: code -> (material, brand, price)
code_ref = {}
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material:
        continue
    code_ref[str(code).strip()] = {
        'material': str(material).strip(),
        'brand': str(brand).strip() if brand else '',
        'price': float(price) if price else None,
    }

print(f"  Loaded {len(code_ref)} reference entries from Excel")

# Step 4: Now fix subcategories and extract sizes
# First, get current state
cur.execute("""
    SELECT p.id, p.name, p.size, c.name AS cat_name, s.name AS subcat_name
    FROM products p 
    JOIN subcategories s ON p.subcategory_id = s.id 
    JOIN categories c ON s.category_id = c.id 
    WHERE p.company = 'بي ار'
    ORDER BY p.name
""")

products = cur.fetchall()
print(f"\nStep 3: Analyzing {len(products)} products...")

# Fix improper characters in names
cur.execute("""
    UPDATE products SET name = replace(name, 'ﻼ', 'لا') WHERE company = 'بي ار' AND name LIKE '%ﻼ%';
    UPDATE products SET name = replace(name, 'ﻻ', 'لا') WHERE company = 'بي ار' AND name LIKE '%ﻻ%';
""")
conn.commit()
print("  Fixed Arabic characters (ﻼ/ﻻ -> لا)")

# Classification rules (same as earlier)
CLASSIFICATION = {
    'مواسير': None,
    'كوع': None, 'تي': None, 'وصلة': None, 'مسلوب': None,
    'جلبة': None, 'طبة': None, 'صليبة': None,
    'مشترك': None,
    'محبس': None,
    'صفاية': 'صفاية',
    'علاية': 'علاية صفاية',
    'غطاء': 'غطاء مواسير',
    'بردة': 'بردة لحام',
    'بيبة': 'بيبة',
    'ياردة': 'ياردة',
    'غراء': 'غراء',
    'هواية': 'هواية',
    'قفيز': 'قفيز PPR',
    'واي': 'واي فلتر',
    'طلمبة': 'طلمبة مياه',
    'سيفون': 'سيفون',
    'مجمع': 'مجمع صرف',
    'غرفة': 'غرفة تفتيش',
    'جاليتراب': 'جاليتراب',
    'بطارية': 'بطارية متغيرة',
    'مانع': 'مانع ارتداد',
    'عازل': 'عازل',
    'خزان': 'خزان دفن',
    'برقع': 'برقع بيبة',
    'جرجوري': 'جرجوري مطر',
    'وش': 'وش استانلس',
    'حاجز': 'حاجز مائي',
    'بوش': 'وصلات صرف S',
    'رقبة': 'رقبة',
    'مخرج': 'مخرج خلاط',
}

# Get category ID for ايجيك
cur.execute("SELECT id FROM categories WHERE name = 'ايجيك'")
cat_id = cur.fetchone()[0]

def classify_product(name):
    """Return (subcategory_name, updated_name, size_val)"""
    words = name.split()
    first = words[0] if words else ''

    if first == 'مواسير':
        subcat = 'مواسير فايبر' if 'فايبر' in name else 'مواسير PPR'

    elif first in ('كوع', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة', 'صليبة'):
        if 'UV' in name or 'صرف' in name:
            subcat = f'{first} صرف'
        elif 'فايبر' in name:
            subcat = f'{first} فايبر'
        elif 'بسن' in name or 'خارجي' in name:
            subcat = f'{first} بسن'
        elif first == 'مسلوب':
            subcat = 'مسلوب لحام'
        elif first == 'جلبة':
            subcat = 'جلبة لحام'
        elif first == 'طبة':
            subcat = 'طبة لحام'
        elif first == 'صليبة':
            subcat = 'صليبة لحام'
        else:
            subcat = f'{first} لحام'

    elif first == 'مشترك':
        if 'باب' in name:
            subcat = 'مشترك بباب كشف'
        elif '45' in name or '87' in name or 'مائل' in name or 'درجة' in name:
            subcat = 'مشترك مائل'
        elif 'صليبة' in name:
            subcat = 'مشترك صليبة'
        else:
            subcat = 'مشترك'

    elif first == 'محبس':
        if 'دفن' in name:
            subcat = 'محبس دفن'
        elif 'طارة' in name:
            subcat = 'محبس طارة'
        elif 'بلية' in name or 'بلي' in name:
            subcat = 'محبس بلية'
        else:
            subcat = 'محبس'

    elif first == 'مم':
        if len(words) >= 2:
            second = words[1]
            if second in ('فلنشة', 'فﻼنشة'):
                subcat = 'فلنشة لحام'
            elif 'مانع' in name:
                subcat = 'مانع ارتداد'
            else:
                subcat = 'أخرى'
        else:
            subcat = 'أخرى'

    elif first.startswith('S-') or first.startswith('Sمم') or first.startswith('S-مم') or first.startswith('S-°'):
        subcat = 'وصلات صرف S'
    elif first.startswith('ML') or first.startswith('UVمم'):
        subcat = 'وصلات صرف'
    elif first.startswith('P.P') or first.startswith('PP-مم') or first.startswith('PPمم') or first.startswith('مدفونP.P'):
        subcat = 'وصلات صرف PP'
    elif first.startswith('مدفون'):
        subcat = 'وصلات صرف PP'
    elif first == 'بوصة' or (first[0].isdigit() and '/' in first):
        if 'مانع' in name:
            subcat = 'مانع ارتداد'
        elif 'علاية' in name:
            subcat = 'علاية صفاية'
        elif 'صفاية' in name:
            subcat = 'صفاية'
        else:
            subcat = 'أخرى'
    elif first == 'S':
        if 'غطاء' in name or 'غرفة' in name or 'قاعدة' in name:
            subcat = 'غرفة تفتيش'
        elif 'مخرج' in name or 'خلاط' in name:
            subcat = 'مخرج خلاط دفن'
        elif 'مجرى' in name:
            subcat = 'مجرى مائي'
        elif 'مانع' in name:
            subcat = 'مانع ارتداد'
        else:
            subcat = 'أخرى'
    elif first.startswith('Sمخرج') or first.startswith('Sدرجة') or first.startswith('Sبداية') or first.startswith('Sمشترك') or first.startswith('S.'):
        subcat = 'وصلات صرف S'
    elif first == 'درجة':
        subcat = 'مشترك صرف'
    elif first == 'P.Pمم':
        subcat = 'وصلات صرف PP'
    elif first == 'TILEABLEمم' or first == 'TILEABLE':
        subcat = 'علاية صفاية'
    elif first == 'جسم' or first == 'قاعدة':
        subcat = 'غرفة تفتيش' if 'غرفة' in name else 'أخرى'
    elif first == 'Sسم':
        subcat = 'غرفة تفتيش' if 'غطاء' in name else 'وصلات صرف S'
    else:
        subcat = CLASSIFICATION.get(first, 'أخرى')
        if subcat is None:
            subcat = 'أخرى'

    # --- Extract size from name ---
    size_val = None
    
    # Strategy: look for patterns like "مم" or digits at end or middle
    for w in reversed(words):
        w_clean = w.replace('×', 'x').replace('*', 'x').replace('X', 'x')
        if re.match(r'^[\d]+x[\d]+', w_clean) or re.match(r'^[\d]+x[\d]+', w):
            size_val = w
            break
        if re.match(r'^[\d]+مم', w) or re.match(r'^[\d]+$', w):
            size_val = w
            break
        if 'مم' in w and re.match(r'^[\d]', w):
            size_val = w
            break

    return subcat, size_val

# Process all products
subcat_cache = {}
update_count = 0

for pid, name, current_size, cat_name, subcat_name in products:
    if not name or not name.strip():
        continue
    
    subcat, size_val = classify_product(name)
    if 'أخرى' in subcat:
        continue
    
    # Get or create subcategory
    if subcat not in subcat_cache:
        cur.execute("SELECT id FROM subcategories WHERE category_id = %s AND name = %s", (cat_id, subcat))
        row = cur.fetchone()
        if row:
            subcat_cache[subcat] = row[0]
        else:
            sid = uuid.uuid4()
            cur.execute("INSERT INTO subcategories (id, category_id, name) VALUES (%s, %s, %s)", (sid, cat_id, subcat))
            subcat_cache[subcat] = sid
            print(f"  Created subcategory: {subcat}")
    
    new_subcat_id = subcat_cache[subcat]
    
    # Update product
    if size_val:
        cur.execute("UPDATE products SET subcategory_id = %s, size = %s WHERE id = %s",
                    (new_subcat_id, size_val, pid))
    else:
        cur.execute("UPDATE products SET subcategory_id = %s WHERE id = %s",
                    (new_subcat_id, pid))
    update_count += 1
    
    if update_count % 50 == 0:
        print(f"  Processed {update_count} products...")
        conn.commit()

conn.commit()
print(f"\nUpdated {update_count} products")

# Final check
cur.execute("""
    SELECT s.name, count(p.id) FROM products p 
    JOIN subcategories s ON p.subcategory_id = s.id 
    WHERE p.company = 'بي ار' 
    GROUP BY s.name ORDER BY s.name
""")
print("\nFinal subcategory breakdown:")
for sname, cnt in cur.fetchall():
    print(f"  {sname}: {cnt}")

cur.close()
conn.close()
print("\nDone!")
