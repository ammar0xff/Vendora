import subprocess
import re
import json

r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '\t',
     '-c', "SELECT row_to_json(t)::text FROM (SELECT id, name, company, subcategory_id FROM products WHERE company IN ('ايديال', 'دروفيت')) t"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

products = []
for line in r.stdout.strip().split('\n'):
    line = line.strip()
    if line.startswith('{'):
        try:
            products.append(json.loads(line))
        except:
            pass

# Check for corrupted Arabic (chars that look like mojibake)
def is_clean_arabic(s):
    """Check if name has only clean Arabic or acceptable chars."""
    for ch in s:
        o = ord(ch)
        # Allow clean Arabic range (letters)
        if 0x0627 <= o <= 0x064A:  # ا to ي
            continue
        # Allow Arabic digits
        if 0x0660 <= o <= 0x0669:
            continue
        # Allow Arabic punctuation
        if o in (0x060C, 0x061B, 0x061F, 0x0640):  # comma, semicolon, question, tatweel
            continue
        # Allow ASCII alphanumeric and common punctuation
        if chr(o).isascii():
            if chr(o).isalnum() or chr(o) in ' -.,()[]/xX':
                continue
        # Allow other common chars
        if ch in '×•':
            continue
        # If it's a non-standard char in the Arabic block, it's suspicious
        if 0x0600 <= o <= 0x06FF:
            return False, f"suspicious Arabic char U+{o:04X} ({ch})"
    return True, ''

garbled = []
for p in products:
    ok, reason = is_clean_arabic(p['name'])
    if not ok:
        garbled.append(p)
        if len(garbled) <= 20:
            print(f"  [{p['id'][:8]}...] {repr(p['name'][:70])} ({p['company']})")

print(f"\nTotal garbled: {len(garbled)}")
