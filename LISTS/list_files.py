import os
for f in os.listdir(r'C:\eg-co-erp\LISTS'):
    path = os.path.join(r'C:\eg-co-erp\LISTS', f)
    if os.path.isfile(path) and f.endswith('.xlsx'):
        size = os.path.getsize(path)
        print(f'{size:>8} | {f}')
