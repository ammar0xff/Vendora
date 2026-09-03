from pypdf import PdfReader
import re

pdf_path = r'C:\eg-co-erp\LISTS\ايديال.pdf'
txt_path = r'C:\eg-co-erp\LISTS\ideal_text.txt'

r = PdfReader(pdf_path)
with open(txt_path, 'w', encoding='utf-8') as f:
    for i, page in enumerate(r.pages):
        txt = page.extract_text()
        f.write(f'=== PAGE {i+1} ===\n')
        f.write(txt)
        f.write('\n\n')

print(f'Extracted {len(r.pages)} pages to {txt_path}')
