import openpyxl, sys, os, re
sys.stdout.reconfigure(encoding='utf-8')

d = r'C:\eg-co-erp\LISTS\done'
for f in os.listdir(d):
    if not f.endswith('.xlsx') or 'شريف' in repr(f)[:50]:
        continue
    path = os.path.join(d, f)
    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb['Sheet1']

from collections import defaultdict

# Group all products by their normalized category
groups = defaultdict(list)

for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material:
        continue
    
    material_str = str(material).strip()
    words = material_str.split()
    first = words[0] if words else ''
    
    # Normalize category based on pattern matching
    if first == 'مواسير':
        # Pipes - subcategorize by material type
        if 'فايبر' in material_str:
            subcat = 'مواسير فايبر'
        elif 'لحام' in material_str:
            subcat = 'مواسير لحام'
        elif 'PPR' in material_str:
            subcat = 'مواسير PPR'
        else:
            subcat = 'مواسير'
    elif first.startswith('S-') or first.startswith('Sمم') or first.startswith('S-مم') or first.startswith('S-°') or first.startswith('PP-مم'):
        subcat = 'وصلات صرف S'
    elif first.startswith('ML') or first.startswith('UVمم'):
        subcat = 'وصلات صرف'
    elif first == 'P.P' or first == 'PP-مم' or first == 'مم':
        subcat = 'وصلات صرف PP'
    elif first in ('كوع', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة', 'صليبة'):
        # Fittings
        if 'UV' in material_str:
            subcat = f'{first} UV'
        elif 'لحام' in material_str or 'PPR' in material_str:
            subcat = f'{first} لحام'
        elif 'بسن' in material_str:
            subcat = f'{first} بسن'
        elif 'فايبر' in material_str:
            subcat = f'{first} فايبر'
        else:
            subcat = f'{first} لحام'
    elif first == 'مشترك':
        if 'باب' in material_str:
            subcat = 'مشترك بباب كشف'
        elif '45' in material_str or '87' in material_str:
            subcat = 'مشترك مائل'
        else:
            subcat = 'مشترك'
    elif first == 'محبس':
        if 'دفن' in material_str:
            subcat = 'محبس دفن'
        elif 'طارة' in material_str:
            subcat = 'محبس طارة'
        elif 'بلية' in material_str:
            subcat = 'محبس بلية'
        else:
            subcat = 'محبس'
    elif first == 'صفاية':
        subcat = 'صفاية'
    elif first == 'علاية':
        subcat = 'علاية صفاية'
    elif first == 'غطاء':
        subcat = 'غطاء'
    elif first == 'بردة':
        subcat = 'بردة لحام'
    elif first == 'بيبة':
        subcat = 'بيبة'
    elif first == 'ياردة':
        subcat = 'ياردة'
    elif first == 'غراء':
        subcat = 'غراء'
    elif first == 'هواية':
        subcat = 'هواية'
    elif first == 'رقبة':
        subcat = 'رقبة'
    elif first == 'مخرج':
        subcat = 'مخرج خلاط'
    elif first == 'جاليتراب':
        subcat = 'جاليتراب'
    elif first == 'واي':
        subcat = 'واي فلتر'
    elif first == 'طلمبة':
        subcat = 'طلمبة مياه'
    elif first in ('قفيز', 'بطارية'):
        subcat = first
    elif first == 'سيفون':
        subcat = 'سيفون'
    elif first == 'مجمع':
        subcat = 'مجمع صرف'
    elif first == 'غرفة':
        subcat = 'غرفة تفتيش'
    elif first == 'S':
        if 'مخرج' in material_str:
            subcat = 'مخرج خلاط دفن'
        elif 'خلاط' in material_str:
            subcat = 'مخرج خلاط دفن'
        else:
            subcat = 'وصلات صرف S'
    elif first in ('درجة',):
        subcat = 'مشترك صرف'
    elif first == 'PP-مم' or first.startswith('PP'):
        subcat = 'وصلات صرف PP'
    else:
        subcat = 'أخرى'
    
    groups[subcat].append((material_str, brand, price, code))

print(f"{'Subcategory':30s} | Count")
print('-' * 40)
for scat in sorted(groups.keys()):
    count = len(groups[scat])
    print(f'{scat:30s} | {count:3d}')

print(f'\nTotal: {sum(len(v) for v in groups.values())}')
