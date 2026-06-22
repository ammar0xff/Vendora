"""
Extract Ideal Standard PDF tables using pdfplumber with better settings.
Focuses on table areas that contain product data.
"""
import pdfplumber
import pandas as pd

pdf = pdfplumber.open(r'C:\eg-co-erp\LISTS\ايديال.pdf')

all_rows = []

for i, page in enumerate(pdf.pages):
    # Try extracting tables with various settings
    tables = page.extract_tables({
        'vertical_strategy': 'text',
        'horizontal_strategy': 'text',
    })
    
    for t in tables:
        for row in t:
            # Clean cells
            clean = []
            for cell in row:
                if cell:
                    # Remove newlines, normalize spaces
                    c = cell.replace('\n', ' ').strip()
                    clean.append(c)
                else:
                    clean.append('')
            all_rows.append(clean)

pdf.close()

print(f"Total rows extracted from tables: {len(all_rows)}")

# Show sample rows
for row in all_rows[:20]:
    print(row)

# Save to CSV for inspection
with open(r'C:\eg-co-erp\LISTS\ideal_tables_raw.csv', 'w', encoding='utf-8') as f:
    for row in all_rows:
        f.write('|'.join(row) + '\n')

print(f"\nSaved to ideal_tables_raw.csv - {len(all_rows)} rows")
