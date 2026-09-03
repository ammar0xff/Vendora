import subprocess
import re
import json
import sys

# Redirect stdout to UTF-8 file
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# Dump products to JSON via docker psql
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '\t',
     '-c', "SELECT row_to_json(t)::text FROM (SELECT id, name, company, subcategory_id FROM products WHERE company IN ('ايديال', 'دروفيت')) t"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

raw = r.stdout.strip()
products = []
for line in raw.split('\n'):
    line = line.strip()
    if line.startswith('{') and line.endswith('}'):
        try:
            p = json.loads(line)
            products.append(p)
        except:
            pass

print(f"Loaded: {len(products)}", flush=True)
ideal_count = len([p for p in products if p.get('company') == 'ايديال'])
drovit_count = len([p for p in products if p.get('company') == 'دروفيت'])
print(f"Ideal: {ideal_count}, Drovit: {drovit_count}", flush=True)

def detect_series(n):
    n_lower = n.lower()
    series_list = ['TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'CAPRI',
                   'KIMERA', 'ESEDRA', 'PLAYA', 'I.LIFE', 'ILIFE', 'INDEPENDENT',
                   'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'STUDIO', 'IOM',
                   'HAPPY D', 'DURASTYLE', 'DARLING', 'VERO', 'P3 COMFORTS',
                   'D-NEO', 'L-CUBE', 'KETHO', 'CARO', 'X-LARGE', 'D-CODE',
                   'PURAVIDA', 'VITRIUM', 'GOLF', 'EMILIA', 'ECHO',
                   'DURAPLUS', 'STARCK', 'SOLEA', 'FLORIDA', 'CONTOUR',
                   'NIAGRA', 'SUPER', 'COMBI', 'TURBO', 'PROSYS',
                   'VENICE', 'NEW CAPRI', 'NEW ESEDRA', 'CREDO', 'NEW SEMIRAMIS',
                   'SEMIRAMIS', 'ENTRY']
    for s in series_list:
        if s.lower() in n_lower:
            return s
    return None

def guess_type(n):
    """Identify product type from name."""
    n_lower = n.lower()
    n_clean = n_lower.replace('\xad', '')
    types = []
    
    # Must check more specific patterns first
    if re.search(r'bowl\s+s\b', n_clean):
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        t = 'مرحاض S' + sz
        if re.search(r'wall.?hung|wall.?mount', n_clean): t += ' معلق'
        if re.search(r'without douche|w/out douche', n_clean): t += ' بدون دوش'
        if re.search(r'with douche', n_clean): t += ' بدوش'
        return t
    
    if re.search(r'bowl\s+p\b', n_clean):
        t = 'مرحاض P'
        if re.search(r'wall.?hung|wall.?mount', n_clean): t += ' معلق'
        if re.search(r'without douche|w/out douche', n_clean): t += ' بدون دوش'
        if re.search(r'with douche', n_clean): t += ' بدوش'
        return t
    
    if re.search(r'mini\s*bowl', n_clean):
        t = 'مرحاض ميني'
        if re.search(r'without douche|w/out douche', n_clean): t += ' بدون دوش'
        if re.search(r'with douche', n_clean): t += ' بدوش'
        return t
    
    if re.search(r'\bbowl\b', n_clean) and not re.search(r'wash\s*bowl|lava|washbasin|hand', n_clean):
        t = 'مرحاض'
        if re.search(r'wall.?hung|wall.?mount', n_clean): t += ' معلق'
        if re.search(r'close.?coupled|back.?to.?wall', n_clean): t += ' للحائط'
        if re.search(r'without douche|w/out douche', n_clean): t += ' بدون دوش'
        if re.search(r'with douche', n_clean): t += ' بدوش'
        return t
    
    if re.search(r'\bbidet\b', n_clean):
        t = 'بيديه'
        if re.search(r'without douche|w/out douche', n_clean): t += ' بدون دوش'
        if re.search(r'with douche', n_clean): t += ' بدوش'
        if re.search(r'wall.?hung', n_clean): t += ' معلق'
        if re.search(r'single.?hole', n_clean): t += ' فتحة واحدة'
        return t
    
    if re.search(r'seat\b', n_clean) and re.search(r'cover\b', n_clean):
        t = 'سيديلي وغطاء'
        if re.search(r'soft.?close', n_clean): t += ' ذاتي الغلق'
        return t
    
    if re.search(r'seat\b', n_clean):
        t = 'سيديلي'
        if re.search(r'soft.?close', n_clean): t += ' ذاتي الغلق'
        return t
    
    if re.search(r'\btank\b|\bcistern\b', n_clean):
        t = 'خزان'
        if re.search(r'dual.?flush|dualflush', n_clean): t += ' - ضغط مزدوج'
        if re.search(r'4[.,]5/3', n_clean): t += ' 4.5/3 لتر'
        if re.search(r'trim', n_clean) or re.search(r'with trim', n_clean): t += ' وطقم'
        return t
    
    if re.search(r'pedestal\b', n_clean):
        t = 'عامود'
        if re.search(r'floor|large', n_clean): t = 'عامود أرضي'
        if re.search(r'semi', n_clean): t = 'نصف عامود'
        if re.search(r'wall', n_clean): t = 'عامود معلق'
        if re.search(r'small', n_clean): t = 'عامود صغير'
        return t
    
    if re.search(r'connecting.?bend', n_clean):
        return 'جلبة توصيل'
    
    if re.search(r'chair.?suppor', n_clean):
        return 'حامل مقعد'
    
    if re.search(r'fixing.?set', n_clean):
        return 'طقم تثبيت'
    
    # Washbasin / Lavatory
    if re.search(r'lavatory|lava\b|wash\s*bowl|washbowl|washbasin|hand\s*wash|handwash', n_clean):
        t = 'حوض'
        if re.search(r'guest', n_clean): t = 'حوض ضيوف'
        if re.search(r'counter.?top|countertop', n_clean) and not re.search(r'semi', n_clean): t += ' كونترتوب'
        if re.search(r'above.?counter|abv\.?counter', n_clean): t += ' فوق سطح'
        if re.search(r'under.?counter|undercounter', n_clean): t += ' تحت سطح'
        if re.search(r'semi.?counter|semicounter', n_clean): t += ' نصف كونترتوب'
        if re.search(r'vessel', n_clean): t += ' فوق سطح'
        if re.search(r'pedestal', n_clean): t += ' مع عامود'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        m = re.search(r'(\d+)[xX](\d+)', n_clean)
        if m: t += ' ' + m.group(1) + 'x' + m.group(2)
        return t
    
    # Mixer
    if re.search(r'mixer|tap|faucet', n_clean):
        t = 'خلاط'
        if re.search(r'basin|lava|sink|washbowl|hand|washbasin', n_clean): t += ' حوض'
        elif re.search(r'bath|shower', n_clean): t += ' بانيو'
        elif re.search(r'bidet', n_clean): t += ' بيديه'
        elif re.search(r'deck|wall', n_clean): t += ' حائط'
        if re.search(r'single.?hole', n_clean): t += ' فتحة واحدة'
        if re.search(r'high.?spout', n_clean): t += ' عالي'
        if re.search(r'pop.?up|popup', n_clean) or re.search(r'waste', n_clean): t += ' مع صرف'
        if re.search(r'without pop|w/o pop|without waste', n_clean): t += ' بدون صرف'
        return t
    
    # Handspray
    if re.search(r'hand.?spray', n_clean):
        return 'دش يدوي'
    
    # Shower column / system
    if re.search(r'shower.?column|shower.?system', n_clean):
        t = 'عمود دش'
        m = re.search(r'(\d+)\s*cm|(\d+)mm', n_clean)
        if m: t += ' ' + (m.group(1) or m.group(2))
        return t
    
    # Shower set
    if re.search(r'shower.?set', n_clean):
        return 'طقم دش'
    
    # Shower tray
    if re.search(r'shower.?tray|shower.?base', n_clean):
        t = 'صينية دش'
        if re.search(r'corner|pentagon|quadrant', n_clean): t += ' ركنية'
        if re.search(r'entry', n_clean): t += ' ENTRY'
        if re.search(r'quadrant', n_clean): t += ' كودرنت'
        sz = ''
        m = re.search(r'(\d+)[xX\s]*(\d+)', n_clean)
        if m: sz = ' ' + m.group(1) + 'x' + m.group(2)
        if not sz:
            m = re.search(r'(\d+)\s*cm', n_clean)
            if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Shower enclosure
    if re.search(r'shower.?enclosure|bath.?screen|bath.?enclosure|shower.?screen', n_clean):
        t = 'كابينة دش'
        if re.search(r'folding|fold', n_clean): t += ' قابلة للطي'
        if re.search(r'sliding|slide', n_clean): t += ' منزلقة'
        if re.search(r'pivot', n_clean): t += ' محورية'
        if re.search(r'corner|pentagon', n_clean): t += ' ركنية'
        if re.search(r'square', n_clean): t += ' مربعة'
        if re.search(r'entry', n_clean): t += ' ENTRY'
        sz = ''
        m = re.search(r'(\d+)[xX]\s*(\d+)', n_clean)
        if m: sz = ' ' + m.group(1) + 'x' + m.group(2)
        m2 = re.search(r'(\d+)\s*cm', n_clean)
        if m2 and not sz: sz = ' ' + m2.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Panel (bath panel)
    if re.search(r'\bpanel\b', n_clean) and not re.search(r'control|push|bracket', n_clean):
        t = 'بانيلي'
        if re.search(r'side', n_clean): t = 'بانيلي جانبي'
        if re.search(r'front', n_clean): t = 'بانيلي أمامي'
        if re.search(r'end|short', n_clean): t = 'بانيلي طرفي'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Bath tub
    if re.search(r'\bbath\b', n_clean) and not re.search(r'enclosure|screen|panel|shower', n_clean):
        t = 'بانيو'
        if re.search(r'whirlpool|whir', n_clean): t += ' جاكوزي'
        if re.search(r'spa|mini.?spa', n_clean): t += ' سبا'
        sz = ''
        m = re.search(r'(\d+)[xX]\s*(\d+)', n_clean)
        if m: sz = ' ' + m.group(1) + 'x' + m.group(2)
        if sz: t += sz
        return t
    
    # Furniture
    if re.search(r'furniture|console|vanity', n_clean):
        t = 'موبيليا'
        series = detect_series(n_clean)
        if series and series not in t: t = f'موبيليا {series}'
        if re.search(r'drawer', n_clean): t += ' بأدراج'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Unit
    if re.search(r'\bunit\b', n_clean):
        t = 'وحدة'
        series = detect_series(n_clean)
        if series: t = f'وحدة {series}'
        if re.search(r'tall', n_clean): t += ' عالية'
        if re.search(r'drawer', n_clean) and not re.search(r'drawers', n_clean): t += ' درج واحد'
        if re.search(r'2\s*drawer|two\s*drawer', n_clean): t += ' درجين'
        if re.search(r'3\s*drawer|three\s*drawer', n_clean): t += ' 3 أدراج'
        if re.search(r'4\s*drawer|four\s*drawer', n_clean): t += ' 4 أدراج'
        if re.search(r'drawers', n_clean) and not re.search(r'\d+', n_clean): t += ' بأدراج'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Mirror
    if re.search(r'mirror', n_clean):
        t = 'مراية'
        series = detect_series(n_clean)
        if series: t = f'مراية {series}'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_clean)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        return t
    
    # Shelf
    if re.search(r'shelf', n_clean):
        t = 'رف'
        series = detect_series(n_clean)
        if series: t = f'رف {series}'
        return t
    
    # Wall hung WC frame / support
    if re.search(r'support|frame|bracket', n_clean):
        t = 'حامل'
        return t
    
    # Accessories
    if re.search(r'accessor', n_clean):
        t = 'إكسسوار'
        series = detect_series(n_clean)
        if series: t = f'إكسسوار {series}'
        return t
    
    # Duravit - by series name
    if re.search(r'starck|happy\s*d|durastyle|darling|vero|ketho|caro|puravida|vitrium|golf', n_clean):
        series = detect_series(n_clean)
        if series: return series
    
    # Combi systems (Ideal Standard showers/system)
    if re.search(r'combi', n_clean):
        t = 'نظام كومبي'
        m = re.search(r'(\d+)', n_clean)
        if m: t += ' ' + m.group(1)
        return t
    
    return None

def clean_name(name, company):
    code = ''
    m = re.search(r'\[([A-Z0-9]+)\]', name)
    if m: code = m.group(1)
    
    n = name
    if code:
        n = name.replace(f'[{code}]', '').strip()
    
    # Remove soft hyphen and garbage
    n = n.replace('\xad', '').replace('\u200b', '').replace('\ufeff', '')
    
    guessed = guess_type(n)
    
    if guessed:
        t = guessed
        series = detect_series(n)
        if series and series not in t and 'موبيليا' not in t and 'وحدة' not in t:
            t = f'{series} {t}'
        if code:
            t += f' [{code}]'
        return t
    
    # Fallback by series
    series = detect_series(n)
    if series:
        t = series
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m: sz = ' ' + m.group(1) + ' سم'
        if sz: t += sz
        if code: t += f' [{code}]'
        return t
    
    # Fallback by code
    if code:
        if company == 'دروفيت':
            return f'دروفيت [{code}]'
        return f'ايديال [{code}]'
    
    # Last resort - clean garbage
    clean = re.sub(r'[^\w\s\-\[\]\.,\(\)/]', '', n).strip()
    if clean and len(clean) > 3:
        return clean
    return name

# Generate SQL updates
updates = []
total = 0
skipped = 0
for p in products:
    new_name = clean_name(p['name'], p['company'])
    if new_name != p['name']:
        safe = new_name.replace("'", "''")
        updates.append(f"UPDATE products SET name = E'{safe}' WHERE id = '{p['id']}';")
        total += 1
    else:
        skipped += 1

print(f"Updates: {total}, Skipped: {skipped}", flush=True)

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\translate_v3.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

# Copy and execute
subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/translate_v3.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/translate_v3.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
errors = r2.stderr.count('ERROR') if r2.stderr else 0
print(f"DB result: stderr_len={len(r2.stderr or '')}, stdout_len={len(r2.stdout or '')}", flush=True)
if r2.stderr:
    print(f"First error: {r2.stderr[:200]}", flush=True)
print(f"Errors: {errors}", flush=True)
print("DONE", flush=True)
