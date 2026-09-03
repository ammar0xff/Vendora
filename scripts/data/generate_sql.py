import sys, openpyxl, re
from decimal import Decimal
sys.stdout.reconfigure(encoding='utf-8')

lines = []
def sql(s): lines.append(s)
esc = lambda v: 'NULL' if v is None else "'" + str(v).replace("'", "''") + "'"

sql("""
-- ===== Product Import Script =====
INSERT INTO categories (id, name) VALUES (gen_random_uuid(), 'الشريف') ON CONFLICT (name) DO NOTHING;
INSERT INTO categories (id, name) VALUES (gen_random_uuid(), 'ايجيك') ON CONFLICT (name) DO NOTHING;
""")

# Known Arabic product-type keywords (priority ordered)
PRODUCT_TYPES = [
    'مواسير', 'كوع', 'مشترك', 'تي', 'وصلة', 'مسلوب', 'جلبة', 'طبة',
    'صفاية', 'محبس', 'بردة', 'بيبة', 'غطاء', 'علاية', 'سيفون',
    'غراء', 'ياردة', 'هواية', 'غرفة', 'واي', 'صليبة', 'بوش',
    'بطارية', 'قفيز', 'مجمع', 'طلمبة', 'جاليتراب', 'خزان',
    'مانع', 'عازل', 'مخرج', 'حاجز', 'جسم', 'وش', 'قاعدة',
    'برقع', 'جرجوري', 'باﻻكرة', 'فﻼنشة', 'مجرى', 'مائى', 'بيبه',
]
STOP_WORDS = {'مم', 'سم', 'متر', 'درجة', 'بوصة', 'أسود', 'اخضر',
              'بباب', 'قصير', 'بجوان', 'لحام', 'كيس', 'بسوكت',
              'داخلي', 'خارجي', 'طويل', 'عادي', 'معدن', 'بلاستيك',
              'بالغطاء', 'بغطاء'}

def normalize_arabic(s):
    """Remove tatweel (kashida) and normalize alif variants."""
    s = s.replace('\u0640', '')  # Remove tatweel
    return s

def get_subcategory(material_str):
    words = material_str.split()
    norm_words = [normalize_arabic(w) for w in words]
    # Find the first product-type keyword anywhere in each word (handles S-°45-"3/4-كوع etc.)
    for nw in norm_words:
        for pt in PRODUCT_TYPES:
            if pt in nw:
                return pt
    # Fallback: find any Arabic word that isn't a stop word
    arabic_words = [nw for nw in norm_words if re.search(r'[\u0600-\u06FF]', nw) and nw not in STOP_WORDS]
    if arabic_words:
        return arabic_words[0]
    # Last resort
    return 'أخرى'

# ===== الشريف =====
print("=== Processing الشريف ===")
path = r'C:\eg-co-erp\LISTS\الشريف.xlsx'
wb = openpyxl.load_workbook(path, data_only=True)
ws = wb['All_Products']

sharif_subs = set()
product_count = 0

for row in ws.iter_rows(min_row=2, values_only=True):
    system_type, category_name, product_name, size_val, thickness, price = row
    if not category_name or not product_name:
        continue
    cat_name = str(category_name).strip()
    if cat_name not in sharif_subs:
        sql(f"""INSERT INTO subcategories (id, category_id, name) SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'الشريف'), {esc(cat_name)} WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'الشريف') AND name = {esc(cat_name)});""")
        sharif_subs.add(cat_name)
    full_name = (str(system_type).strip() + ' - ' if system_type else '') + str(product_name).strip()
    if size_val:
        full_name += ' - ' + str(size_val).strip()
    if thickness:
        full_name += ' - سمك ' + str(thickness).strip()
    size_esc = esc(str(size_val).strip() if size_val else None)
    price_val = Decimal(str(price)) if price else Decimal('0')
    sql(f"""INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status) SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'الشريف') AND name = {esc(cat_name)}), {esc(full_name)}, 'عدد', {price_val}, 0, 0, true, {esc('الشريف')}, {size_esc}, 'untracked' WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = {esc(full_name)} AND company = {esc('الشريف')});""")
    product_count += 1

print(f"  {product_count} products, {len(sharif_subs)} subcategories")

# ===== ايجيك =====
print("=== Processing ايجيك ===")
path2 = r'C:\eg-co-erp\LISTS\ايجيك.xlsx'
wb2 = openpyxl.load_workbook(path2, data_only=True)
ws2 = wb2['Sheet1']

egy_subs = set()
product_count2 = 0
skipped = 0

for row in ws2.iter_rows(min_row=2, values_only=True):
    code, material, brand, price = row
    if not material:
        continue
    code_str = str(code).strip() if code else ''
    material_str = str(material).strip()
    material_str_with_code = material_str + (' [' + code_str + ']' if code_str else '')
    brand_str = str(brand).strip() if brand else ''
    if price is None:
        skipped += 1
        continue
    
    subcat_name = get_subcategory(material_str)
    
    if subcat_name not in egy_subs:
        sql(f"""INSERT INTO subcategories (id, category_id, name) SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايجيك'), {esc(subcat_name)} WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'ايجيك') AND name = {esc(subcat_name)});""")
        egy_subs.add(subcat_name)
    
    words = material_str.split()
    size_val = None
    for word in words:
        if any(c in word for c in 'م/"\\'):
            size_val = word
    if not size_val:
        for word in words:
            if any(c in word for c in '0123456789'):
                size_val = word
                break
    
    price_val = Decimal(str(price))
    sql(f"""INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, material, stock_status) SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'ايجيك') AND name = {esc(subcat_name)}), {esc(material_str_with_code)}, 'عدد', {price_val}, 0, 0, true, {esc('ايجيك')}, {esc(size_val)}, {esc(brand_str)}, 'untracked' WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = {esc(material_str_with_code)} AND company = {esc('ايجيك')});""")
    product_count2 += 1

print(f"  {product_count2} products, {len(egy_subs)} subcategories (skipped {skipped} no price)")
print(f"\nEgytec subcategories: {sorted(egy_subs)}")

sql("""
SELECT 'categories' AS tbl, count(*) FROM categories WHERE name IN ('الشريف','ايجيك')
UNION ALL SELECT 'subcategories', count(*) FROM subcategories s JOIN categories c ON s.category_id = c.id WHERE c.name IN ('الشريف','ايجيك')
UNION ALL SELECT 'products', count(*) FROM products p WHERE p.company IN ('الشريف','ايجيك');
""")

output_path = r'C:\eg-co-erp\import_products.sql'
with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print(f"\nSQL written to {output_path}")
