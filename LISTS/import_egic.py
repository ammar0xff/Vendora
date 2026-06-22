import sys, openpyxl, uuid, psycopg2, os, re
from decimal import Decimal
sys.stdout.reconfigure(encoding='utf-8')

DB_PARAMS = {
    'host': 'localhost', 'port': 5432, 'dbname': 'inventory_db',
    'user': 'postgres', 'password': 'postgres',
}

conn = psycopg2.connect(**DB_PARAMS)
cur = conn.cursor()

def esc(val):
    if val is None:
        return 'NULL'
    return "'" + str(val).replace("'", "''") + "'"

def insert_category(name):
    cur.execute("SELECT id FROM categories WHERE name = %s", (name,))
    row = cur.fetchone()
    if row:
        return row[0]
    cid = uuid.uuid4()
    cur.execute("INSERT INTO categories (id, name) VALUES (%s, %s)", (cid, name))
    return cid

def insert_or_get_subcategory(category_id, name):
    cur.execute("SELECT id FROM subcategories WHERE category_id = %s AND name = %s", (category_id, name))
    row = cur.fetchone()
    if row:
        return row[0]
    sid = uuid.uuid4()
    cur.execute("INSERT INTO subcategories (id, category_id, name) VALUES (%s, %s, %s)", (sid, category_id, name))
    return sid

def product_exists(name, company, size_val):
    cur.execute("SELECT id FROM products WHERE name = %s AND company = %s AND size = %s",
                (name, company, size_val if size_val else None))
    return cur.fetchone()

def insert_product(subcategory_id, name, size_val, price, company, material=None):
    full_name = name.strip()
    existing = product_exists(full_name, company, size_val)
    if existing:
        return existing[0]
    pid = uuid.uuid4()
    cur.execute("""
        INSERT INTO products (id, subcategory_id, name, unit, retail_price, company, size, material, stock_status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (pid, subcategory_id, full_name, 'عدد',
          Decimal(str(price)) if price else Decimal('0'),
          company, size_val if size_val else None, material, 'untracked'))
    return pid

# Find EGIC file
d = r'C:\eg-co-erp\LISTS\done'
egic_path = None
for f in os.listdir(d):
    if f.endswith('.xlsx') and 'شريف' not in repr(f):
        egic_path = os.path.join(d, f)
        break

if not egic_path:
    print("EGIC file not found!")
    sys.exit(1)

print(f"Reading {egic_path}")
wb = openpyxl.load_workbook(egic_path, data_only=True)
ws = wb['Sheet1']

company = 'ايجيك'
cat_id = insert_category(company)
print(f"Category '{company}' ID: {cat_id}")

subcat_cache = {}
total = 0
skipped_no_price = 0
skipped_duplicate = 0

# Classification rules: first word -> subcategory name
CLASSIFICATION = {
    'مواسير': None,  # handled specially
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
}

def classify_and_clean(material_str, brand_str, code):
    """Return (subcategory_name, product_name, size_val)"""
    words = material_str.split()
    first = words[0] if words else ''

    # Default values
    subcat = None
    name_parts = words[:]
    size_val = None

    if first == 'مواسير':
        if 'فايبر' in material_str:
            subcat = 'مواسير فايبر'
        elif 'PPR' in material_str or 'لحام' in material_str:
            subcat = 'مواسير PPR'
        else:
            subcat = 'مواسير'
    
    elif first in ('كوع', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة', 'صليبة'):
        if 'UV' in material_str:
            subcat = f'{first} صرف'
        elif 'فايبر' in material_str:
            subcat = f'{first} فايبر'
        elif 'بسن' in material_str or 'خارجي' in material_str:
            subcat = f'{first} بسن'
        elif 'PPR' in material_str or 'لحام' in material_str or 'PN' in material_str:
            subcat = f'{first} لحام'
        elif first == 'وصلة':
            subcat = 'وصلة لحام'
        elif first == 'مسلوب':
            subcat = 'مسلوب لحام'
        elif first == 'جلبة':
            subcat = 'جلبة لحام'
        elif first == 'طبة':
            subcat = 'طبة لحام'
        else:
            subcat = f'{first} لحام'
    
    elif first == 'مشترك':
        if 'باب' in material_str:
            subcat = 'مشترك بباب كشف'
        elif '45' in material_str or '87' in material_str or 'مائل' in material_str or 'درجة' in material_str:
            subcat = 'مشترك مائل'
        elif 'صليبة' in material_str:
            subcat = 'مشترك صليبة'
        else:
            subcat = 'مشترك'
    
    elif first == 'محبس':
        if 'دفن' in material_str:
            subcat = 'محبس دفن'
        elif 'طارة' in material_str:
            subcat = 'محبس طارة'
        elif 'بلية' in material_str or 'بلي' in material_str:
            subcat = 'محبس بلية'
        elif 'إيليت' in material_str.lower():
            subcat = 'محبس إيليت'
        else:
            subcat = 'محبس'
    
    elif first.startswith('S-') or first.startswith('Sمم') or first.startswith('S-مم') or first.startswith('S-°'):
        subcat = 'وصلات صرف S'
    elif first.startswith('ML') or first.startswith('UVمم'):
        subcat = 'وصلات صرف'
    elif first.startswith('P.P') or first == 'PP-مم' or first.startswith('PPمم') or first.startswith('مدفونP.P'):
        subcat = 'وصلات صرف PP'
    elif first == 'مم':
        # Starts with size, check second word
        if len(words) >= 2:
            second = words[1]
            if second == 'فﻼنشة' or second == 'فلنشة':
                subcat = 'فلنشة لحام'
                name_parts = words[1:]  # Remove the first مم
            elif 'مانع' in material_str:
                subcat = 'مانع ارتداد'
            else:
                subcat = 'أخرى'
        else:
            subcat = 'أخرى'
    elif first == 'بوصة' or (first[0].isdigit() and '/' in first):
        if 'مانع' in material_str:
            subcat = 'مانع ارتداد'
        elif 'علاية' in material_str or 'عﻼية' in material_str:
            if 'مربعة' in material_str:
                subcat = 'علاية صفاية'
            else:
                subcat = 'أخرى'
        elif 'صفاية' in material_str:
            subcat = 'صفاية'
        else:
            subcat = 'أخرى'
    elif first == 'عازل':
        subcat = 'عازل'
    elif first == 'خزان':
        subcat = 'خزان دفن'
    elif first.startswith('CLEARFOR') or first.startswith('CLEARFOR'):
        subcat = 'غراء'
        name_parts = ['غراء', 'بارد'] + words[1:]
    elif first == 'مدفون' or first.startswith('مدفون'):
        subcat = 'وصلات صرف PP'
        if 'كوع' in material_str:
            name_parts = ['كوع', 'مدفون'] + words[1:]
        elif 'جلبة' in material_str:
            name_parts = ['جلبة', 'مدفون'] + words[1:]
    elif first.startswith('P.Pمم'):
        subcat = 'وصلات صرف PP'
        rest = material_str[5:].strip()
        name_parts = rest.split()
    elif first.startswith('TILEABLE'):
        subcat = 'علاية صفاية'
        rest = material_str[8:].strip()
        name_parts = ['علاية', 'TILEABLE'] + rest.split()
    elif first == 'برقع':
        subcat = 'برقع بيبة'
    elif first == 'باﻻكرة' or first == 'باكرة':
        subcat = 'حنفية غسالة'
    elif first.startswith('Sمخرج') or first.startswith('Sدرجة') or first.startswith('Sبداية') or first.startswith('Sمشترك'):
        subcat = 'مجرى مائي'
        name_parts = words  # Keep original
    elif first.startswith('S.'):
        subcat = 'وصلات صرف S'
        name_parts = words
    elif first == 'بوش':
        subcat = 'وصلات صرف S'
        name_parts = ['بوش'] + words[1:]
    elif first == 'جرجوري':
        subcat = 'جرجوري مطر'
    elif first == 'وش':
        subcat = 'وش استانلس'
    elif first == 'حاجز':
        subcat = 'حاجز مائي'
    elif first == 'جسم' or first == 'قاعدة':
        if 'غرفة' in material_str:
            subcat = 'غرفة تفتيش'
        else:
            subcat = 'أخرى'
        name_parts = words
    elif first == 'Sسم' or first == 'S':
        if 'غطاء' in material_str:
            subcat = 'غرفة تفتيش'
        elif 'مخرج' in material_str or 'خلاط' in material_str:
            subcat = 'مخرج خلاط دفن'
        elif 'مجرى' in material_str:
            subcat = 'مجرى مائي'
        elif 'مانع' in material_str:
            subcat = 'مانع ارتداد'
        else:
            subcat = 'أخرى'
        name_parts = words
    elif first == 'مانع':
        subcat = 'مانع ارتداد'
    elif first == 'رقبة':
        subcat = 'رقبة'
    elif first == 'مخرج':
        subcat = 'مخرج خلاط دفن'
    elif first == 'درجة':
        subcat = 'مشترك صرف'
        name_parts = words
    elif first == 'TILEABLEمم' or first == 'TILEABLE':
        subcat = 'علاية صفاية'
        rest = material_str[8:].strip() if first.startswith('TILEABLE') else material_str
        if rest.startswith('مم') or rest.startswith('مم'):
            rest = rest[2:].strip()
        name_parts = ['علاية'] + rest.split()
    
    if subcat is None:
        subcat = 'أخرى'

    # --- Clean product name ---
    cleaned_name = ' '.join(name_parts)
    
    # Fix common issues
    cleaned_name = cleaned_name.replace('فﻼنشة', 'فلنشة').replace('عﻼية', 'علاية')
    cleaned_name = cleaned_name.replace('باﻻكرة', 'باكرة')
    
    # --- Extract size ---
    size_val = None
    
    # First try: last word that looks like a size (digits, optional unit)
    for w in reversed(words):
        if re.match(r'^[\d]+[×*xX][\d]+', w):
            size_val = w
            break
        if re.match(r'^[\d]+', w) and ('مم' in material_str or 'سم' in material_str):
            size_val = w
            break
        if re.match(r'^[\d]+', w) and any(c in w for c in ('مم', 'سم', '"', "'", 'بوصة')):
            size_val = w
            break
    
    # Second try: find words with مم or " pattern
    if not size_val:
        for w in words:
            if re.match(r'^[\d]+[×*xX][\d]+.*مم', w) or 'مم' in w:
                size_val = w
                break
    
    # Third try: last word with digits
    if not size_val:
        for w in reversed(words):
            if re.match(r'^[\d]+', w):
                size_val = w
                break

    return subcat, cleaned_name, size_val

# Process all products
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material:
        continue
    
    material_str = str(material).strip()
    brand_str = str(brand).strip() if brand else 'بر'
    price_val = float(price) if price else None
    
    if price_val is None:
        skipped_no_price += 1
        continue
    
    subcat_name, cleaned_name, size_val = classify_and_clean(material_str, brand_str, str(code).strip())
    
    subcat_id = insert_or_get_subcategory(cat_id, subcat_name)
    
    pid = insert_product(subcat_id, cleaned_name, size_val, price_val, company, material=brand_str)
    if pid:
        total += 1
    else:
        skipped_duplicate += 1

conn.commit()
cur.close()
conn.close()

print(f"\n=== Import complete ===")
print(f"Total imported: {total}")
print(f"Skipped (no price): {skipped_no_price}")
print(f"Skipped (duplicate): {skipped_duplicate}")

# Show subcategory breakdown
cur2 = conn.cursor()
cur2.execute("""
    SELECT s.name, COUNT(p.id) FROM products p 
    JOIN subcategories s ON p.subcategory_id = s.id 
    WHERE p.company = 'ايجيك' 
    GROUP BY s.name ORDER BY s.name
""")
# This won't work since conn is closed... let me skip this
