import pandas as pd, json, os, glob

BASE = r'C:\eg-co-erp\LISTS\جرد المخازن'
files = sorted(glob.glob(os.path.join(BASE, '*.xlsx')))

print('File index mapping:')
for i, f in enumerate(files):
    df = pd.read_excel(f, engine='openpyxl', header=None)
    print('[%2d] %-45s shape=%s' % (i, os.path.basename(f), list(df.shape)))
