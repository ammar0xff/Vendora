import openpyxl
from collections import Counter

wb = openpyxl.load_workbook(r'C:\eg-co-erp\LISTS\ايجيك.xlsx', data_only=True)
ws = wb['Sheet1']
rows_by_name = {}
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    name = str(material).strip() if material else ''
    if not name or price is None:
        continue
    if name not in rows_by_name:
        rows_by_name[name] = []
    rows_by_name[name].append((str(code).strip() if code else '', str(brand).strip() if brand else '', str(price)))

for name, rows in sorted(rows_by_name.items(), key=lambda x: -len(x[1])):
    if len(rows) > 1:
        print(f'{len(rows)}x: name={repr(name)}')
        for code, brand, price in rows:
            print(f'   code={repr(code)}, brand={repr(brand)}, price={repr(price)}')
