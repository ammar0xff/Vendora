import pandas as pd
import json

f = r'C:\eg-co-erp\LISTS\جرد المخازن\رف 7.xlsx'
df = pd.read_excel(f, engine='openpyxl', header=None)
for i in range(len(df)):
    row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]
    print('[%3d] %s' % (i, row))
