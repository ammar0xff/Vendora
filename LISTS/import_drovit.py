"""
Import Duravit/Drovit products into database.
"""
import subprocess
import pandas as pd

df = pd.read_excel(r'C:\eg-co-erp\LISTS\دروفيت.xlsx')
print(f"Products: {len(df)}")

CATEGORY = 'دروفيت'

sql_parts = []

# Category
sql_parts.append(f"INSERT INTO categories (id, name) SELECT gen_random_uuid(), '{CATEGORY}' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = '{CATEGORY}');")

# Subcategories
seen_subs = set()
for _, row in df.iterrows():
    subcat = str(row['category']).replace("'", "''")
    if subcat not in seen_subs:
        seen_subs.add(subcat)
        sql_parts.append(f"""
INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = '{CATEGORY}'), '{subcat}'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = '{subcat}' AND category_id = (SELECT id FROM categories WHERE name = '{CATEGORY}'));
""")

# Products
cnt = 0
for _, row in df.iterrows():
    subcat = str(row['category']).replace("'", "''")
    model = str(row['model']).replace("'", "''")
    desc = str(row['description']).replace("'", "''")[:80] if pd.notna(row['description']) else ''
    price = float(row['price']) if pd.notna(row['price']) else 0
    
    pname = f"{desc} [{model}]"[:200].replace("'", "''")
    
    sql_parts.append(f"""
INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = '{subcat}' AND category_id = (SELECT id FROM categories WHERE name = '{CATEGORY}')),
  '{pname}', 'قطعة', {price}, 0, 0, true, '{CATEGORY}', '{model}', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '{pname}' AND company = '{CATEGORY}');
""")
    cnt += 1

full_sql = '\n'.join(sql_parts)

sql_path = r'C:\eg-co-erp\import_drovit.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(full_sql)

print(f"Generated: {cnt} products, {len(seen_subs)} subcategories")

# Copy to Docker
subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/import_drovit.sql'], capture_output=True)

# Execute
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/import_drovit.sql'],
    capture_output=True, text=True
)

inserts = r.stdout.count('INSERT 0 1')
errors = r.stderr.count('ERROR')
print(f"DB result: {inserts} inserts, {errors} errors")
if errors:
    print(f"Errors: {r.stderr[-1000:]}")
