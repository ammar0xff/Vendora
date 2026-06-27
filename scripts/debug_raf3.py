import pandas as pd
f = r'C:\eg-co-erp\LISTS\جرد المخازن\رف 3.xlsx'
df = pd.read_excel(f, engine='openpyxl', header=None)
for i in range(len(df)):
    row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]
    has_val = any(row[c] is not None for c in range(2, min(5, len(row))))
    if has_val:
        print(f'[{i:3d}] {row[:5]}')
