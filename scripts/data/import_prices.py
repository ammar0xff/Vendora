import openpyxl, subprocess

wb = openpyxl.load_workbook(r'C:\eg-co-erp\noprice_export.xlsx')
updated = 0
errors = []

for ws in wb.worksheets:
    for row in ws.iter_rows(min_row=2, values_only=True):
        company, name, size, brand, price, pid = row
        if price is None or str(price).strip() == '':
            continue
        try:
            price_val = float(str(price).replace(',', '.'))
            cmd = [
                'docker', 'exec', 'eg-co-erp-db-1',
                'psql', '-U', 'postgres', '-d', 'inventory_db',
                '-c', f"UPDATE products SET retail_price = {price_val} WHERE id = '{pid}'"
            ]
            result = subprocess.run(cmd, capture_output=True)
            if b'UPDATE 1' in result.stdout:
                updated += 1
            else:
                errors.append(f'{pid}: {result.stderr.decode()}')
        except Exception as e:
            errors.append(f'{pid}: {e}')

print(f'Updated: {updated}')
if errors:
    print(f'Errors ({len(errors)}):')
    for e in errors[:5]:
        print(f'  {e}')
