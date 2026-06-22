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

# Map subcategory_id to name via products table
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

# Series name translations
SERIES_ARABIC = {
    'TONIC': 'تونيك',
    'KIMERA': 'كيميرا', 
    'PROSYS': 'بروسيس',
    'HAPPY D.': 'هابي دي',
    'D-CODE': 'دي كود',
    'SPACE': 'سبيس',
    'CONNECT': 'كونكت',
    'X-LARGE': 'إكس لارج',
    'SEPARATES': 'سيبريتس',
    'D-NEO': 'دي نيو',
    'DURASTYLE': 'ديورا ستايل',
    'VERO': 'فيرو',
    'SAN REMO': 'سان ريمو',
    'PLAYA': 'بلايا',
    'MANTA': 'مانتا',
    'TESI': 'تيسي',
    'STARCK 3': 'شتارك 3',
    'DARLING': 'دارلينج',
    'L-CUBE': 'إل كيوب',
    'PLAN': 'بلان',
    'P3 COMFORTS': 'بي 3 كومفورت',
    'DURAPLUS': 'ديورا بلس',
    'NEW ESEDRA': 'نيو إيسيدرا',
    'NEW CAPRI': 'نيو كابري',
    'PURAVIDA': 'بيورا فيدا',
    'SOPHIA': 'صوفيا',
    'IOM ACCESSORIES': 'إكسسوار أيوم',
    'ECHO': 'إيكو',
    'I.LIFE': 'آي لايف',
    'STUDIO ACCESSORIES': 'إكسسوار ستوديو',
    'INDEPENDENT': 'إندبندنت',
    'EMILIA': 'إميليا',
    'DIAGONAL': 'دياجونال',
    'GOLF': 'جولف',
    'CARO': 'كارو',
    'VITRIUM': 'فيتريوم',
    'KETHO': 'كيثو',
    'STARCK 1': 'شتارك 1',
    'OTHERS': 'متنوع',
    'STARCK 3': 'شتارك 3',
    'SAN REMO SPECIAL NEEDS': 'سان ريمو احتياجات خاصة',
    'ACCESSORIES': 'إكسسوارات',
    'IOM': 'آيوم',
}

def has_garbled_arabic(s):
    """Check for non-standard Arabic chars (likely from encoding corruption)."""
    for ch in s:
        o = ord(ch)
        if 0x0600 <= o <= 0x06FF:
            # Allow only standard Arabic letters
            if not (
                (0x0621 <= o <= 0x064A) or  # Standard Arabic letters
                (0x0660 <= o <= 0x0669) or  # Arabic-Indic digits
                o in (0x060C, 0x061F) or    # Commas, question
                o in (0x064B, 0x064C, 0x064D, 0x064E, 0x064F, 0x0650, 0x0651, 0x0652)  # Diacritics
            ):
                return True
    return False

def name_is_garbage(s):
    """Check if name is mostly corrupted or useless."""
    # Check for dimension-only names
    if re.match(r'^\d+[xX]\d+', s):
        return True
    # Check for extremely short names (1-2 chars, non-letter)
    if len(s.strip()) <= 2 and not re.search(r'[\u0621-\u064A]', s):
        return True
    return False

updates = []

for p in products:
    name = p['name']
    sid = p['subcategory_id']
    sc_name = subcats.get(sid, '')
    
    needs_fix = has_garbled_arabic(name) or name_is_garbage(name)
    if not needs_fix:
        continue
    
    # Generate clean name based on subcategory
    sc_arabic = SERIES_ARABIC.get(sc_name, sc_name)
    
    # Generate proper name
    clean_name = f'قطعة {sc_arabic}'
    
    safe = clean_name.replace("'", "''")
    updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")

print(f"Updates needed: {len(updates)}", flush=True)

# Also handle dimension-only names (from the full set)
dims = [p for p in products if re.match(r'^\d+[xX]\d+', p['name'])]
print(f"Dimension-only names: {len(dims)}", flush=True)

# Add dim updates if not already covered
for p in dims:
    sid = p['subcategory_id']
    sc_name = subcats.get(sid, '')
    sc_arabic = SERIES_ARABIC.get(sc_name, sc_name)
    clean_name = f'قطعة {sc_arabic}'
    
    already = any(f"'{p['id']}'" in u for u in updates)
    if not already:
        safe = clean_name.replace("'", "''")
        updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")

print(f"Total updates: {len(updates)}", flush=True)

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\fix_garbled_final.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/fix_garbled_final.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/fix_garbled_final.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Errors: {r2.stderr.count('ERROR') if r2.stderr else 0}", flush=True)

# Verify
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-c', "SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت') AND name ~ '[' || chr(0x0627) || '-' || chr(0x064A) || ']{2,}'"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Clean Arabic entries: {r3.stdout.strip()}", flush=True)

# Count remaining issues
r4 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت')"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Total products: {r4.stdout.strip()}", flush=True)
