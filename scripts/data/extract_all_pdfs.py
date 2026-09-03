from pypdf import PdfReader

for pdf_name, out_name in [('بروج.pdf', 'borouj_text.txt'), ('دروفيت.pdf', 'drovit_text.txt')]:
    pdf_path = rf'C:\eg-co-erp\LISTS\{pdf_name}'
    out_path = rf'C:\eg-co-erp\LISTS\{out_name}'
    r = PdfReader(pdf_path)
    with open(out_path, 'w', encoding='utf-8') as f:
        for i, page in enumerate(r.pages):
            txt = page.extract_text()
            f.write(f'=== PAGE {i+1} ({len(txt)} chars) ===\n')
            f.write(txt)
            f.write('\n\n')
    print(f'{pdf_name}: {len(r.pages)} pages -> {out_name}')
