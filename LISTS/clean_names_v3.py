import subprocess
import re
import json

# Dump products to JSON via docker psql
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '\t',
     '-c', "SELECT row_to_json(t)::text FROM (SELECT id, name, company, subcategory_id FROM products WHERE company IN ('ايديال', 'دروفيت')) t"],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)

raw = r.stdout.strip()
# Filter valid JSON lines
products = []
for line in raw.split('\n'):
    line = line.strip()
    if line.startswith('{') and line.endswith('}'):
        try:
            p = json.loads(line)
            products.append(p)
        except:
            pass

print(f"Loaded {len(products)} products")

# Group by company
ideal = [p for p in products if p.get('company') == 'ايديال']
drovit = [p for p in products if p.get('company') == 'دروفيت']
print(f"ايديال: {len(ideal)}, دروفيت: {len(drovit)}")

# Count corrupted
corrupted = 0
for p in products:
    name = p['name']
    for ch in name:
        if ord(ch) > 127 and not ('\u0600' <= ch <= '\u06FF') and not ('\u0660' <= ch <= '\u0669') and ch not in '•©®✓→×':
            corrupted += 1
            break
print(f"Corrupted names: {corrupted}")

# === INTELLIGENT NAME GENERATOR ===
def guess_product_type(name):
    """Identify what kind of product this is based on keywords."""
    n = name.lower()
    
    # Normalize common PDF garbage
    n = n.replace('\xad', '')  # soft hyphen
    n = re.sub(r'[\u2000-\u200f\u2028-\u202f\u2060-\u206f\ufeff]', '', n)  # various unicode garbage
    
    types = []
    
    # WC / Toilet
    if re.search(r'bowl\b', n) and not re.search(r'wash\s*bowl|washbowl|lava', n):
        types.append('مرحاض')
        if re.search(r'\bP\b', n): types[0] += ' P'
        if re.search(r'\bS\b', n): types[0] += ' S'
        if re.search(r'mini\s*bowl', n): types[0] = 'مرحاض ميني'
        if re.search(r'wall.?hung|wall.?mount', n): types[0] += ' معلق'
        if re.search(r'close\s*coupled|back.?to.?wall', n): types[0] += ' للحائط'
    
    if re.search(r'\btoilet\b|\bwc\b', n):
        if not types: types.append('مرحاض')
    
    if re.search(r'bidet', n):
        types.append('بيديه')
    
    # Lavatory / Basin
    if re.search(r'lavatory|lava\b|wash\s*bowl|washbowl|washbasin|hand\s*wash|handwash|basin', n):
        t = 'حوض'
        if re.search(r'guest', n): t = 'حوض ضيوف'
        if re.search(r'counter.?top|countertop', n): t += ' كونترتوب'
        if re.search(r'under.?counter|undercounter', n): t += ' تحت سطح'
        if re.search(r'semi.?counter|semicounter', n): t += ' نصف كونترتوب'
        if re.search(r'vessel', n): t += ' فوق سطح'
        if re.search(r'pedestal', n) or re.search(r'wall.?hung|wall.?mount', n): t += ' معلق'
        types.append(t)
    
    # Sink
    if re.search(r'\bsink\b', n):
        t = 'حوض مطبخ'
        types.append(t)
    
    # Toilet seat
    if re.search(r'\bseat\b', n) and re.search(r'\bcover\b', n):
        types.append('سيديلي وغطاء')
    if re.search(r'\bseat\b', n) and not re.search(r'\bcover\b', n) and not types:
        types.append('سيديلي')
    
    # Pedestal
    if re.search(r'pedestal', n):
        t = 'عامود'
        if re.search(r'floor|large', n): t += ' أرضي'
        if re.search(r'semi', n): t = 'نصف عامود'
        if re.search(r'small', n): t = 'عامود صغير'
        types.append(t)
    
    # Cistern / Tank
    if re.search(r'\btank\b|\bcistern', n):
        t = 'خزان'
        if re.search(r'\btrim\b', n): t += ' وطقم'
        if re.search(r'dual\s*flush|dualflush', n): t += ' - ضغط مزدوج'
        if re.search(r'4\.5/3', n) or re.search(r'4،5/3', n): t += ' - 4.5/3 لتر'
        types.append(t)
    
    # Mixer / Tap
    if re.search(r'mixer|tap|faucet', n):
        t = 'خلاط'
        if re.search(r'basin|lava|sink|washbowl|hand', n): t += ' حوض'
        elif re.search(r'bath|shower', n): t += ' بانيو' 
        elif re.search(r'sink|kitchen', n): t += ' مطبخ'
        elif re.search(r'bidet', n): t += ' بيديه'
        elif re.search(r'deck|wall', n): t += ' حائط'
        if re.search(r'single.?hole', n): t += ' فتحة واحدة'
        if re.search(r'swivel|swive', n): t += ' سفلي'
        if re.search(r'high.?spout', n): t += ' عالي'
        if re.search(r'pop.?up|popup', n): t += ' مع ضغط صرف'
        types.append(t)
    
    # Furniture
    if re.search(r'furniture|vanity|console', n):
        t = 'موبيليا'
        # Detect collection/series
        series = detect_series(n)
        if series: t = f'موبيليا {series}'
        if re.search(r'floor|standing', n): t += ' أرضية'
        if re.search(r'wall|hung|mount', n): t += ' معلقة'
        types.append(t)
    
    # Unit
    if re.search(r'\bunit\b', n) and not re.search(r'furniture|vanity', n):
        t = 'وحدة'
        series = detect_series(n)
        if series: t = f'وحدة {series}'
        if re.search(r'\btall\b', n): t = f'وحدة عالية'
        if re.search(r'\bdrawer', n): t += ' بأدراج'
        if re.search(r'\bdoor\b', n): t += ' بأبواب'
        types.append(t)
    
    # Bath tub
    if re.search(r'\bbath\b', n) and not re.search(r'enclosure|screen|panel|shower', n):
        t = 'بانيو'
        if re.search(r'whirlpool|whir', n): t += ' جاكوزي'
        if re.search(r'spa|mini.?spa', n): t += ' سبا'
        types.append(t)
    
    # Shower enclosure
    if re.search(r'shower\s*enclosure|bath.?screen|bath.?enclosure|shower.?screen', n):
        t = 'كابينة دش'
        if re.search(r'folding|fold', n): t += ' قابلة للطي'
        if re.search(r'sliding|slide', n): t += ' منزلقة'
        if re.search(r'pivot', n): t += ' محورية'
        if re.search(r'corner|pentagon|quadrant', n): t += ' ركنية'
        types.append(t)
    
    # Shower tray
    if re.search(r'shower\s*tray|shower\s*base|shower.?tray', n):
        t = 'صينية دش'
        if re.search(r'corner|pentagon|quadrant', n): t += ' ركنية'
        types.append(t)
    
    # Shower panel / column
    if re.search(r'shower\s*panel|shower\s*column', n):
        t = 'بانيلي دش'
        types.append(t)
    
    # Handspray / Shower head
    if re.search(r'hand.?spray|handspray', n):
        types.append('دش يدوي')
    
    # Bath panel
    if re.search(r'\bpanel\b', n) and not re.search(r'control|push|bracket|shower', n):
        t = 'بانيلي'
        if re.search(r'\bside\b', n): t = 'بانيلي جانبي'
        if re.search(r'\bfront\b', n): t = 'بانيلي أمامي'
        types.append(t)
    
    # Accessories
    if re.search(r'accessor', n):
        types.append('إكسسوار')
    
    return types

def detect_series(name):
    n = name.lower()
    series_list = ['TONIC', 'DIAGONAL', 'MANTA', 'CONNECT', 'TESI', 'CAPRI',
                   'KIMERA', 'ESEDRA', 'PLAYA', 'ILIFE', 'I.LIFE', 'INDEPENDENT',
                   'SAN REMO', 'PLAN', 'SOPHIA', 'SPACE', 'STUDIO', 'IOM',
                   'HAPPY D', 'DURASTYLE', 'DARLING', 'VERO', 'P3 COMFORTS',
                   'D-NEO', 'L-CUBE', 'KETHO', 'CARO', 'X-LARGE', 'D-CODE',
                   'PURAVIDA', 'VITRIUM', 'GOLF', 'EMILIA', 'ECHO',
                   'DURAPLUS', 'STARCK', 'SOLEA', 'FLORIDA', 'CONTOUR',
                   'NIAGRA', 'SUPER', 'COMBI', 'TURBO', 'PROSYS',
                   'VENICE', 'NEW CAPRI', 'NEW ESEDRA']
    for s in series_list:
        if s.lower() in n:
            return s
    return None

def extract_dimensions(name):
    """Extract dimensions from name."""
    n = name.replace('\xad', '')
    dims = []
    # Find patterns like "120x70", "120 x 70", "100 cm", "1000 mm"
    m = re.search(r'(\d+)\s*[xX×]\s*(\d+)', n)
    if m:
        dims.append(f"{m.group(1)}x{m.group(2)}")
    m = re.search(r'(\d+)\s*[xX×]\s*(\d+)\s*[xX×]\s*(\d+)', n)
    if m:
        dims.append(f"{m.group(1)}x{m.group(2)}x{m.group(3)}")
    m = re.search(r'(\d+)\s*cm', n)
    if m:
        if not any(m.group(1) in d for d in dims):
            dims.append(f"{m.group(1)} سم")
    return ' '.join(dims) if dims else ''

def extract_code(name):
    m = re.search(r'\[([A-Z0-9]+)\]', name)
    return m.group(1) if m else ''

def extract_model(name):
    """Extract model/reference numbers like GA863, G0481, 0417100027."""
    m = re.findall(r'\b([A-Z]{1,2}\d{3,})\b', name)
    if m:
        return ' '.join(m)
    return ''

def clean_arabic_name(name, company):
    """Generate a clean Arabic product name."""
    code = extract_code(name)
    n = name.replace(f'[{code}]', '').strip() if code else name
    # Remove soft hyphens and unicode garbage
    n = n.replace('\xad', '')
    n = re.sub(r'[\u2000-\u200f\u2028-\u202f\u2060-\u206f\ufeff]', '', n)
    
    # Get product type(s)
    types = guess_product_type(n)
    
    # Get dimensions
    dims = extract_dimensions(n)
    
    # Get series
    series = detect_series(n)
    
    # Get model numbers (for Duravit)
    models = extract_model(n)
    
    # Build clean name
    if types:
        t = types[0]
        if dims:
            t += f' - {dims}'
        if series and series not in t:
            t = f'{series} {t}'
        if code:
            t += f' [{code}]'
        return t
    elif series:
        t = series
        if dims:
            t += f' {dims}'
        if code:
            t += f' [{code}]'
        return t
    elif company == 'دروفيت' and code:
        return f'دروفيت [{code}]'
    elif company == 'ايديال' and code:
        return f'ايديال [{code}]'
    elif company == 'دروفيت' and models:
        return f'دروفيت {models}'
    
    # Last resort: just use original with garbage cleaned
    clean = re.sub(r'[^\w\s\-\[\]\.,\(\)/]', '', n).strip()
    if clean:
        return clean
    return name

for p in products[:30]:
    name = p['name']
    new = clean_arabic_name(name, p['company'])
    # Only print if different
    if new != name:
        print(f"  {name[:70]}")
        print(f"  → {new}")
        print()
