import openpyxl, subprocess, datetime
from collections import OrderedDict

cmd = [
    'docker', 'exec', 'eg-co-erp-db-1',
    'psql', '-U', 'postgres', '-d', 'inventory_db',
    '-At', '-F|', '-c',
    "SELECT c.name, coalesce(p.company,''), p.name, coalesce(p.size,''), coalesce(p.material,''), p.id::text "
    "FROM products p "
    "JOIN subcategories s ON s.id = p.subcategory_id "
    "JOIN categories c ON c.id = s.category_id "
    "WHERE p.retail_price = 0 OR p.retail_price IS NULL "
    "ORDER BY c.name, p.name"
]

result = subprocess.run(cmd, capture_output=True)
raw = result.stdout.decode('utf-8').strip()
categories = OrderedDict()
for line in raw.split('\n'):
    if not line:
        continue
    parts = line.split('|')
    cat = parts[0]
    if cat not in categories:
        categories[cat] = []
    categories[cat].append((parts[1], parts[2], parts[3], parts[4], parts[5]))

wb = openpyxl.Workbook()
wb.remove(wb.active)
for cat_name, products in categories.items():
    ws = wb.create_sheet(title=cat_name[:31])
    ws.append(['الشركة', 'اسم المنتج', 'المقاس', 'البراند', 'السعر', 'id'])
    for company, name, size, brand, pid in products:
        ws.append([company, name, size, brand, None, pid])

wb.save(r'C:\eg-co-erp\noprice_' + datetime.datetime.now().strftime('%H%M%S') + '.xlsx')
print(f'OK: {len(categories)} sheets, {sum(len(v) for v in categories.values())} products')
print(f'Fill prices in column E, then run: python import_prices.py')
