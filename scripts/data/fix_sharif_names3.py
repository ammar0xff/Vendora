import openpyxl, sys
from decimal import Decimal

sys.stdout.reconfigure(encoding='utf-8')

path = r'C:\eg-co-erp\LISTS\done\الشريف.xlsx'
wb = openpyxl.load_workbook(path, data_only=True)
ws = wb['All_Products']

lines = []
updates = 0

def sql(s):
    lines.append(s)

def sv(v):
    return str(v) if v is not None else ''

CAT = 'الشريف'

for row in ws.iter_rows(min_row=2, values_only=True):
    system, cat, prod_name, size, thickness, price = row
    if not system:
        continue
    system = sv(system).strip()
    if 'UPVC-N' not in system:
        continue  # only fix UPVC-N products
    
    cat = sv(cat).strip()
    prod_name = sv(prod_name).strip()
    size = sv(size).strip()
    thickness = sv(thickness).strip()
    if not price:
        continue
    price_v = Decimal(str(price))
    
    # Build clean name: remove "الرصف الأبيض" from middle too
    clean_prod = prod_name.replace('الرصف الأبيض', '').replace('  ', ' ').strip()
    if clean_prod.startswith('مواسير'):
        clean_prod = 'مواسير' + clean_prod[7:]
    clean_prod = clean_prod.strip()
    if clean_prod.startswith('- '):
        clean_prod = clean_prod[2:]
    
    if thickness and cat == 'مواسير':
        clean_name = f'{clean_prod} - {size} - سمك {thickness}'
    else:
        clean_name = f'{clean_prod} - {size}'
    
    clean_name = clean_name.replace("'", "''")
    cat_esc = cat.replace("'", "''")
    size_esc = size.replace("'", "''")
    
    sql(f"""UPDATE products SET name = '{clean_name}'
WHERE company = '{CAT}'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = '{cat_esc}' 
                        AND category_id = (SELECT id FROM categories WHERE name = '{CAT}'))
  AND retail_price = {price_v}
  AND size = '{size_esc}';""")
    updates += 1

output = r'C:\eg-co-erp\fix_sharif_names3.sql'
with open(output, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print(f"Wrote {updates} UPDATE statements")
