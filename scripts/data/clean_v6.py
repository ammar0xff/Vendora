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

print(f"Loaded: {len(products)}", flush=True)

def keep_clean_arabic(s):
    """Keep only clean Arabic chars, digits, spaces, and common punctuation."""
    out = []
    for ch in s:
        if '\u0600' <= ch <= '\u06FF':
            out.append(ch)
        elif '\u0660' <= ch <= '\u0669':
            out.append(ch)
        elif ch.isascii() and ch.isalnum():
            out.append(ch)
        elif ch in ' \t-.,xX()[]/':
            out.append(ch)
    return ''.join(out)

def extract_clean_info(name):
    """Extract any clean info from a possibly garbled name."""
    n = name.replace('\xad', '').replace('\u200b', '').replace('\ufeff', '')
    code = ''
    m = re.search(r'\[([A-Z0-9]+)\]', n)
    if m: code = m.group(1)
    
    info = []
    
    # Series names (clean ASCII)
    for s in ['TONIC', 'KIMERA', 'PROSYS', 'HAPPY D', 'SPACE', 'CONNECT',
              'D-CODE', 'X-LARGE', 'SEPARATES', 'D-NEO', 'DURASTYLE', 'VERO',
              'SAN REMO', 'PLAYA', 'MANTA', 'TESI', 'STARCK', 'DARLING',
              'L-CUBE', 'PLAN', 'P3 COMFORTS', 'DURAPLUS', 'NEW ESEDRA',
              'NEW CAPRI', 'PURAVIDA', 'SOPHIA', 'IOM', 'ECHO', 'I.LIFE',
              'STUDIO', 'INDEPENDENT', 'EMILIA', 'DIAGONAL', 'GOLF', 'CARO',
              'VITRIUM', 'KETHO', 'CREDO', 'NEW SEMIRAMIS', 'ENTRY',
              'VENICE', 'MEDIA', 'AQUA', 'STEP', 'DEA', 'COOL', 'COPACABANA',
              'CAPRI', 'ESEDRA', 'SEMIRAMIS', 'SMITHE', 'GATTO', 'TURBO']:
        if s in n:
            info.append(s)
            break
    
    # Model numbers (GAxxx, Gxxxx, BCxxx, etc.)
    models = re.findall(r'\b(GA\d{2,}|G\d{3,}|BC\d{2,}|GD\d{2,}|P\d{2,})\b', n)
    if models:
        info.append(' '.join(models))
    
    # Clean Arabic words (might survive corruption)
    arabic_words = re.findall(r'[\u0600-\u06FF\u0660-\u0669]+', n)
    arabic_info = [w for w in arabic_words if len(w) >= 2]
    
    # Dimension patterns
    dims = re.findall(r'\d+\s*[xX×]\s*\d+(?:\s*[xX×]\s*\d+)?\s*(?:سم|cm|mm)?', n)
    if dims:
        info.append(dims[0].strip())
    
    # Single number + cm/mm
    sz = re.findall(r'\d+\s*(?:سم|cm|mm)', n)
    if sz and not dims:
        info.append(sz[0].strip())
    
    # Try to match partial English keywords for type detection
    has_type = False
    n_lower = n.lower()
    
    for keyword, arabic in [
        ('bowl', 'مرحاض'), ('bidet', 'بيديه'), ('seat', 'سيديلي'),
        ('cover', 'غطاء'), ('tank', 'خزان'), ('cistern', 'خزان'),
        ('mixer', 'خلاط'), ('tap', 'حنفية'), ('pedestal', 'عامود'),
        ('lavatory', 'حوض'), ('lava', 'حوض'), ('wash', 'حوض'),
        ('shower', 'دش'), ('tray', 'صينية'), ('panel', 'بانيلي'),
        ('bath', 'بانيو'), ('mirror', 'مراية'), ('shelf', 'رف'),
        ('furniture', 'موبيليא'), ('vanity', 'موبيليא'), ('unit', 'وحدة'),
        ('handspray', 'دش يدوي'), ('handspra', 'دش يدوي'),
        ('enclosure', 'كابينة'), ('screen', 'كابينة'),
        ('column', 'عمود'), ('combi', 'كومبي'),
        ('spa', 'سبا'), ('whirlpool', 'جاكوزي'),
        ('connecting', 'جلبة'), ('chair', 'حامل'),
        ('accessor', 'إكسسوار'), ('valve', 'بلوف'),
        ('flush', 'طرد'), ('plate', 'غطاء دفع'),
        ('fixing', 'تثبيت'), ('support', 'حامل'),
    ]:
        if keyword in n_lower:
            has_type = keyword
            break
    
    return {
        'code': code,
        'series': info[0] if info and not info[0].startswith('G') and not re.match(r'\d+x\d+', info[0]) else '',
        'models': [m for m in info if not m.startswith('G') and not re.match(r'\d+x?\d*\s*سم', m) and m != (info[0] if info else '')],
        'dimension': next((i for i in info if re.match(r'\d+[xX×]', i) or re.search(r'سم|cm|mm', i)), ''),
        'has_type': has_type,
        'arabic_words': arabic_info[:3],
    }

def generate_clean_v2(name, company):
    """Generate clean Arabic name, removing all corrupted text."""
    n = name.replace('\xad', '').replace('\u200b', '').replace('\ufeff', '')
    info = extract_clean_info(n)
    
    code = info['code']
    series = info['series']
    models = info['models']
    dim = info['dimension']
    has_type = info['has_type']
    
    # Build name from clean components
    parts = []
    
    if has_type:
        type_map = {
            'bowl': 'مرحاض', 'bidet': 'بيديه', 'seat': 'سيديلي',
            'cover': 'غطاء', 'tank': 'خزان', 'cistern': 'خزان',
            'mixer': 'خلاط', 'tap': 'حنفية', 'pedestal': 'عامود',
            'lavatory': 'حوض', 'lava': 'حوض', 'wash': 'حوض',
            'shower': 'دش', 'tray': 'صينية', 'panel': 'بانيلي',
            'bath': 'بانيو', 'mirror': 'مراية', 'shelf': 'رف',
            'furniture': 'موبيليا', 'vanity': 'موبيليا', 'unit': 'وحدة',
            'handspray': 'دش يدوي', 'handspra': 'دش يدوي',
            'enclosure': 'كابينة', 'screen': 'كابينة',
            'column': 'عمود دش', 'combi': 'نظام كومبي',
            'spa': 'سبا', 'whirlpool': 'جاكوزي',
            'connecting': 'جلبة توصيل', 'chair': 'حامل مقعد',
            'accessor': 'إكسسوار', 'valve': 'بلوف',
            'flush': 'طقم طرد', 'plate': 'غطاء دفع',
            'fixing': 'طقم تثبيت', 'support': 'حامل',
        }
        t = type_map.get(has_type, '')
        
        # Add nuance
        n_lower = n.lower()
        
        # For bowls: detect P/S, douche, wall-hung
        if has_type == 'bowl':
            if re.search(r'\bp\b', n_lower): t = 'مرحاض P'
            elif re.search(r'\bs\b', n_lower): t = 'مرحاض S'
            if re.search(r'mini', n_lower): t = 'مرحاض ميني'
            if re.search(r'wall.?hung|wall.?mount', n_lower): t += ' معلق'
            if re.search(r'close.?coupled|back.?to.?wall', n_lower): t += ' للحائط'
            # Check for douche (possibly garbled)
            if re.search(r'without douche|w/out douche|بدون دوش', n_lower) or ('دوش' not in n and 'دوش' not in ''.join(info['arabic_words'])):
                # Check if douche mention exists at all
                if re.search(r'douche|دوش', n_lower):
                    t += ' بدون دوش'
            if re.search(r'with douche|بدوش', n_lower):
                t += ' بدوش'
        
        if has_type == 'bidet':
            if re.search(r'without douche|w/out douche|بدون دوش', n_lower):
                t += ' بدون دوش'
            if re.search(r'with douche|بدوش', n_lower):
                t += ' بدوش'
            if re.search(r'wall.?hung', n_lower): t += ' معلق'
        
        if has_type == 'seat' and 'سيديلي' in t:
            if re.search(r'soft.?close|ذاتي الغلق', n_lower): t += ' ذاتي الغلق'
            if 'cover' not in t and re.search(r'\bcover\b', n_lower):
                t = t.replace('سيديلي', 'سيديلي وغطاء')
        
        if has_type == 'tank':
            if re.search(r'dual.?flush|ضغط مزدوج', n_lower): t += ' - ضغط مزدوج'
            if re.search(r'trim', n_lower): t += ' وطقم'
        
        if has_type in ('mixer', 'tap'):
            if re.search(r'basin|lava|sink|wash|hand|حوض', n_lower): t += ' حوض'
            elif re.search(r'bath|بانيو', n_lower): t += ' بانيو'
            elif re.search(r'bidet|بيديه', n_lower): t += ' بيديه'
            elif re.search(r'shower|دش', n_lower): t += ' دش'
            elif re.search(r'deck|wall|حائط', n_lower): t += ' حائط'
            if re.search(r'single.?hole', n_lower): t += ' فتحة واحدة'
            if re.search(r'high.?spout', n_lower): t += ' عالي'
        
        if has_type == 'shower':
            if re.search(r'tray|base|صينية', n_lower):
                t = 'صينية دش'
                if re.search(r'corner|pentagon|quadrant|ركنية', n_lower): t += ' ركنية'
            elif re.search(r'enclosure|screen|كابينة', n_lower):
                t = 'كابينة دش'
                if re.search(r'folding|fold|طي', n_lower): t += ' قابلة للطي'
                elif re.search(r'sliding|slide|منزلقة', n_lower): t += ' منزلقة'
                elif re.search(r'pivot|محورية', n_lower): t += ' محورية'
                if re.search(r'corner|pentagon|ركنية', n_lower): t += ' ركنية'
            elif re.search(r'column|عمود', n_lower):
                t = 'عمود دش'
            elif re.search(r'hand.?spray', n_lower):
                t = 'دش يدوي'
            elif re.search(r'set', n_lower):
                t = 'طقم دش'
        
        if has_type == 'panel':
            if re.search(r'side|جانبي', n_lower): t = 'بانيلي جانبي'
            elif re.search(r'front|أمامي', n_lower): t = 'بانيلي أمامي'
            elif re.search(r'end|طرفي', n_lower): t = 'بانيلي طرفي'
        
        if has_type == 'bath':
            if re.search(r'whirlpool|whir', n_lower): t += ' جاكوزي'
            if re.search(r'spa', n_lower): t += ' سبا'
        
        if has_type == 'lavatory' or has_type == 'lava' or has_type == 'wash':
            if re.search(r'guest', n_lower): t = 'حوض ضيوف'
            if re.search(r'counter.?top|above|كونترتوب', n_lower): t = 'حوض كونترتوب'
            elif re.search(r'under.?counter|تحت سطح', n_lower): t = 'حوض تحت سطح'
            elif re.search(r'semi.?counter|نصف', n_lower): t = 'حوض نصف كونترتوب'
            if re.search(r'pedestal', n_lower): t = 'حوض مع عامود'
        
        if has_type == 'furniture' or has_type == 'vanity':
            if series and series != 'TONIC': t = f'موبيليا {series}'
            else: t = 'موبيليا'
        
        if has_type == 'unit':
            if series: t = f'وحدة {series}'
            if re.search(r'tall|عالية', n_lower): t += ' عالية'
            if re.search(r'drawer|درج', n_lower) and not re.search(r'drawers', n_lower): t += ' درج واحد'
            if re.search(r'2\s*drawer|two|درجين', n_lower): t += ' درجين'
            if re.search(r'3\s*drawer|three', n_lower): t += ' 3 أدراج'
            if re.search(r'4\s*drawer|four', n_lower): t += ' 4 أدراج'
        
        if dim:
            t += f' - {dim}'
        
        parts.append(t)
    elif series:
        parts.append(series)
        if dim:
            parts[-1] += f' {dim}'
        if models and not dim:
            parts[-1] += ' ' + models[0] if isinstance(models, list) and models else ''
    elif models:
        parts.append(' '.join(models) if isinstance(models, list) else models)
    elif dim:
        parts.append(dim)
    elif info['arabic_words']:
        parts.append(' '.join(info['arabic_words']))
    
    if code:
        parts.append(f'[{code}]')
    
    if parts:
        return ' '.join(parts)
    
    # Final fallback
    if code:
        return f'ايديال [{code}]' if company == 'ايديال' else f'دروفيت [{code}]'
    
    # Try to extract anything recognizable
    clean = re.sub(r'[^\w\s\-\[\]\.,\(\)/]', ' ', name).strip()
    clean = re.sub(r'\s+', ' ', clean)
    if len(clean) > 2:
        return clean
    return name

# Generate SQL
updates = []
for p in products:
    new_name = generate_clean_v2(p['name'], p['company'])
    if new_name != p['name']:
        safe = new_name.replace("'", "''")
        updates.append(f"UPDATE products SET name = '{safe}' WHERE id = '{p['id']}';")

print(f"Updates: {len(updates)}", flush=True)

sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\translate_v6.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/translate_v6.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/translate_v6.sql'],
    capture_output=True, text=True, encoding='utf-8', errors='replace'
)
print(f"Errors: {r2.stderr.count('ERROR') if r2.stderr else 0}", flush=True)
print("DONE", flush=True)
