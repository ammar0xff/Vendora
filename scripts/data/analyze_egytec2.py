import openpyxl, sys
from collections import Counter

sys.stdout.reconfigure(encoding='utf-8')

path = r'C:\eg-co-erp\LISTS\ايجيك.xlsx'
wb = openpyxl.load_workbook(path, data_only=True)
ws = wb['Sheet1']

first_words = Counter()
for row in ws.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material:
        continue
    words = str(material).strip().split()
    fw = words[0].strip() if words else ''
    if fw and fw[0].isdigit():
        # Skip numeric, use second word
        fw = words[1].strip() if len(words) > 1 else fw
    first_words[fw] += 1

print(f"Unique first words (potential subcategories): {len(first_words)}\n")
for fw, count in first_words.most_common(50):
    print(f"  {fw}: {count}")
