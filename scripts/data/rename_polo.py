import subprocess, re
from collections import Counter

r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F|', '-c',
     "SELECT p.id, p.name, p.size, p.retail_price, s.name as subcat FROM products p JOIN subcategories s ON p.subcategory_id = s.id WHERE p.company = 'بولو' ORDER BY p.name, p.size, s.name"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

lines = [l for l in r.stdout.strip().split('\n') if l.strip()]
rows = []
for line in lines:
    parts = line.split('|')
    if len(parts) >= 5:
        rows.append({
            'id': parts[0].strip(),
            'name': parts[1].strip(),
            'size': parts[2].strip(),
            'price': parts[3].strip(),
            'subcat': parts[4].strip()
        })

ns_counts = Counter((r['name'], r['size']) for r in rows)
nss_counts = Counter((r['name'], r['size'], r['subcat']) for r in rows)

updates = []
for row in rows:
    key = (row['name'], row['size'])
    key_sub = (row['name'], row['size'], row['subcat'])
    if ns_counts[key] <= 1:
        new_name = f"{row['name']} ({row['size']})" if row['size'] else row['name']
    elif nss_counts[key_sub] <= 1:
        new_name = f"{row['name']} ({row['size']}) [{row['subcat']}]"
    else:
        new_name = f"{row['name']} ({row['size']}) [{row['subcat']}] {row['price']} EGP"
    new_name = new_name.replace("'", "''")
    updates.append(f"UPDATE products SET name = E'{new_name}' WHERE id = '{row['id']}';")

print(f'Generated {len(updates)} updates')

sql_path = r'C:\eg-co-erp\rename_polo.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(updates))

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/rename_polo.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-f', '/tmp/rename_polo.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
errors = r2.stderr.count('ERROR') if r2.stderr else 0
print(f'Errors: {errors}')
if errors > 0:
    for l in r2.stderr.split('\n')[:15]:
        if 'ERROR' in l:
            print(f'  {l[:200]}')

# Verify - show all products
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT name FROM products WHERE company = 'بولو' ORDER BY name;"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(r3.stdout)

# Check for duplicates
r4 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-c', "SELECT name, count(*) FROM products WHERE company = 'بولو' GROUP BY name HAVING count(*) > 1;"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
dups = [l for l in r4.stdout.strip().split('\n') if l.strip()]
print(f'Remaining duplicates: {len(dups)}')
for d in dups:
    print(f'  {d}')
