import pandas as pd

files = [
    (r'C:\eg-co-erp\LISTS\جرد المخازن\رف 2.xlsx', 'رف 2'),
    (r'C:\eg-co-erp\LISTS\جرد المخازن\رف 3.xlsx', 'رف 3'),
    (r'C:\eg-co-erp\LISTS\جرد المخازن\رف 14.xlsx', 'رف 14'),
]

for f, name in files:
    df = pd.read_excel(f, engine='openpyxl', header=None)
    print(f'=== {name} === cols={df.shape[1]}')
    for i in range(len(df)):
        row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]
        has_col3 = row[3] is not None if len(row) > 3 else False
        has_col4 = row[4] is not None if len(row) > 4 else False
        if any([has_col3, has_col4]) or i < 3:
            print(f'[{i:3d}] {row[:6]}')
    print()
