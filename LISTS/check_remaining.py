import os, openpyxl

# Check each xlsx file that has Arabic in its name
for f in os.listdir(r'C:\eg-co-erp\LISTS'):
    path = os.path.join(r'C:\eg-co-erp\LISTS', f)
    if not os.path.isfile(path) or not f.endswith('.xlsx'):
        continue
    try:
        wb = openpyxl.load_workbook(path, data_only=True)
        print(f'='*60)
        print(f'File: {f}')
        print(f'Path: {path}')
        print(f'Size: {os.path.getsize(path)}')
        print(f'Sheets: {wb.sheetnames}')
        for s in wb.sheetnames:
            ws = wb[s]
            print(f'  [{s}] rows={ws.max_row}')
            for r in range(1, min(4, ws.max_row+1)):
                cells = [str(ws.cell(r,c).value or '')[:40] for c in range(1, min(ws.max_column+1, 6))]
                print(f'    r{r}: {cells}')
        print()
    except Exception as e:
        print(f'Error with {f}: {e}')
