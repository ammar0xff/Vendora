import subprocess
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

# Check names more carefully - what chars do they actually contain?
# Look for names that have Arabic chars but NOT the common ones (ا ب ت ث etc)
garbled = []
for p in products:
    name = p['name']
    has_bad_arabic = False
    bad_chars = []
    for ch in name:
        o = ord(ch)
        # Suspicious: Arabic range but not standard letters
        if 0x0600 <= o <= 0x06FF:
            if not (
                (0x0621 <= o <= 0x064A) or  # Arabic letters
                (0x0660 <= o <= 0x0669) or  # Arabic digits
                o in (0x060C, 0x061B, 0x061F, 0x0640, 0x064B, 0x064C, 0x064D, 0x064E, 0x064F, 0x0650, 0x0651, 0x0652)  # punctuation/diacritics
            ):
                has_bad_arabic = True
                bad_chars.append(f"U+{o:04X}")
    
    if has_bad_arabic:
        garbled.append({
            'id': p['id'],
            'name': name,
            'company': p['company'],
            'bad_chars': list(set(bad_chars))[:5]
        })

print(f"Garbled: {len(garbled)}")

# Show samples with char details
for g in garbled[:10]:
    print(f"  ID: {g['id'][:8]}...")
    print(f"  Name: {g['name'][:80]}")
    print(f"  Bad chars: {g['bad_chars']}")
    print()
