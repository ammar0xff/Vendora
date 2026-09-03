import pdfplumber
import json

pdf = pdfplumber.open(r'C:\eg-co-erp\LISTS\ايديال.pdf')
output = {"pages": [], "total_pages": len(pdf.pages)}

for i in range(3, min(15, len(pdf.pages))):
    page = pdf.pages[i]
    tables = page.extract_tables()
    tables_data = []
    for t in tables:
        rows = []
        for r in t:
            rows.append([str(c) if c else "" for c in r])
        tables_data.append(rows)
    output["pages"].append({"page": i+1, "tables": tables_data})

pdf.close()
with open(r'C:\eg-co-erp\LISTS\ideal_extracted.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)
print(f"Done! Extracted {len(output['pages'])} pages to ideal_extracted.json")
