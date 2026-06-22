from pypdf import PdfReader

reader = PdfReader(r'C:\eg-co-erp\LISTS\done\COMER BY NEISCO 09-04-2026.pdf')
out = open(r'C:\eg-co-erp\comer_pdf_text.txt', 'w', encoding='utf-8')

for i, page in enumerate(reader.pages):
    text = page.extract_text()
    out.write(f"\n{'='*60}\nPAGE {i+1}\n{'='*60}\n{text}\n")

out.close()
print(f"Done - {len(reader.pages)} pages")
