"""
Generate import SQL for Ideal Standard products and import into Docker DB.
"""
import subprocess
import pandas as pd

df = pd.read_excel(r'C:\eg-co-erp\LISTS\ايديال.xlsx')
df = df[df['code'] != ''].copy()
print(f"Products with codes: {len(df)}")

CATEGORY = 'ايديال'

# Combine name = description (truncated) + code in name for uniqueness
def make_name(row):
    desc = str(row['description']).strip()
    code = str(row['code']).strip()
    # Truncate desc to avoid overly long names
    if len(desc) > 90:
        desc = desc[:90]
    return f"{desc} [{code}]"

df['product_name'] = df.apply(make_name, axis=1)

sql_parts = []

# 1. Category
sql_parts.append(f"INSERT INTO categories (id, name) SELECT gen_random_uuid(), '{CATEGORY}' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = '{CATEGORY}');")

# 2. Subcategories (distinct series)
series_list = sorted(df['series'].unique())
for s in series_list:
    sn = s.replace("'", "''")
    sql_parts.append(f"""
INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = '{CATEGORY}'), '{sn}'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = '{sn}' AND category_id = (SELECT id FROM categories WHERE name = '{CATEGORY}'));
""")

# 3. Products
cnt = 0
for _, row in df.iterrows():
    subcat = row['series'].replace("'", "''")
    pname = row['product_name'].replace("'", "''")
    price = float(row['white_price']) if pd.notna(row['white_price']) else 0
    weight = str(row['weight']) if pd.notna(row['weight']) else ''
    
    sql_parts.append(f"""
INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = '{subcat}' AND category_id = (SELECT id FROM categories WHERE name = '{CATEGORY}')),
  '{pname}', 'قطعة', {price}, 0, 0, true, '{CATEGORY}', '{weight}', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '{pname}' AND company = '{CATEGORY}');
""")
    cnt += 1

full_sql = '\n'.join(sql_parts)

sql_path = r'C:\eg-co-erp\import_ideal.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(full_sql)

print(f"Generated: {cnt} products, {len(series_list)} subcategories")

# Copy to Docker
subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/import_ideal.sql'], capture_output=True)

# Execute
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/import_ideal.sql'],
    capture_output=True, text=True
)

# Print summary
inserts = r.stdout.count('INSERT 0 1')
errors = r.stderr.count('ERROR')
print(f"DB result: {inserts} inserts, {errors} errors")
if errors:
    print(f"Errors: {r.stderr[-1000:]}")
