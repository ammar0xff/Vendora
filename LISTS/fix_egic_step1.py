import sys, re
sys.stdout.reconfigure(encoding='utf-8')

# Step 1: Remove [code] from names
sql = []
sql.append("-- Step 1: Remove [code] from EGIC names")
sql.append("UPDATE products SET name = trim(regexp_replace(name, '\\\\[[0-9]+\\\\]$', '')) WHERE company = 'بي ار' AND name ~ '\\\\[[0-9]+\\\\]$';")
sql.append("UPDATE products SET name = trim(regexp_replace(name, '\\[[0-9]+\\]$', '')) WHERE company = 'بي ار' AND name ~ '\\[[0-9]+\\]$';")
sql.append("")

# Better approach with simpler regex
sql2 = []
sql2.append("-- Fix EGIC/بي ار product names - remove codes")
sql2.append("UPDATE products SET name = trim(substring(name from 1 for length(name) - position('[' in reverse(name)))) WHERE company = 'بي ار' AND name LIKE '%[0-9]%' AND name LIKE '%[[]%';")
sql2.append("")

# Actually let's just do it in Python by reading and generating targeted SQL
import openpyxl, os

d = r'C:\eg-co-erp\LISTS\done'
egic_path = None
for f in os.listdir(d):
    if f.endswith('.xlsx') and 'شريف' not in repr(f):
        egic_path = os.path.join(d, f)
        break

class CLASSIFIER:
    def classify(self, name):
        words = name.split()
        first = words[0] if words else ''

        # Determine subcategory
        if first == 'مواسير':
            subcat = 'مواسير فايبر' if 'فايبر' in name else 'مواسير PPR'
        elif first in ('كوع', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة', 'صليبة'):
            if 'UV' in name or 'صرف' in name:
                subcat = f'{first} صرف'
            elif 'فايبر' in name:
                subcat = f'{first} فايبر'
            elif 'بسن' in name or 'خارجي' in name:
                subcat = f'{first} بسن'
            else:
                subcat = f'{first} لحام'
        elif first == 'مشترك':
            if 'باب' in name: subcat = 'مشترك بباب كشف'
            elif '45' in name or '87' in name or 'مائل' in name or 'درجة' in name: subcat = 'مشترك مائل'
            elif 'صليبة' in name: subcat = 'مشترك صليبة'
            else: subcat = 'مشترك'
        elif first == 'محبس':
            if 'دفن' in name: subcat = 'محبس دفن'
            elif 'طارة' in name: subcat = 'محبس طارة'
            elif 'بلية' in name or 'بلي' in name: subcat = 'محبس بلية'
            elif 'إيليت' in name.lower(): subcat = 'محبس إيليت'
            else: subcat = 'محبس'
        elif first == 'مم':
            if len(words) >= 2 and words[1] in ('فلنشة', 'فﻼنشة'): subcat = 'فلنشة لحام'
            elif 'مانع' in name: subcat = 'مانع ارتداد'
            else: subcat = 'أخرى'
        elif first.startswith('S-') or first.startswith('Sمم') or first.startswith('S-مم') or first.startswith('S-°') or first.startswith('S.'):
            subcat = 'وصلات صرف S'
        elif first.startswith('ML') or first.startswith('UVمم'):
            subcat = 'وصلات صرف'
        elif first.startswith('P.P') or first.startswith('PP-مم') or first.startswith('PPمم') or first.startswith('مدفونP.P') or first.startswith('مدفون'):
            subcat = 'وصلات صرف PP'
        elif first == 'بوصة' or (first[0].isdigit() and '/' in first):
            if 'مانع' in name: subcat = 'مانع ارتداد'
            elif 'علاية' in name: subcat = 'علاية صفاية'
            elif 'صفاية' in name: subcat = 'صفاية'
            else: subcat = 'أخرى'
        elif first == 'S':
            if 'غطاء' in name or 'غرفة' in name or 'قاعدة' in name: subcat = 'غرفة تفتيش'
            elif 'مخرج' in name or 'خلاط' in name: subcat = 'مخرج خلاط دفن'
            elif 'مجرى' in name: subcat = 'مجرى مائي'
            elif 'مانع' in name: subcat = 'مانع ارتداد'
            else: subcat = 'أخرى'
        elif first.startswith('Sمخرج') or first.startswith('Sدرجة') or first.startswith('Sبداية') or first.startswith('Sمشترك'):
            subcat = 'مجرى مائي'
        elif first == 'درجة': subcat = 'مشترك صرف'
        elif first == 'P.Pمم': subcat = 'وصلات صرف PP'
        elif first == 'TILEABLEمم' or first == 'TILEABLE': subcat = 'علاية صفاية'
        elif first == 'جسم' or first == 'قاعدة': subcat = 'غرفة تفتيش' if 'غرفة' in name else 'أخرى'
        elif first == 'Sسم': subcat = 'غرفة تفتيش' if 'غطاء' in name else 'وصلات صرف S'
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

        if first == 'مم' and len(words) >= 2 and words[1] in ('فلنشة', 'فﻼنشة'):
            # Fix name: remove leading مم
            new_name = ' '.join(words[1:])
        elif first == 'مم' and len(words) >= 2 and 'مانع' in name:
            new_name = name
        else:
            new_name = name

        new_name = new_name.replace('فﻼنشة', 'فلنشة').replace('عﻼية', 'علاية')

        return subcat, new_name.strip()

cls = CLASSIFIER()

# Build lookup from Excel: code -> (material, subcategory from our analysis)
excel_data = {}
if egic_path:
    wb = openpyxl.load_workbook(egic_path, data_only=True)
    ws = wb['Sheet1']
    for row in ws.iter_rows(min_row=2, values_only=True):
        code, material, brand, price = row
        if not material:
            continue
        code_str = str(code).strip()
        material_str = str(material).strip()
        subcat, _ = cls.classify(material_str)
        excel_data[code_str] = (material_str, subcat)

print(f"Loaded {len(excel_data)} reference products from Excel")

# Now read products from DB and generate UPDATEs
# Since we can't connect directly, let's export the data first
# We'll generate SQL to fix products

# First, let's just do the name cleanup (remove codes) via direct SQL
print("Generating Step 1 SQL...")
with open(r'C:\eg-co-erp\fix_egic_step1.sql', 'w', encoding='utf-8') as f:
    f.write("-- Remove [code] from EGIC/بي ار product names\n")
    f.write("UPDATE products SET name = trim(regexp_replace(name, '\\\\[[0-9]+\\\\]$', '')) WHERE company = 'بي ار' AND name ~ '\\\\[[0-9]+\\\\]$';\n")
    f.write("UPDATE products SET name = trim(regexp_replace(name, '\\\\[[0-9]+\\\\]$', '')) WHERE company = 'بي ار' AND name ~ '\\\\[[0-9]+\\\\]$';\n")
    f.write("UPDATE products SET name = replace(name, 'ﻼ', 'لا') WHERE company = 'بي ار' AND name LIKE '%ﻼ%';\n")
    f.write("UPDATE products SET name = replace(name, 'ﻻ', 'لا') WHERE company = 'بي ار' AND name LIKE '%ﻻ%';\n")
    f.write("UPDATE products SET name = replace(name, replace(name, 'فﻼنشة', 'فلنشة')) WHERE company = 'بي ار' AND name LIKE '%فﻼنشة%';\n")

print("Done!")
print("\nNow you need to:")
print("1. Export current بي ار products:")
print(r"   docker exec eg-co-erp-db-1 psql -U postgres -d inventory_db -c `\copy (SELECT id, name, subcategory_id) FROM products WHERE company = 'بي ار' TO '/tmp/egic_export.csv' WITH CSV HEADER`")
print("2. Run this script again to generate step 2 SQL")
