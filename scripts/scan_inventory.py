import pandas as pd
import json
import os
import glob

BASE = r'C:\eg-co-erp\LISTS\جرد المخازن'
files = sorted(glob.glob(os.path.join(BASE, '*.xlsx')))

# Index-based config to avoid encoding issues
# Key = sorted index, value = (name_col, [qty_col_candidates])
FILE_CONFIG = {
    0:  (1, [2]),        # جرد الرفوف تحت الصندلة
    1:  (1, [2]),        # جرد مخزن البولى
    2:  (2, [3]),        # جرد المخزن الكبير بولي (name in col 2)
    3:  (1, [2]),        # جرد رف 4
    4:  (0, [1]),        # جرد الصندلة (2-col format, name in col 0)
    5:  (1, [2]),        # جرد مخزن الحديد
    6:  (1, [2]),        # رف 1 (2)
    7:  (1, [2]),        # رف 10
    8:  (1, [2]),        # رف 11
    9:  (1, [2]),        # رف 12
    10: (1, [2]),        # رف 13
    11: (1, [2]),        # رف 14
    12: (1, [2]),        # رف 2
    13: (1, [2]),        # رف 3
    14: (1, [2]),        # رف 5
    15: (1, [2]),        # رف 6
    16: (2, [3, 5]),     # رف 7 (name in col 2, qty in col 3 or 5)
    17: (1, [2]),        # رف 8
    18: (1, [2]),        # رف 9
    19: (1, [2, 3]),     # مخزن نواكل (qty in col 2 or 3)
    20: (1, [2]),        # مخزن داخلى بولى 15
    21: (1, [2]),        # مخزن داخلي0
}

SKIP_NAMES = [
    'اسم الصنف', 'الصنف', 'العدد', 'البيان', 'رقم الرف', 'رقم الرف ا',
    'اجمالى', 'الاجمالى', 'المخزن', 'نوع الرف', 'الاجمالي',
    'الصنف', 'العدد', 'البيان', 'الوحدة', 'الاجمالي', 'سعر البيع',
]

def is_noise(val):
    if not val or len(val.strip()) == 0:
        return True
    v = val.strip()
    if v in SKIP_NAMES:
        return True
    if len(v) <= 2 and not any('\u0600' <= c <= '\u06FF' for c in v):
        return True
    if len(set(v)) <= 2 and len(v) > 5:
        return True
    # Pure numbers (barcode numbers or codes)
    if v.replace('.','').replace('/','').isdigit() and len(v) < 6:
        return True
    return False

def is_header_row(row):
    if row[0] is not None:
        c0 = str(row[0]).strip()
        if c0 in ('رقم الرف', 'رقم الرف ا', 'م', 'ت', 'م ', 'ت ', 'الرف'):
            return True
    return False

products = []

for idx, f in enumerate(files):
    df = pd.read_excel(f, engine='openpyxl', header=None)
    fname = os.path.basename(f)
    nc, qty_cols = FILE_CONFIG.get(idx, (1, [2]))

    count = 0
    for i in range(len(df)):
        row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]

        if is_header_row(row):
            continue

        if nc >= len(row):
            continue

        val = row[nc]
        if val is None or not isinstance(val, str):
            continue
        if is_noise(val):
            continue

        name = val.strip()

        # Skip section titles like "جرد المخزن الداخلى فوق الرفوف"
        if len(name) > 10 and 'مخزن' in name and len([c for c in name if c == ' ']) > 2:
            continue

        qty = 0
        for c in qty_cols:
            if c < len(row) and row[c] is not None:
                try:
                    v = float(str(row[c]).replace(',', '').replace(' ', ''))
                    if v > qty:
                        qty = v
                except:
                    pass
        if qty == int(qty):
            qty = int(qty)

        products.append({'name': name, 'qty': qty, 'file': fname})
        count += 1

    print('%s: %d products' % (fname, count))

out = os.path.join(os.environ.get('TEMP', '.'), 'products_extracted.json')
with open(out, 'w', encoding='utf-8') as f:
    json.dump(products, f, ensure_ascii=False, indent=1)
print('\nTotal: %d products' % len(products))
print('Saved to %s' % out)
