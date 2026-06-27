import os, glob, pandas as pd

BASE = r'C:\eg-co-erp\LISTS\جرد المخازن'
files = sorted(glob.glob(os.path.join(BASE, '*.xlsx')))

for idx, f in enumerate(files):
    df = pd.read_excel(f, engine='openpyxl', header=None)
    fname = os.path.basename(f)
    print(f'[{idx:2d}] {fname}  shape={list(df.shape)}')
    
    # Find header row (has Arabic column names)
    header_row = None
    for i in range(min(5, len(df))):
        row_text = ' | '.join([str(v)[:30] for v in df.iloc[i].tolist() if not pd.isna(v)])
        if any(kw in row_text for kw in ['سعر', 'اجمال', 'البيع']):
            header_row = i
            print(f'      Price headers at row {i}: {[v for v in df.iloc[i].tolist() if not pd.isna(v)][:6]}')
            break
    
    # Print first few data rows (with prices)
    data_shown = 0
    for i in range(len(df)):
        if data_shown >= 3:
            break
        row = df.iloc[i]
        # Skip rows where product name column is not a valid name
        name_col = 1  # default
        if idx in [2]: name_col = 2  # جرد المخزن الكبير
        if idx in [4]: name_col = 0  # جرد الصندلة
        if idx in [16]: name_col = 2  # رف 7
        
        if name_col < len(row):
            val = row[name_col]
            if not pd.isna(val) and isinstance(val, str) and len(val.strip()) > 3:
                if not any(kw in str(val) for kw in ['اسم', 'الصنف', 'العدد', 'رف ', 'جرد', 'مخزن']):
                    data_shown += 1
                    row_data = [v for v in row.tolist()]
                    print(f'      [{i}] {row_data}')
    print()
