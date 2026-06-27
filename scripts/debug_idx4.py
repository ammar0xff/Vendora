import pandas as pd, os, glob

BASE = r'C:\eg-co-erp\LISTS\جرد المخازن'
files = sorted(glob.glob(os.path.join(BASE, '*.xlsx')))

f = files[4]
print('File:', os.path.basename(f))
df = pd.read_excel(f, engine='openpyxl', header=None)
print('Shape:', df.shape)
for i in range(min(20, len(df))):
    row = [v if not pd.isna(v) else None for v in df.iloc[i].tolist()]
    print('[%2d] %s' % (i, row))
