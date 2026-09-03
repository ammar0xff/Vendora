import subprocess
import re
import json

# Fetch products
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

print(f"Loaded: {len(products)}", flush=True)

def code_from_name(name):
    m = re.search(r'\[([A-Z0-9]+)\]', name)
    return m.group(1) if m else ''

def series_from_name(name):
    n = name.lower()
    for s in ['TONIC', 'KIMERA', 'PROSYS', 'HAPPY D', 'SPACE', 'CONNECT',
              'D-CODE', 'X-LARGE', 'SEPARATES', 'D-NEO', 'DURASTYLE', 'VERO',
              'SAN REMO', 'PLAYA', 'MANTA', 'TESI', 'STARCK', 'DARLING',
              'L-CUBE', 'PLAN', 'P3 COMFORTS', 'DURAPLUS', 'NEW ESEDRA',
              'NEW CAPRI', 'PURAVIDA', 'SOPHIA', 'IOM', 'ECHO', 'I.LIFE',
              'STUDIO', 'INDEPENDENT', 'EMILIA', 'DIAGONAL', 'GOLF', 'CARO',
              'VITRIUM', 'KETHO', 'CREDO', 'NEW SEMIRAMIS', 'SEMIRAMIS',
              'ENTRY', 'VENICE', 'MEDIA', 'AQUA', 'STEP', 'DEA']:
        if s.lower() in n:
            return s
    return ''

def generate_clean(name, company):
    """Generate clean Arabic product name."""
    n = name.replace('\xad', '').replace('\u200b', '').replace('\ufeff', '')
    code = code_from_name(n)
    
    clean = n
    if code:
        clean = n.replace(f'[{code}]', '').strip()
    
    n_lower = clean.lower()
    series = series_from_name(n)
    
    # === WC / Toilets ===
    if re.search(r'\bbowl\b', n_lower) or re.search(r'مرحاض', n):
        t = 'مرحاض'
        if re.search(r'\bs\b', n_lower): t += ' S'
        elif re.search(r'\bp\b', n_lower): t += ' P'
        elif re.search(r'mini', n_lower): t = 'مرحاض ميني'
        if re.search(r'wall.?hung|wall.?mount', n_lower): t += ' معلق'
        if re.search(r'close.?coupled|back.?to.?wall', n_lower): t += ' للحائط'
        if re.search(r'without douche|w/out douche|بدون دوش', n_lower): t += ' بدون دوش'
        elif re.search(r'with douche|بدوش', n_lower): t += ' بدوش'
        if series: return f'{series} {t}' + (f' [{code}]' if code else '')
        return t + (f' [{code}]' if code else '')
    
    if re.search(r'\btoilet\b|\bwc\b', n_lower):
        t = 'مرحاض'
        if series: return f'{series} {t}' + (f' [{code}]' if code else '')
        return t + (f' [{code}]' if code else '')
    
    # === Bidets ===
    if re.search(r'bidet|بيديه', n_lower):
        t = 'بيديه'
        if re.search(r'without douche|w/out|بدون دوش', n_lower): t += ' بدون دوش'
        elif re.search(r'with douche|بدوش', n_lower): t += ' بدوش'
        if re.search(r'wall.?hung', n_lower): t += ' معلق'
        if re.search(r'single.?hole|فتحة', n_lower): t += ' فتحة واحدة'
        if series: return f'{series} {t}' + (f' [{code}]' if code else '')
        return t + (f' [{code}]' if code else '')
    
    # === Seats ===
    if re.search(r'\bseat\b', n_lower) and re.search(r'\bcover\b', n_lower):
        t = 'سيديلي وغطاء'
        if re.search(r'soft.?close', n_lower): t += ' ذاتي الغلق'
        return t + (f' [{code}]' if code else '')
    if re.search(r'\bseat\b', n_lower):
        t = 'سيديلي'
        if re.search(r'soft.?close', n_lower): t += ' ذاتي الغلق'
        return t + (f' [{code}]' if code else '')
    
    # === Basins ===
    if re.search(r'lavatory|lava\b|wash\s*bowl|washbowl|washbasin|hand\s*wash|handwash', n_lower):
        t = 'حوض'
        if re.search(r'guest', n_lower): t = 'حوض ضيوف'
        if re.search(r'counter.?top|above', n_lower): t += ' كونترتوب'
        elif re.search(r'under.?counter', n_lower): t += ' تحت سطح'
        elif re.search(r'semi.?counter', n_lower): t += ' نصف كونترتوب'
        elif re.search(r'vessel', n_lower): t += ' فوق سطح'
        if re.search(r'pedestal', n_lower): t += ' مع عامود'
        # Extract size
        sz = ''
        m = re.search(r'(\d+)\s*cm', n_lower)
        if m: sz = f' {m.group(1)} سم'
        m = re.search(r'(\d+)\s*x\s*(\d+)', n_lower)
        if m and not sz: sz = f' {m.group(1)}x{m.group(2)}'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    # === Mixers ===
    if re.search(r'mixer|tap|faucet|حنفية|خلاط', n_lower):
        t = 'خلاط'
        if re.search(r'basin|lava|sink|wash|handwash|حوض', n_lower): t += ' حوض'
        elif re.search(r'bath|بانيو', n_lower): t += ' بانيو'
        elif re.search(r'bidet|بيديه', n_lower): t += ' بيديه'
        elif re.search(r'deck|wall|حائط', n_lower): t += ' حائط'
        elif re.search(r'shower|دش', n_lower): t += ' دش'
        if re.search(r'single.?hole', n_lower): t += ' فتحة واحدة'
        if re.search(r'high.?spout', n_lower): t += ' عالي'
        if re.search(r'swivel', n_lower): t += ' سفلي'
        if re.search(r'pop.?up|popup|waste|صرف', n_lower) and not re.search(r'without.?pop|w/o.?pop|without.?waste', n_lower):
            t += ' مع صرف'
        return t + (f' [{code}]' if code else '')
    
    # === Tanks / Cisterns ===
    if re.search(r'\btank\b|\bcistern\b|خزان', n_lower):
        t = 'خزان'
        if re.search(r'trim|طقم', n_lower): t += ' وطقم'
        if re.search(r'dual.?flush|ضغط مزدوج', n_lower): t += ' - ضغط مزدوج'
        if re.search(r'4[.,]5/3', n_lower): t += ' 4.5/3 لتر'
        return t + (f' [{code}]' if code else '')
    
    # === Pedestals ===
    if re.search(r'pedestal|عامود', n_lower):
        t = 'عامود'
        if re.search(r'floor|large|أرضي', n_lower): t = 'عامود أرضي'
        elif re.search(r'semi|نصف', n_lower): t = 'نصف عامود'
        elif re.search(r'small|صغير', n_lower): t = 'عامود صغير'
        elif re.search(r'wall|معلق', n_lower): t = 'عامود معلق'
        return t + (f' [{code}]' if code else '')
    
    # === Shower Trays ===
    if re.search(r'shower.?tray|shower.?base|صينية دش|صينية', n_lower):
        t = 'صينية دش'
        if re.search(r'corner|pentagon|quadrant|ركنية', n_lower): t += ' ركنية'
        if re.search(r'entry', n_lower): t += ' ENTRY'
        sz = ''
        m = re.search(r'(\d+)\s*[xX×]\s*(\d+)', n)
        if m: sz = f' {m.group(1)}x{m.group(2)}'
        m = re.search(r'(\d+)\s*cm', n) if not sz else None
        if m: sz = f' {m.group(1)} سم'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    # === Shower Enclosures ===
    if re.search(r'enclosure|screen|كابينة', n_lower):
        t = 'كابينة دش'
        if re.search(r'folding|fold|طي', n_lower): t += ' قابلة للطي'
        elif re.search(r'sliding|slide|منزلقة', n_lower): t += ' منزلقة'
        elif re.search(r'pivot|محورية', n_lower): t += ' محورية'
        if re.search(r'corner|pentagon|ركنية', n_lower): t += ' ركنية'
        if re.search(r'square|مربعة', n_lower): t += ' مربعة'
        if re.search(r'entry', n_lower): t += ' ENTRY'
        sz = ''
        m = re.search(r'(\d+)\s*[xX×]\s*(\d+)', n)
        if m: sz = f' {m.group(1)}x{m.group(2)}'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    # === Panels ===
    if re.search(r'\bpanel\b|بانيلي', n_lower) and not re.search(r'control|push|bracket', n_lower):
        t = 'بانيلي'
        if re.search(r'side|جانبي', n_lower): t = 'بانيلي جانبي'
        elif re.search(r'front|أمامي', n_lower): t = 'بانيلي أمامي'
        elif re.search(r'end|طرفي', n_lower): t = 'بانيلي طرفي'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m: sz = f' {m.group(1)} سم'
        t += sz
        if series: return f'{series} {t}' + (f' [{code}]' if code else '')
        return t + (f' [{code}]' if code else '')
    
    # === Bath tubs ===
    if re.search(r'\bbath\b', n_lower) and not re.search(r'enclosure|screen|panel|shower', n_lower):
        t = 'بانيو'
        if re.search(r'whirlpool|whir', n_lower): t += ' جاكوزي'
        if re.search(r'spa|mini.?spa', n_lower): t += ' سبا'
        sz = ''
        m = re.search(r'(\d+)\s*[xX×]\s*(\d+)', n)
        if m: sz = f' {m.group(1)}x{m.group(2)}'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    # === Shower columns / Sets ===
    if re.search(r'shower.?column|عمود دش', n_lower):
        return f'عمود دش [{code}]' if code else 'عمود دش'
    if re.search(r'shower.?set|طقم دش', n_lower):
        return f'طقم دش [{code}]' if code else 'طقم دش'
    if re.search(r'hand.?spray|دش يدوي', n_lower):
        return f'دش يدوي [{code}]' if code else 'دش يدوي'
    
    # === Connecting bend / Chair support / Fixing set ===
    if re.search(r'connecting.?bend|جلبة', n_lower):
        return f'جلبة توصيل [{code}]' if code else 'جلبة توصيل'
    if re.search(r'chair.?support|حامل مقعد', n_lower):
        return f'حامل مقعد [{code}]' if code else 'حامل مقعد'
    if re.search(r'fixing.?set|طقم تثبيت', n_lower):
        return f'طقم تثبيت [{code}]' if code else 'طقم تثبيت'
    
    # === Accessories ===
    if re.search(r'accessor|إكسسوار', n_lower):
        t = 'إكسسوار'
        if series: t = f'إكسسوار {series}'
        return t + (f' [{code}]' if code else '')
    
    # === Furniture ===
    if re.search(r'furniture|vanity|console|موبيليا', n_lower):
        t = 'موبيليا'
        if series: t = f'موبيليا {series}'
        if re.search(r'drawer|درج', n_lower): t += ' بأدراج'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m: sz = f' {m.group(1)} سم'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    if re.search(r'\bunit\b|وحدة', n_lower):
        t = 'وحدة'
        if series: t = f'وحدة {series}'
        if re.search(r'tall|عالية', n_lower): t += ' عالية'
        if re.search(r'drawer|درج', n_lower): t += ' بأدراج'
        sz = ''
        m = re.search(r'(\d+)\s*cm', n)
        if m: sz = f' {m.group(1)} سم'
        t += sz
        return t + (f' [{code}]' if code else '')
    
    if re.search(r'mirror|مراية', n_lower):
        t = 'مراية'
        if series: t = f'مراية {series}'
        return t + (f' [{code}]' if code else '')
    
    if re.search(r'shelf|رف\b', n_lower):
        t = 'رف'
        if series: t = f'رف {series}'
        return t + (f' [{code}]' if code else '')
    
    # === Combi systems ===
    if re.search(r'combi|كومبي', n_lower):
        t = 'نظام كومبي'
        m = re.search(r'(\d+)', n)
        if m: t += f' {m.group(1)}'
        if series and series not in t: t = f'{series} {t}'
        return t + (f' [{code}]' if code else '')
    
    # === Valve related ===
    if re.search(r'valve|بلوف', n_lower):
        return f'بلوف [{code}]' if code else 'بلوف'
    if re.search(r'flush|طرد|plate|غطاء دفع|push|ضاغط|mechanism|ماكينة', n_lower):
        return f'طقم طرد [{code}]' if code else 'طقم طرد'
    
    # === By series (fallback with code) ===
    if series:
        t = series
        if code: t += f' [{code}]'
        return t
    
    # === By code only ===
    if code:
        if company == 'دروفيت':
            return f'دروفيت [{code}]'
        return f'ايديال [{code}]'
    
    # === Remove garbage chars ===
    clean = re.sub(r'[^\w\s\-\[\]\.,\(\)/]', '', clean).strip()
    if len(clean) > 3:
        return clean
    return name


# Generate SQL
updates = []
ideal_updated = 0
drovit_updated = 0
for p in products:
    new = generate_clean(p['name'], p['company'])
    if new != p['name']:
        safe = new.replace("'", "''")
        updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")
        if p['company'] == 'ايديال': ideal_updated += 1
        else: drovit_updated += 1

print(f"Updates: {len(updates)} (Ideal: {ideal_updated}, Drovit: {drovit_updated})", flush=True)

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\translate_v5.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/translate_v5.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/translate_v5.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Errors: {r2.stderr.count('ERROR') if r2.stderr else 0}", flush=True)

# Verify: count remaining English
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-c', "SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت') AND name ~ '[' || chr(65) || '-' || chr(90) || '[' || chr(97) || '-' || chr(122) || ']{2,}'"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Remaining with English: {r3.stdout.strip()}", flush=True)
print("DONE", flush=True)
