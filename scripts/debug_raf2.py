import pandas as pd
f = r'C:\eg-co-erp\LISTS\جرد المخازن\رف 2.xlsx'
df = pd.read_excel(f, engine='openpyxl', header=None)

print('All data:')
for i in range(len(df)):
    row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]
    # Check if any of cols 3-5 have values
    has_price = any(row[c] is not None for c in range(3, min(6, len(row))))
    if has_price or i < 3:
        print(f'[{i:3d}] {row}')
