import csv, uuid, re, sys
sys.stdout.reconfigure(encoding='utf-8')

products = []
with open(r'C:\eg-co-erp\egic_clean.csv', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        products.append({
            'id': row['id'],
            'name': row['name'].strip() if row['name'] else '',
            'size': row['size'].strip() if row['size'] else '',
            'subcategory_id': row['subcategory_id'].strip() if row['subcategory_id'] else '',
        })

print(f"Loaded {len(products)} products")

def classify_and_clean(name):
    """Return (subcategory_name, cleaned_name, size_val)"""
    words = name.split()
    first = words[0] if words else ''
    
    # Fix Arabic letters (whole words first, then individual chars)
    cleaned = name.replace('فﻼنشة', 'فلنشة').replace('فﻼنشة', 'فلنشة')
    cleaned = cleaned.replace('عﻼية', 'علاية').replace('باﻻكرة', 'باكرة')
    cleaned = cleaned.replace('ﻼ', 'لا').replace('ﻻ', 'لا')
    words = cleaned.split()
    first = words[0] if words else ''
    
    # Subcategory classification
    if first == 'مواسير':
        if 'فايبر' in cleaned:
            subcat = 'مواسير فايبر'
        else:
            subcat = 'مواسير PPR'

    elif first in ('كوع', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة', 'صليبة'):
        if 'UV' in cleaned or 'صرف' in cleaned:
            subcat = f'{first} صرف'
        elif 'فايبر' in cleaned:
            subcat = f'{first} فايبر'
        elif 'بسن' in cleaned or 'خارجي' in cleaned:
            subcat = f'{first} بسن'
        elif first == 'صليبة':
            subcat = 'صليبة لحام'
        else:
            subcat = f'{first} لحام'

    elif first == 'مشترك':
        if 'باب' in cleaned: subcat = 'مشترك بباب كشف'
        elif '45' in cleaned or '87' in cleaned or 'مائل' in cleaned or 'درجة' in cleaned: subcat = 'مشترك مائل'
        elif 'صليبة' in cleaned: subcat = 'مشترك صليبة'
        else: subcat = 'مشترك'

    elif first == 'محبس':
        if 'دفن' in cleaned: subcat = 'محبس دفن'
        elif 'طارة' in cleaned: subcat = 'محبس طارة'
        elif 'بلية' in cleaned or 'بلي' in cleaned: subcat = 'محبس بلية'
        elif 'إيليت' in cleaned.lower(): subcat = 'محبس إيليت'
        else: subcat = 'محبس'

    elif first == 'مم':
        if len(words) >= 3 and words[2] in ('فلنشة',):
            subcat = 'فلنشة لحام'
        elif 'مانع' in cleaned: subcat = 'مانع ارتداد'
        else: subcat = 'أخرى'

    elif first.startswith('S-') or first.startswith('Sمم') or first.startswith('S-مم') or first.startswith('S-°') or first.startswith('S.'):
        subcat = 'وصلات صرف S'
    elif first.startswith('ML') or first.startswith('UVمم'):
        subcat = 'وصلات صرف'
    elif first.startswith('P.P') or first.startswith('PP-مم') or first.startswith('PPمم') or first.startswith('مدفونP.P') or first.startswith('مدفون'):
        subcat = 'وصلات صرف PP'
    elif first == 'بوصة' or (first[0].isdigit() and '/' in first):
        if 'مانع' in cleaned: subcat = 'مانع ارتداد'
        elif 'علاية' in cleaned: subcat = 'علاية صفاية'
        elif 'صفاية' in cleaned: subcat = 'صفاية'
        else: subcat = 'أخرى'
    elif first == 'S':
        if 'غطاء' in cleaned or 'غرفة' in cleaned or 'قاعدة' in cleaned: subcat = 'غرفة تفتيش'
        elif 'مخرج' in cleaned or 'خلاط' in cleaned: subcat = 'مخرج خلاط دفن'
        elif 'مجرى' in cleaned: subcat = 'مجرى مائي'
        elif 'مانع' in cleaned: subcat = 'مانع ارتداد'
        else: subcat = 'أخرى'
    elif first.startswith('Sمخرج') or first.startswith('Sدرجة') or first.startswith('Sبداية') or first.startswith('Sمشترك'):
        subcat = 'مجرى مائي'
    elif first == 'درجة': subcat = 'مشترك صرف'
    elif first == 'P.Pمم': subcat = 'وصلات صرف PP'
    elif first == 'TILEABLEمم' or first == 'TILEABLE': subcat = 'علاية صفاية'
    elif first == 'جسم' or first == 'قاعدة': subcat = 'غرفة تفتيش' if 'غرفة' in cleaned else 'أخرى'
    elif first == 'Sسم': subcat = 'غرفة تفتيش' if 'غطاء' in cleaned else 'وصلات صرف S'

    # Direct classifications
    elif first in ('صفاية',): subcat = 'صفاية'
    elif first in ('علاية',): subcat = 'علاية صفاية'
    elif first in ('غطاء',): subcat = 'غطاء مواسير'
    elif first in ('بردة',): subcat = 'بردة لحام'
    elif first in ('بيبة',): subcat = 'بيبة'
    elif first in ('ياردة',): subcat = 'ياردة'
    elif first in ('غراء',): subcat = 'غراء'
    elif first in ('هواية',): subcat = 'هواية'
    elif first in ('قفيز',): subcat = 'قفيز PPR'
    elif first in ('واي',): subcat = 'واي فلتر'
    elif first in ('طلمبة',): subcat = 'طلمبة مياه'
    elif first in ('سيفون',): subcat = 'سيفون'
    elif first in ('مجمع',): subcat = 'مجمع صرف'
    elif first in ('غرفة',): subcat = 'غرفة تفتيش'
    elif first in ('جاليتراب',): subcat = 'جاليتراب'
    elif first in ('بطارية',): subcat = 'بطارية متغيرة'
    elif first in ('مانع',): subcat = 'مانع ارتداد'
    elif first in ('عازل',): subcat = 'عازل'
    elif first in ('خزان',): subcat = 'خزان دفن'
    elif first in ('برقع',): subcat = 'برقع بيبة'
    elif first in ('جرجوري',): subcat = 'جرجوري مطر'
    elif first in ('وش',): subcat = 'وش استانلس'
    elif first in ('حاجز',): subcat = 'حاجز مائي'
    elif first in ('بوش',): subcat = 'وصلات صرف S'
    elif first in ('رقبة',): subcat = 'رقبة'
    elif first in ('مخرج',): subcat = 'مخرج خلاط'
    else: subcat = 'أخرى'

    # Fix name for مم-based products (e.g., "مم 63 فلنشة لحام" -> "فلنشة لحام 63")
    if first == 'مم' and len(words) >= 3 and words[2] in ('فلنشة',):
        cleaned = f"{words[2]} {words[3]} {words[1]}" if len(words) >= 4 else ' '.join(words[1:])
    
    # --- Extract size ---
    size_val = None
    for w in reversed(words):
        w_clean = w.replace('×', 'x').replace('*', 'x').replace('X', 'x').replace('/', '_')
        if re.match(r'^[\d]+x[\d]+', w_clean):
            size_val = w
            break
        if 'مم' in w or 'سم' in w:
            if re.match(r'^[\d]', w):
                size_val = w
                break
            if re.match(r'^[\d]', w_clean):
                size_val = w
                break
        if re.match(r'^[\d]+$', w) and len(w) <= 5 and ('مم' in cleaned or 'سم' in cleaned):
            size_val = w
            break

    return subcat, cleaned, size_val

# Process each product
updates = []
unknown_subcats = set()

for p in products:
    name = p['name']
    if not name:
        continue
    
    subcat, cleaned_name, size_val = classify_and_clean(name)
    
    if subcat == 'أخرى':
        unknown_subcats.add(name)
        continue
    
    name_esc = cleaned_name.replace("'", "''")
    subcat_esc = subcat.replace("'", "''")
    size_esc = size_val.replace("'", "''") if size_val else None
    
    if size_val:
        updates.append(f"UPDATE products SET name = '{name_esc}', size = '{size_esc}', subcategory_id = (SELECT id FROM subcategories WHERE name = '{subcat_esc}' AND category_id = (SELECT id FROM categories WHERE name = 'ايجيك')) WHERE id = '{p['id']}';")
    else:
        updates.append(f"UPDATE products SET name = '{name_esc}', subcategory_id = (SELECT id FROM subcategories WHERE name = '{subcat_esc}' AND category_id = (SELECT id FROM categories WHERE name = 'ايجيك')) WHERE id = '{p['id']}';")

# Generate subcategory INSERT statements
all_subcats = set()
for u in updates:
    import re as re2
    m = re2.search(r"name = '([^']+)'", u.split("subcategory_id")[1])
    if m:
        all_subcats.add(m.group(1))

header_lines = [
    "-- EGIC product reorganization",
    "-- First ensure all subcategories exist",
]

for sc in sorted(all_subcats):
    sc_esc = sc.replace("'", "''")
    header_lines.append(f"INSERT INTO subcategories (id, category_id, name) SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايجيك'), '{sc_esc}' WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'ايجيك') AND name = '{sc_esc}');")

lines = header_lines + [""] + updates

with open(r'C:\eg-co-erp\fix_egic_step2.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print(f"Generated {len(updates)} UPDATE statements across {len(all_subcats)} subcategories")
print(f"Unknown (أخرى): {len(unknown_subcats)} products")

if unknown_subcats:
    print("\n=== Unknown products (need manual classification) ===")
    for n in sorted(unknown_subcats)[:20]:
        print(f"  {n}")
