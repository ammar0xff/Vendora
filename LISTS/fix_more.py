import openpyxl, sys
sys.stdout.reconfigure(encoding='utf-8')

path = r'C:\eg-co-erp\LISTS\ايجيك.xlsx'
wb = openpyxl.load_workbook(path, data_only=True)
ws = wb['Sheet1']

# Show products with problematic subcategory names
bad_prefixes = ('-مم', '3/مم', '50', '63', '75', '90', 'P.Pمم', 'Sبداية', 'Sدرجة', 'Sسم', 'Sمتر', 'Sمخرج', 'Sمشترك', 'S.63', 'Sمم', 'Sسم', 'Sمتر')
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material: continue
    words = str(material).strip().split()
    fw = words[0].strip() if words else ''
    if fw in bad_prefixes or fw.startswith('Sبداية') or fw.startswith('Sدرجة') or fw == 'Sسم' or fw == 'Sمتر' or fw == 'Sمخرج' or fw == 'Sمشترك' or fw == 'S.63' or fw == 'Sمم':
        print(f"  [{fw}] -> {str(material).strip()}")
