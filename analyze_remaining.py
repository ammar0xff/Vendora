import csv, openpyxl, re, sys
sys.stdout.reconfigure(encoding='utf-8')

remaining = []
with open(r'C:\eg-co-erp\remaining_comer.csv', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        remaining.append(row)
print(f"{len(remaining)} remaining")

wb = openpyxl.load_workbook(r'C:\eg-co-erp\LISTS\Neisco_Comer_Price_List_2026.xlsx', data_only=True)

FITTING_NAMES = {
    'EL50N': 'كوع 90', 'EY50N': 'كوع 45',
    'SO10N': 'صولة', 'TE40N': 'تي 90', 'TR40N': 'تي نقص',
    'ST20N': 'مسلوب', 'BR00N': 'فلنشة', 'UN80N': 'يونيون',
    'CA70N': 'غطاء', 'RP20N': 'نقاص', 'RB90N': 'جلبة نقص',
    'RB92N': 'جلبة نقص محول', 'RB94N': 'جلبة نقص محول سن',
    'EL51N': 'كوع 90 سن', 'EY51N': 'كوع 45 سن', 'SO11N': 'صولة سن',
    'TE41N': 'تي 90 سن', 'PL71N': 'وصلة سن', 'CA71N': 'طبة سن',
    'EL53N': 'كوع 90 انجليزي', 'EY53N': 'كوع 45 انجليزي',
    'TE43N': 'تي 90 انجليزي', 'CA73N': 'طبة انجليزي', 'SO13N': 'صولة انجليزي',
    'EL52N': 'كوع 90 محول', 'EL54N': 'كوع 45 محول',
    'TE42N': 'تي محول', 'TE44N': 'تي محول سن', 'TR44N': 'تي نقص محول',
    'AD12N': 'محول', 'AD14N': 'محول سن',
    'SO12N': 'صولة محول', 'SO14N': 'صولة محول سن',
    'UN82N': 'يونيون محول',
    'BVSL10N': 'محبس كرة', 'BVDL10N': 'محبس كرة', 'FV10N': 'محبس رفرف',
    'BVSL11N': 'محبس كرة سن', 'BVDL11N': 'محبس كرة سن',
    'BVSL13N': 'محبس كرة', 'BVDL13N': 'محبس كرة',
    'CVD10N': 'صمام عدم رجوع', 'CVDC10N': 'صمام عدم رجوع',
    'CVD11N': 'صمام عدم رجوع سن', 'CVD13N': 'صمام عدم رجوع سن',
    'CVDC13N': 'صمام عدم رجوع',
    'BUT10N': 'صمام فراشة',
    'RE61N': 'ناقص سن', 'SA51N': 'سرج', 'VS51N': 'سرج',
    'NI61N': 'نبل سن',
    'UN81N': 'يونيون سن',
    'UN83N': 'يونيون انجليزي',
    'RB93N': 'جلبة نقص محول انجليزي',
    'TR43N': 'تي نقص انجليزي',
    'EY54N': 'كوع 45 محول انجليزي',
    'TR41N': 'تي نقص سن',
    'TR45N': 'تي نقص انجليزي',
}

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
                prefix = None
                for k in sorted(FITTING_NAMES.keys(), key=len, reverse=True):
                    if code_str.startswith(k):
                        prefix = FITTING_NAMES[k]
                        break
                if prefix:
                    new_name = f'{prefix} {size_str}'
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
    for u in unmatched[:20]:
        print(f"  {u['name']:25s} | {u['subcat']:20s} | {u['size']:15s} | {u['retail_price']}")

if updates:
    # Generate SQL
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
    
    # Write SQL
    header = f"-- Generated {len(updates)} UPDATE statements for remaining Comer products"
    sql = '\n'.join([header] + lines)
    with open(r'C:\eg-co-erp\fix_comer_names_batch2.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f"\nWrote {len(lines)} updates to fix_comer_names_batch2.sql")
