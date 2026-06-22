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

r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '\t',
     '-c', "SELECT row_to_json(t)::text FROM (SELECT id, name FROM subcategories) t"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

subcats = {}
for line in r2.stdout.strip().split('\n'):
    line = line.strip()
    if line.startswith('{'):
        try:
            sc = json.loads(line)
            subcats[sc['id']] = sc['name']
        except:
            pass

SERIES_ARABIC = {
    'TONIC': 'تونيك', 'KIMERA': 'كيميرا', 'PROSYS': 'بروسيس',
    'HAPPY D.': 'هابي دي', 'D-CODE': 'دي كود', 'SPACE': 'سبيس',
    'CONNECT': 'كونكت', 'X-LARGE': 'إكس لارج', 'SEPARATES': 'سيبريتس',
    'D-NEO': 'دي نيو', 'DURASTYLE': 'ديورا ستايل', 'VERO': 'فيرو',
    'SAN REMO': 'سان ريمو', 'PLAYA': 'بلايا', 'MANTA': 'مانتا',
    'TESI': 'تيسي', 'STARCK 3': 'شتارك 3', 'DARLING': 'دارلينج',
    'L-CUBE': 'إل كيوب', 'PLAN': 'بلان', 'P3 COMFORTS': 'بي 3 كومفورت',
    'DURAPLUS': 'ديورا بلس', 'NEW ESEDRA': 'نيو إيسيدرا',
    'NEW CAPRI': 'نيو كابري', 'PURAVIDA': 'بيورا فيدا', 'SOPHIA': 'صوفيا',
    'IOM ACCESSORIES': 'إكسسوار أيوم', 'ECHO': 'إيكو', 'I.LIFE': 'آي لايف',
    'STUDIO ACCESSORIES': 'إكسسوار ستوديو', 'INDEPENDENT': 'إندبندنت',
    'EMILIA': 'إميليا', 'DIAGONAL': 'دياجونال', 'GOLF': 'جولف',
    'CARO': 'كارو', 'VITRIUM': 'فيتريوم', 'KETHO': 'كيثو',
    'STARCK 1': 'شتارك 1', 'OTHERS': 'متنوع',
    'SAN REMO SPECIAL NEEDS': 'سان ريمو احتياجات خاصة',
    'ACCESSORIES': 'إكسسوارات', 'IOM': 'آيوم',
}

# Top Arabic letters by frequency (MUST have at least 1 for a valid name)
TOP_ARABIC = set('ا لم ي ن ر ب و ف أ ك هـ ة')

# Secondary acceptable letters in product names
SECONDARY = set('ت ث ج ح خ د ذ ز س ش ص ض ع غ ق ي ء ى ئ ؤ')

def name_is_garbage(name):
    """Check if a name is corrupted/missing."""
    # Dimension-only (no letters)
    if re.match(r'^[\d\sxXسممم.]+\s*$', name):
        return True
    # Has Arabic but none of the top Arabic letters
    has_arabic = bool(re.search(r'[\u0600-\u06FF]', name))
    has_top = any(c in TOP_ARABIC for c in name)
    if has_arabic and not has_top:
        return True
    # Very short (< 3 chars, no real info)
    if len(name.strip()) <= 2:
        return True
    return False

updates = []
for p in products:
    if name_is_garbage(p['name']):
        sid = p['subcategory_id']
        sc_name = subcats.get(sid, '')
        sc_arabic = SERIES_ARABIC.get(sc_name, sc_name)
        clean_name = f'قطعة {sc_arabic}'
        safe = clean_name.replace("'", "''")
        updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")

print(f"Garbled to fix: {len(updates)}", flush=True)

if updates:
    sql = '\n'.join(updates)
    sql_path = r'C:\eg-co-erp\fix_garbled_v3.sql'
    with open(sql_path, 'w', encoding='utf-8') as f:
        f.write(sql)
    subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/fix_garbled_v3.sql'], capture_output=True)
    r2 = subprocess.run(
        ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/fix_garbled_v3.sql'],
        capture_output=True, text=True, encoding='utf-8', errors='replace'
    )
    print(f"Errors: {r2.stderr.count('ERROR') if r2.stderr else 0}", flush=True)

# Verify: dump clean product names to text file
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A',
     '-c', "SELECT name FROM products WHERE company = 'ايديال' ORDER BY random() LIMIT 30"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

# Write to file (bypass PowerShell display issues)
with open('C:\\eg-co-erp\\final_names_sample.txt', 'w', encoding='utf-8') as f:
    f.write("=== ايديال SAMPLES ===\n")
    f.write(r3.stdout)
    f.write("\n")

# Also check how many still have English
r4 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A',
     '-c', "SELECT name FROM products WHERE company IN ('ايديال', 'دروفيت') AND name ~ '[A-Za-z]{2,}' LIMIT 5"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
f = open('C:\\eg-co-erp\\final_names_sample.txt', 'a', encoding='utf-8')
f.write("=== STILL WITH ENGLISH ===\n")
f.write(r4.stdout)
f.write("\n")

# Count with top Arabic
r5 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A',
     '-c', "SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت') AND position(chr(0x0627) in name) > 0"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
f.write(f"Products with 'alif' (ا): {r5.stdout.strip()}\n")

# Count total
r6 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A',
     '-c', "SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت')"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
f.write(f"Total: {r6.stdout.strip()}\n")
f.close()

print("DONE - results written to C:\\eg-co-erp\\final_names_sample.txt", flush=True)
