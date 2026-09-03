"""
Rewrite all product names in clean Arabic by pattern matching.
"""
import subprocess
import re

# Fetch all products
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '|||',
     '-c', "SELECT id, name, company FROM products WHERE company IN ('ايديال', 'دروفيت') ORDER BY company, name"],
    capture_output=True, text=True
)

lines = [l.strip() for l in r.stdout.strip().split('\n') if l.strip()]
print(f"Products: {len(lines)}")

def arabic_name(name, company):
    """Generate clean Arabic name from product data."""
    code = ''
    m = re.search(r'\[([A-Z0-9]+)\]', name)
    if m:
        code = m.group(1)
    
    n = name.replace(f'[{code}]', '').strip() if code else name
    
    # Common patterns
    
    # === WC / Bowls (مراحيض) ===
    if re.search(r'Bowl\s+P\b', n, re.I):
        t = 'مرحاض P'
        t += ' بدون دوش' if re.search(r'without douche', n, re.I) else (' بدوش' if re.search(r'with douche', n, re.I) else '')
        t += ' معلق' if re.search(r'wall.?hung|wall.?mount', n, re.I) else ''
        t += ' للحائط' if re.search(r'back to wall|close coupled', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    if re.search(r'Bowl\s+S\b', n, re.I):
        t = 'مرحاض S'
        t += ' بدون دوش' if re.search(r'without douche', n, re.I) else (' بدوش' if re.search(r'with douche', n, re.I) else '')
        t += ' معلق' if re.search(r'wall.?hung|wall.?mount', n, re.I) else ''
        t += ' للحائط' if re.search(r'back to wall|close coupled', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    if re.search(r'Bowl\b', n, re.I) and not re.search(r'Wash|Lava', n, re.I):
        t = 'مرحاض'
        t += ' معلق' if re.search(r'wall.?hung|wall.?mount', n, re.I) else ''
        t += ' بدون دوش' if re.search(r'without douche|w/out douche', n, re.I) else (' بدوش' if re.search(r'with douche', n, re.I) else '')
        return f"{t} {code}" if code else t
    
    # Mini Bowl
    if re.search(r'Mini Bowl', n, re.I):
        t = 'مرحاض ميني'
        t += ' بدون دوش' if re.search(r'without douche|w/out douche', n, re.I) else (' بدوش' if re.search(r'with douche', n, re.I) else '')
        return f"{t} {code}" if code else t
    
    # === Bidets (بيديه) ===
    if re.search(r'Bidet', n, re.I):
        t = 'بيديه'
        t += ' معلق' if re.search(r'wall.?hung', n, re.I) else ''
        t += ' بدون دوش' if re.search(r'without douche|w/out', n, re.I) else (' بدوش' if re.search(r'with douche', n, re.I) else '')
        t += ' فتحة واحدة' if re.search(r'single.?hole', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    # === Lavatory / Basin (أحواض) ===
    if re.search(r'Lavatory|Lava\b', n, re.I):
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m:
            sz = f" {m.group(1)} سم"
        t = f"حوض{sz}"
        return f"{t} {code}" if code else t
    
    if re.search(r'Wash\s*Bowl|Washbasin', n, re.I):
        sz = ''
        m = re.search(r'(\d+)\s*cm|(\d+)x(\d+)', n)
        if m:
            sz = f" {m.group(1) or m.group(0)} سم" if m.group(1) else ''
        t = f"حوض{sz}"
        t += ' كونترتوب' if re.search(r'Counter.?[Tt]op|countertop', n, re.I) else ''
        t += ' تحت سطح' if re.search(r'Under Counter|under.?counter', n, re.I) else ''
        t += ' جيست' if re.search(r'Guest\b', n, re.I) else ''
        t += ' فوق سطح' if re.search(r'Vessel', n, re.I) else ''
        t += ' معلق' if re.search(r'wall.?hung|wall.?mount|pedestal', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    if re.search(r'Hand\s*Wash', n, re.I):
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m:
            sz = f" {m.group(1)} سم"
        t = f"حوض أيدين{sz}"
        return f"{t} {code}" if code else t
    
    # === Pedestals (أعمدة) ===
    if re.search(r'Pedestal', n, re.I):
        t = 'عامود'
        t += ' أرضي' if re.search(r'Floor\b|Large\b', n, re.I) else ''
        t += ' حوض معلق' if re.search(r'Wall\b', n, re.I) else ''
        if re.search(r'Semi', n, re.I):
            t = 'نصف عامود'
        if re.search(r'Small\b', n, re.I):
            t = 'عامود صغير'
        return f"{t} {code}" if code else t
    
    # === Cistern / Tank (خزانات) ===
    if re.search(r'Tank|Cistern', n, re.I):
        t = 'خزان'
        t += ' وطقم' if re.search(r'Trim', n, re.I) else ''
        t += ' ضغط مزدوج' if re.search(r'Dual\s*[Ff]lush', n, re.I) else ''
        m = re.search(r'4\.5/3', n)
        t += ' 4.5/3 لتر' if m else ''
        return f"{t} {code}" if code else t
    
    # === Seats & Covers (سيديلية) ===
    if re.search(r'Seat\b', n, re.I) and re.search(r'Cover', n, re.I):
        t = 'سيديلي وغطاء'
        t += ' ذاتي الغلق' if re.search(r'Soft\s*Close', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    if re.search(r'Seat\b', n, re.I) and not re.search(r'Cover', n, re.I):
        t = 'سيديلي'
        t += ' ذاتي الغلق' if re.search(r'Soft\s*Close', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    # === Furniture (موبيليا) ===
    # Detect series name for furniture
    series = ''
    for s in ['TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'NEW CAPRI',
               'KIMERA', 'NEW ESEDRA', 'PLAYA', 'I.LIFE', 'INDEPENDENT',
               'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'STUDIO', 'IOM',
               'HAPPY D', 'DURASTYLE', 'DARLING', 'VERO', 'P3 COMFORTS',
               'D-NEO', 'L-CUBE', 'KETHO', 'CARO', 'X-LARGE', 'D-CODE',
               'PURAVIDA', 'DURAVIT NO. 1', 'VITRIUM', 'GOLF', 'EMILIA',
               'ECHO', 'DURAPLUS']:
        if s.lower() in n.lower():
            series = s
            break
    
    if re.search(r'Furniture', n, re.I) or re.search(r'Vanity', n, re.I):
        t = 'وحدة موبيليا'
        if series:
            t = f'موبيليا {series}'
        t += ' أرضي' if re.search(r'floor.?standing|floor', n, re.I) else ''
        t += ' معلقة' if re.search(r'wall.?mount|wall.?hung', n, re.I) else ''
        m = re.search(r'(\d+)\s*drawe', n, re.I)
        t += f' {m.group(1)} درج' if m else ''
        m = re.search(r'(\d+)\s*door', n, re.I)
        t += f' {m.group(1)} باب' if m else ''
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m:
            sz = f" {m.group(1)} سم"
        t += sz
        color = ''
        for c in ['Grey', 'Walnut', 'White', 'Black', 'Oak']:
            if c.lower() in n.lower():
                color = f' {c}'
                break
        t += color
        return f"{t} {code}" if code else t
    
    # === Furniture Unit (وحدات) ===
    if re.search(r'unit\b', n, re.I) and not re.search(r'Vanity|Bath|Shower', n, re.I):
        t = 'وحدة'
        if series:
            t = f'وحدة {series}'
        m = re.search(r'(\d+)\s*drawer', n, re.I)
        t += f' {m.group(1)} درج' if m else ''
        m = re.search(r'(\d+)\s*door', n, re.I)
        t += f' {m.group(1)} باب' if m else ''
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m:
            sz = f" {m.group(1)} سم"
        t += sz
        if 'tall' in n.lower():
            t = f'وحدة عالية {sz}'
        return f"{t} {code}" if code else t
    
    # === Bath Tubs (بانيو) ===
    if re.search(r'Bath\b', n, re.I) and not re.search(r'Shower|Enclosure|Screen|Panel', n, re.I):
        sz = ''
        m = re.search(r'(\d+x\d+)', n)
        if m:
            sz = f' {m.group(1)}'
        t = f'بانيو{sz}'
        if re.search(r'Whirlpool', n, re.I):
            t += ' جاكوزي'
        return f"{t} {code}" if code else t
    
    # === Shower Enclosures (كابينات دش) ===
    if re.search(r'Bath\s*[Ee]nclosure|Shower\s*[Ee]nclosure|Bathscreen', n, re.I):
        t = 'كابينة بانيو'
        t += ' قابلة للطي' if re.search(r'Folding', n, re.I) else ''
        t += ' منزلقة' if re.search(r'Sliding', n, re.I) else ''
        t += ' محورية' if re.search(r'Pivot', n, re.I) else ''
        t += ' ركنية' if re.search(r'Corner|Pentagon', n, re.I) else ''
        return f"{t} {code}" if code else t
    
    if re.search(r'Shower\s*[Tt]ray|Shower\s*[Bb]ase', n, re.I):
        t = 'صينية دش'
        t += ' ركنية' if re.search(r'Corner|Pentagon|Quadrant', n, re.I) else ''
        sz = ''
        m = re.search(r'(\d+x\d+)', n)
        if m:
            sz = f' {m.group(1)}'
        t += sz
        return f"{t} {code}" if code else t
    
    if re.search(r'Panel\b', n, re.I) and not re.search(r'Control|Push|bracket', n, re.I):
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m:
            sz = f" {m.group(1)} سم"
        t = f'بانيلي جانبي{sz}'
        return f"{t} {code}" if code else t
    
    # === Mixers / Taps (خلاطات / حنفيات) ===
    if re.search(r'Mixe|Tap\b|Fauce', n, re.I):
        t = 'خلاط'
        t += ' حوض' if re.search(r'basin|lavatory|lava|sink', n, re.I) else ''
        t += ' بانيو' if re.search(r'bath|shower', n, re.I) else ''
        t += ' مطبخ' if re.search(r'sink|kitchen', n, re.I) else ''
        t += ' دش' if re.search(r'shower|handspray', n, re.I) else ''
        t += ' حائط' if re.search(r'wall|deck', n, re.I) else ''
        t += ' عالي' if re.search(r'high.?spout', n, re.I) else ''
        if not re.search(r'basin|bath|shower|sink|kitchen|wall|deck', n, re.I):
            t = 'خلاط مياه'
        return f"{t} {code}" if code else t
    
    # === Shower Sets (طقم دش) ===
    if re.search(r'Shower\s*(set|kit|system)', n, re.I):
        t = 'طقم دش'
        return f"{t} {code}" if code else t
    
    # === Spray / Handspray (دش يدوي) ===
    if re.search(r'Handspray|hand.?spray', n, re.I):
        t = 'دش يدوي'
        return f"{t} {code}" if code else t
    
    # === Connecting bend (جلبة توصيل) ===
    if re.search(r'connecting\s*bend', n, re.I):
        t = 'جلبة توصيل'
        return f"{t} {code}" if code else t
    
    # === Chair Support (حامل مقعد) ===
    if re.search(r'Chair.?Support', n, re.I):
        t = 'حامل مقعد'
        return f"{t} {code}" if code else t
    
    # === Shower Columns / Systems ===
    if re.search(r'Shower\s*[Cc]olumn', n, re.I):
        t = 'عمود دش'
        return f"{t} {code}" if code else t
    
    # === Whirlpool / Spa ===
    if re.search(r'Spa\b', n, re.I) and not re.search(r'Mini', n, re.I):
        t = 'سبا'
        sz = ''
        m = re.search(r'(\d+x\s*\d+)', n)
        if m:
            sz = f' {m.group(1)}'
        t += sz
        return f"{t} {code}" if code else t
    
    if re.search(r'Mini.?Spa', n, re.I):
        t = 'ميني سبا'
        return f"{t} {code}" if code else t
    
    # === Duravit products by model (most are dimensions) ===
    if company == 'دروفيت' and code:
        # Check if name has a recognizable product type
        if re.search(r'Vanity|washbasin|wash bowl|washbowl|basin', n, re.I):
            return f'حوض دروفيت {code}'
        if re.search(r'Toilet|bowl|WC', n, re.I):
            return f'مرحاض دروفيت {code}'
        if re.search(r'Cistern|tank', n, re.I):
            return f'خزان دروفيت {code}'
        if re.search(r'Seat', n, re.I):
            return f'سيديلي دروفيت {code}'
        if re.search(r'Bidet', n, re.I):
            return f'بيديه دروفيت {code}'
        if re.search(r'Furniture|unit|drawer', n, re.I):
            return f'وحدة دروفيت {code}'
        if re.search(r'accessor', n, re.I):
            return f'إكسسوار دروفيت {code}'
        # Generic: use series name + code
        if series:
            return f'{series} {code}'
        return f'قطعة دروفيت {code}'
    
    # Fallback for ideal: keep code but add generic prefix
    if company == 'ايديال' and code:
        if series:
            return f'{series} {code}'
        return f'قطعة ايديال {code}'
    
    return n  # keep original if nothing matched

# Generate SQL updates
updates = []
for line in lines:
    parts = line.split('|||')
    if len(parts) >= 3:
        pid = parts[0].strip()
        old_name = parts[1].strip()
        company = parts[2].strip()
        
        new_name = arabic_name(old_name, company)
        if new_name != old_name and new_name.strip():
            safe = new_name.replace("'", "''")
            updates.append(f"UPDATE products SET name = E'{safe}' WHERE id = '{pid}';")

print(f"Updates: {len(updates)}")

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\translate_v2.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/translate_v2.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/translate_v2.sql'],
    capture_output=True, text=True
)

errors = r2.stderr.count('ERROR')
print(f"DB done, {errors} errors")

r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT name FROM products WHERE company = 'ايديال' AND length(name) < 80 ORDER BY random() LIMIT 12"],
    capture_output=True, text=True
)
print(r3.stdout)

r4 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT name FROM products WHERE company = 'دروفيت' AND length(name) < 80 ORDER BY random() LIMIT 6"],
    capture_output=True, text=True
)
print("دروفيت samples:")
print(r4.stdout)
