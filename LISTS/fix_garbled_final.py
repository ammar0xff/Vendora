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

# Common Arabic letters that should appear in valid product names
COMMON_ARABIC = set('ابتثجحخدذرزسشصضطظعغفقكلمنهويءةأؤإئ')

def is_garbled(name):
    """Check if a name is corrupted/unreadable."""
    # Has Arabic chars but NO common Arabic letters → garbled
    has_arabic = bool(re.search(r'[\u0600-\u06FF]', name))
    has_common = any(c in COMMON_ARABIC for c in name)
    if has_arabic and not has_common:
        return True
    # Dimension-only names
    if re.match(r'^\s*[\d\sxXسممم.]+\s*$', name) and not re.search(r'[\u0600-\u06FF]', name):
        return True
    # Very short garbage
    if len(name.strip()) <= 3 and not re.search(r'[\u0621-\u064A]', name):
        return True
    return False

updates = []
fixed_ids = set()

for p in products:
    if is_garbled(p['name']):
        sid = p['subcategory_id']
        sc_name = subcats.get(sid, '')
        sc_arabic = SERIES_ARABIC.get(sc_name, sc_name)
        clean_name = f'قطعة {sc_arabic}'
        
        safe = clean_name.replace("'", "''")
        updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")
        fixed_ids.add(p['id'])

print(f"Garbled names to fix: {len(updates)}", flush=True)

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\fix_garbled_final2.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/fix_garbled_final2.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/fix_garbled_final2.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
errors = r2.stderr.count('ERROR') if r2.stderr else 0
print(f"Errors: {errors}", flush=True)

# Verify
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT name FROM products WHERE company IN ('ايديال', 'دروفيت') ORDER BY random() LIMIT 20"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print("Samples:", flush=True)
print(r3.stdout)
print("DONE", flush=True)
