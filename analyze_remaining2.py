import csv, openpyxl, re, sys
sys.stdout.reconfigure(encoding='utf-8')

remaining = []
with open(r'C:\eg-co-erp\remaining_comer.csv', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        remaining.append(row)

print(f"{len(remaining)} remaining")

wb = openpyxl.load_workbook(r'C:\eg-co-erp\LISTS\Neisco_Comer_Price_List_2026.xlsx', data_only=True)

# Broader FITTING_NAMES: match by prefix (sorted long→short)
FITTING_PREFIXES = [
    # Ball Valves (محبس كرة)
    ('BVSL', 'محبس كرة'), ('BVDL', 'محبس كرة'), ('BVS', 'محبس كرة'), ('BVDL', 'محبس كرة'), ('BVDLC', 'محبس كرة'),
    ('BVSL10', 'محبس كرة'), ('BVSL11', 'محبس كرة سن'), ('BVSL12', 'محبس كرة'), ('BVSL13', 'محبس كرة'), ('BVSL15', 'محبس كرة'), ('BVSL19', 'محبس كرة'),
    ('BVDL10', 'محبس كرة'), ('BVDL11', 'محبس كرة سن'), ('BVDL12', 'محبس كرة'), ('BVDL13', 'محبس كرة'), ('BVDL15', 'محبس كرة'), ('BVDL19', 'محبس كرة'),
    ('BVDLC19', 'محبس كرة'), ('BVS17', 'محبس كرة'),
    ('FV10', 'محبس رفرف'),
    
    # Check Valves (صمام عدم رجوع)
    ('CVDC', 'صمام عدم رجوع'), ('CVD', 'صمام عدم رجوع'),
    ('CVD10', 'صمام عدم رجوع'), ('CVD11', 'صمام عدم رجوع سن'), ('CVD13', 'صمام عدم رجوع سن'), ('CVDC10', 'صمام عدم رجوع'), ('CVDC13', 'صمام عدم رجوع'),
    
    # Butterfly Valves
    ('BUT10', 'صمام فراشة'),
    
    # Stubs Metric Tee
    ('TY40', 'تي'), ('TY4', 'تي'),

    # Reducer Socket
    ('RS10', 'نقاص'),

    # Union adapter variant
    ('US82', 'يونيون محول'),
    
    # Elbows كوع
    ('EL50', 'كوع 90'), ('EL51', 'كوع 90 سن'), ('EL52', 'كوع 90 محول'), ('EL53', 'كوع 90 انجليزي'), ('EL54', 'كوع 45 محول'),
    ('EY50', 'كوع 45'), ('EY51', 'كوع 45 سن'), ('EY52', 'كوع 45 محول'), ('EY53', 'كوع 45 انجليزي'), ('EY54', 'كوع 45 محول انجليزي'),
    ('EL5', 'كوع 90'), ('EY5', 'كوع 45'),
    
    # Sockets صولة
    ('SO14', 'صولة محول سن'), ('SO15', 'صولة انجليزي'),
    ('SO10', 'صولة'), ('SO11', 'صولة سن'), ('SO12', 'صولة محول'), ('SO13', 'صولة انجليزي'),
    
    # Tees تي
    ('TE40', 'تي 90'), ('TE41', 'تي 90 سن'), ('TE42', 'تي محول'), ('TE43', 'تي 90 انجليزي'), ('TE44', 'تي محول سن'),
    ('TE4', 'تي 90'),
    
    # Reduced Tees تي نقص
    ('TR40', 'تي نقص'), ('TR41', 'تي نقص سن'), ('TR42', 'تي نقص محول'), ('TR43', 'تي نقص انجليزي'), ('TR44', 'تي نقص محول'), ('TR45', 'تي نقص انجليزي'),
    ('TR4', 'تي نقص'),
    
    # Stubs مسلوب
    ('ST20', 'مسلوب'), ('ST23', 'مسلوب'),
    ('ST2', 'مسلوب'),
    
    # Flanges فلنشة
    ('BR00', 'فلنشة'),
    
    # Unions يونيون
    ('UN80', 'يونيون'), ('UN81', 'يونيون سن'), ('UN82', 'يونيون محول'), ('UN83', 'يونيون انجليزي'), ('UN90', 'يونيون محول'),
    ('UN8', 'يونيون'),
    
    # Caps طبة/غطاء
    ('CA70', 'غطاء'), ('CA71', 'طبة سن'), ('CA73', 'طبة انجليزي'),
    
    # Plugs وصلات
    ('PL71', 'وصلة سن'), ('PL7', 'وصلة'),
    
    # Nipples نبل
    ('NI61', 'نبل سن'),
    
    # Reducers نقاص
    ('RP20', 'نقاص'),
    
    # Reducing Bushing جلبة نقص
    ('RB90', 'جلبة نقص'), ('RB92', 'جلبة نقص محول'), ('RB93', 'جلبة نقص محول انجليزي'), ('RB94', 'جلبة نقص محول سن'),
    ('RB9', 'جلبة نقص'),
    
    # Adaptors محول
    ('AD12', 'محول'), ('AD14', 'محول سن'),
    ('AD1', 'محول'),
    
    # Reducing سن ناقص
    ('RE61', 'ناقص سن'), ('RE21', 'ناقص سن'),
    ('RE6', 'ناقص سن'), ('RE2', 'ناقص سن'),
    
    # Saddles سرج
    ('SA51', 'سرج'), ('SA512', 'سرج'),
    ('SA5', 'سرج'),
    ('VS51', 'سرج'),
    
    # VBRZ - appears as generic "سرج"
    ('VBRZ', 'سرج'),
]

SHEET_TYPES = {
    'Metric Plain Fittings (1)': 'كوع 90',
    'Metric Plain Fittings (2)': 'كوع 45',
    'Sockets & Tees Metric': 'جلبة وتي',
    'Stubs Flanges Unions Metric': 'مسلوب وفلنشة',
    'Reduced Metric Fittings': 'نقاص وتي نقص',
    'BSP Threaded Fittings': 'وصلات سن',
    'Saddles & Bushings Threaded': 'سرج وجلبة سن',
    'Imperial Plain Fittings BS': 'وصلات لصق انجليزي',
    'Adaptor Series Plain-Threaded': 'محولات',
    'UPVC Ball Valves': 'محابس',
    'Check & Butterfly Valves': 'صمامات',
}

def get_prefix_name(code_str):
    """Match code_str to a fitting name prefix."""
    for pref, name in FITTING_PREFIXES:
        if code_str.startswith(pref):
            return name
    return None

# Count available products per sheet
for sname, scat in SHEET_TYPES.items():
    count = 0
    ws = wb[sname]
    for row in ws.iter_rows(min_row=4, values_only=True):
        code, size, pack, box, price = row if len(row) >= 5 else (row[0] if row else None, None, None, None, None)
        if not code or not size:
            continue
        code_str = str(code).strip()
        size_str = str(size).strip()
        if not price or str(price).strip() in ('', '-'):
            continue
        count += 1
    print(f"{sname:40s} ({scat:20s}): {count} products")

updates = []
unmatched = []

for r in remaining:
    db_subcat = r['subcat']
    db_size = r['size']
    db_price = float(r['retail_price'])
    
    found = False
    for sname, scat in SHEET_TYPES.items():
        if scat != db_subcat:
            continue
        ws = wb[sname]
        for row in ws.iter_rows(min_row=4, values_only=True):
            code, size, pack, box, price = row if len(row) >= 5 else (row[0] if row else None, None, None, None, None)
            if not code or not size:
                continue
            code_str = str(code).strip()
            size_str = str(size).strip()
            if not price or str(price).strip() in ('', '-'):
                continue
            price_val = float(price)
            
            # Compare size and price numerically
            if size_str == db_size and abs(price_val - db_price) < 0.01:
                prefix_name = get_prefix_name(code_str)
                if prefix_name:
                    new_name = f'{prefix_name} {size_str}'
                    updates.append((r['name'], new_name, db_subcat, db_size, db_price, code_str))
                    found = True
                    break
        
        if found:
            break
    
    if not found:
        unmatched.append(r)

print(f"\nMatched: {len(updates)}")
print(f"Still unmatched: {len(unmatched)}")

if unmatched:
    print("\n=== Unmatched ===")
    for u in unmatched:
        # Search Excel for any match ignoring price
        found_size = False
        for sname, scat in SHEET_TYPES.items():
            if scat != u['subcat']:
                continue
            ws = wb[sname]
            for row in ws.iter_rows(min_row=4, values_only=True):
                code, size, pack, box, price = row if len(row) >= 5 else (row[0] if row else None, None, None, None, None)
                if not code or not size:
                    continue
                code_str = str(code).strip()
                size_str = str(size).strip()
                if not price or str(price).strip() in ('', '-'):
                    continue
                price_val = float(price)
                
                if size_str == u['size']:
                    prefix_name = get_prefix_name(code_str)
                    if prefix_name:
                        print(f"{u['name']:25s} | subcat={u['subcat']:15s} | size={u['size']:15s} | DB price={u['retail_price']:>8s} | EXCEL code={code_str:15s} price={price_val:>8.2f} name={prefix_name}")
                    else:
                        print(f"{u['name']:25s} | subcat={u['subcat']:15s} | size={u['size']:15s} | DB price={u['retail_price']:>8s} | EXCEL code={code_str:15s} price={price_val:>8.2f} NO PREFIX MATCH")
                    found_size = True
                    break
            if found_size:
                break
        
        if not found_size:
            print(f"{u['name']:25s} | subcat={u['subcat']:15s} | size={u['size']:15s} | DB price={u['retail_price']:>8s} | NO SIZE MATCH IN EXCEL")

if updates:
    lines = []
    lines.append("-- Fix remaining Comer product names (batch 2)")
    for old_name, new_name, subcat, size, price, code in updates:
        price_str = f"{price:.2f}"
        new_name_esc = new_name.replace("'", "''")
        subcat_esc = subcat.replace("'", "''")
        size_esc = size.replace("'", "''")
        
        lines.append(f"""UPDATE products SET name = '{new_name_esc}'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = '{subcat_esc}'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - {price_str}) < 0.01
  AND size = '{size_esc}'
  AND name LIKE 'كومر%';""")
    
    header = f"-- Generated {len(lines)-1} UPDATE statements"
    sql = '\n'.join([header] + lines)
    with open(r'C:\eg-co-erp\fix_comer_names_batch2.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f"\nWrote {len(lines)-1} updates")
