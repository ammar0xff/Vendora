import openpyxl, sys
sys.stdout.reconfigure(encoding='utf-8')

path = r'C:\eg-co-erp\LISTS\ايجيك.xlsx'
wb = openpyxl.load_workbook(path, data_only=True)
ws = wb['Sheet1']

# Show products with problematic first words
problematic = set()
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material: continue
    words = str(material).strip().split()
    fw = words[0].strip() if words else ''
    if fw in ('3/مم', '50', '63', '75', '90') or fw.startswith('S-°'):
        problematic.add(str(material).strip())

print("Problematic products:")
for p in sorted(problematic):
    print(f"  {p}")
