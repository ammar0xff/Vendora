import tabula
import os

pdf_path = r'C:\eg-co-erp\LISTS\ايديال.pdf'
xlsx_path = r'C:\eg-co-erp\LISTS\ايديال.xlsx'

# Read all tables from the PDF
print("Extracting tables from Ideal PDF...")
dfs = tabula.read_pdf(pdf_path, pages='all', multiple_tables=True, encoding='utf-8')
print(f"Extracted {len(dfs)} tables")

# Save to Excel
if dfs:
    with pd.ExcelWriter(xlsx_path) as writer:
        for i, df in enumerate(dfs):
            sheet_name = f'Sheet_{i+1}'
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            print(f"  Sheet {i+1}: {len(df)} rows, {len(df.columns)} cols")
    print(f"\nSaved to {xlsx_path}")
else:
    print("No tables found!")
