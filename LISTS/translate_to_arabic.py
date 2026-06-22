"""
Translate all Ideal Standard and Duravit product names to Arabic.
Uses pattern matching with term replacement.
"""
import subprocess
import re

# Comprehensive translation dictionary
TRANSLATIONS = {
    # Product types
    'Bowl': 'مرحاض',
    'Wash bowl': 'حوض',
    'Washbasin': 'حوض',
    'Lavatory': 'حوض',
    'Basin': 'حوض',
    'Bidet': 'بيديه',
    'Toilet': 'مرحاض',
    'Urinal': 'مبول',
    'Sink': 'حوض',
    'Pedestal': 'عامود',
    'Tank': 'خزان',
    'Cistern': 'خزان',
    'Trim': 'طقم',
    'Seat': 'سيديلي',
    'Cover': 'غطاء',
    'Mixer': 'خلاط',
    'Tap': 'حنفية',
    'Faucet': 'حنفية',
    'Shower': 'دش',
    'Handspray': 'دش يدوي',
    'Bath': 'بانيو',
    'Bathtub': 'بانيو',
    'Furniture': 'موبيليا',
    'Vanity': 'موبيليا',
    'Cabinet': 'دولاب',
    'Mirror': 'مراية',
    'Shelf': 'رف',
    'Panel': 'بانيلي',
    'Enclosure': 'كابينة',
    'Screen': 'كابينة',
    'Tray': 'صينية',
    'Unit': 'وحدة',
    'Column': 'عامود',
    'Connecting bend': 'جلبة توصيل',
    'Support': 'حامل',
    'Chair Support': 'حامل مقعد',
    'Fixing Set': 'طقم تثبيت',
    
    # Descriptions
    'without douche': 'بدون دوش',
    'with douche': 'بدوش',
    'with douche & handle': 'بدوش ومقبض',
    'with douche and handle': 'بدوش ومقبض',
    'w/out douche': 'بدون دوش',
    'without overflow': 'بدون فايظ',
    'with overflow': 'بالفايظ',
    'without tap hole': 'بدون فتحة خلاط',
    'without tap platform': 'بدون فتحة خلاط',
    'with tap platform': 'بفتحة خلاط',
    'Close Coupled': 'معلق للحائط',
    'close coupled': 'معلق للحائط',
    'Wall hung': 'معلق',
    'Wall-Hung': 'معلق',
    'Wall hung': 'معلق',
    'back to wall': 'للحائط',
    'back to wall': 'للحائط',
    'Floor standing': 'أرضي',
    'floor-standing': 'أرضي',
    'wall-mounted': 'معلق',
    'Wall mounted': 'معلق',
    'Countertop': 'كونترتوب',
    'Counter Top': 'كونترتوب',
    'Under Counter': 'تحت سطح',
    'Semi-Countertop': 'نصف كونترتوب',
    'Semi countertop': 'نصف كونترتوب',
    'Vessel': 'فوق سطح',
    'Rectangular': 'مستطيل',
    'Square': 'مربع',
    'Oval': 'بيضاوي',
    'Round': 'دائري',
    'Single-hole': 'فتحة واحدة',
    'Single hole': 'فتحة واحدة',
    'Double-hole': 'فتحتين',
    'Standard': 'قياسي',
    'Large': 'كبير',
    'Small': 'صغير',
    'Mini': 'ميني',
    'Compact': 'كومباكت',
    'Dual flush': 'ضغط مزدوج',
    'Dual Flush': 'ضغط مزدوج',
    'Soft Close': 'ذاتي الغلق',
    'Soft close': 'ذاتي الغلق',
    
    # Furniture/Storage
    'Drawer': 'درج',
    'Drawers': 'أدراج',
    'compartment': 'حجرة',
    'Door': 'باب',
    'Glass': 'زجاج',
    'Walnut': 'جوز',
    'Oak': 'بلوط',
    'Grey': 'رمادي',
    'White': 'أبيض',
    'Black': 'أسود',
    'Chrome': 'كروم',
    'Glossy': 'لامع',
    'Matt': 'مط',
    
    # Bath types
    'Whirlpool': 'جاكوزي',
    'Spa': 'سبا',
    'Mini Spa': 'ميني سبا',
    'System': 'نظام',
    'Jet': 'نفاثة',
    'Jets': 'نفاثات',
    'Panel': 'بانيلي',
    'Bathscreen': 'كابينة بانيو',
    'Pivot': 'محوري',
    'Folding': 'قابلة للطي',
    'Sliding': 'منزلقة',
    'Fixed': 'ثابت',
    'Pentagon': 'خماسي',
    'Corner': 'ركنية',
    
    # Measurements
    'cm': 'سم',
    'mm': 'مم',
    'KG': 'كجم',
    'kg': 'كجم',
    'L': 'لتر',
    
    # Other
    'Design by': 'تصميم',
    'Collection': 'مجموعة',
    'Set': 'طقم',
    'Accessory': 'إكسسوار',
    'Accessories': 'إكسسوارات',
    'Spare Parts': 'قطع غيار',
    'Part of': 'جزء من',
    'Including': 'يشمل',
    'with': 'مع',
    'without': 'بدون',
    'and': 'و',
    'or': 'أو',
    'for': 'لـ',
    'in': 'مقاس',
    'finish': 'تشطيب',
    'finishing': 'تشطيب',
    'Drain': 'صرف',
    'Pop-up': 'ضغط',
    'Overflow': 'فايظ',
    'Tap hole': 'فتحة خلاط',
    'Hole': 'فتحة',
    'Holes': 'فتحات',
    'Remote': 'ريموت',
    'Control': 'تحكم',
    'Handles': 'مقابض',
    'Handle': 'مقبض',
    'valve': 'بلوف',
    'Valve': 'بلوف',
    'Mechanism': 'ماكينة',
    'Plate': 'غطاء دفع',
    'Push button': 'ضاغط',
    'Flush': 'طرد',
    'Water saving': 'توفير مياه',
    'Concealed': 'مخفي',
    'Exposed': 'ظاهر',
    'Connection': 'توصيلة',
    'Bracket': 'حامل',
    'Hose': 'خرطوم',
    'Flexible': 'مرن',
    'Pipe': 'ماسورة',
    'Nut': 'صامولة',
    'Seal': 'أورينج',
    'Gasket': 'أورينج',
    'Waste': 'صرف',
    'Trap': 'كوع صرف',
    'Siphon': 'سيفون',
    'Angle valve': 'بلوف زاوية',
    'Stop valve': 'بلوف قطع',
    'Extension': 'وصلة',
    'Elbow': 'كوع',
    'Tee': 'Tee',
    'Union': 'اتحاد',
    'Reduction': 'تقليل',
    'Cap': 'غطاء',
    'Plug': 'سدادة',
    'Nipple': 'حلمة',
    'Bushing': 'بوشنج',
    'Flange': 'فلنشة',
    'Hanger': 'معلقة',
    'Clip': 'ماسك',
    'Ring': 'رنق',
    
    # Colors
    'Platinum': 'بلاتينوم',
    'PERGAMON': 'برجامون',
    'Pergamon': 'برجامون',
    'WHITE': 'أبيض',
    
    # Company-specific
    'Ideal Standard': 'ايديال ستاندرد',
    'Duravit': 'ديورافيت',
    'Starck': 'شتارك',
    'Philippe Starck': 'فيليب ستارك',
    'Happy D': 'هابي دي',
    'DuraStyle': 'ديورا ستايل',
    'Duraplus': 'ديورا بلس',
    'D-Neo': 'دي نيو',
    'Vero': 'فيرو',
    'Darling': 'دارلينج',
    'Darling New': 'دارلينج نيو',
    'X-Large': 'إكس لارج',
    'L-Cube': 'إل كيوب',
    'Ketho': 'كيثو',
    'Caro': 'كارو',
    'PuraVida': 'بيورا فيدا',
    'Vitrium': 'فيترم',
    'Golf': 'جولف',
    'Emilia': 'إميليا',
    'Echo': 'إيكو',
    'D-Code': 'دي كود',
    'P3 Comforts': 'بي 3 كومفورت',
    'Tonic': 'تونيك',
    'Diagonal': 'دياجونال',
    'Manta': 'مانتا',
    'Connect': 'كونكت',
    'Capri': 'كابري',
    'Kimera': 'كيميرا',
    'Esedra': 'إيسيدرا',
    'Playa': 'بلايا',
    'i.Life': 'آي لايف',
    'Independent': 'إندبندنت',
    'San Remo': 'سان ريمو',
    'Plan': 'بلان',
    'Sophia': 'صوفيا',
    'Space': 'سبيس',
    'PROSYS': 'بروسيس',
    'Solea': 'سوليا',
    'Florida': 'فلوريدا',
    'Contour': 'كونتور',
    'Niagra': 'نياجرا',
    'Super': 'سوبر',
    'Combi': 'كومبي',
    'Turbo': 'توربو',
    
    # Patterns to remove
    'without douche without douche': 'بدون دوش',
    'with douche with douche': 'بدوش',
    '[nan]': '',
}

# Sort translations by length (longest first) to match more specific terms first
sorted_terms = sorted(TRANSLATIONS.items(), key=lambda x: -len(x[0]))

def translate_name(name):
    """Translate an English product name to Arabic."""
    # Remove code in brackets for processing
    code_match = re.search(r'(\[[A-Z0-9]+\])', name)
    code = code_match.group(1) if code_match else ''
    clean_name = name
    if code:
        clean_name = name[:name.find(code)].strip()
    
    result = clean_name
    
    # Apply translations (case-insensitive)
    for eng, ara in sorted_terms:
        # Match whole words, case insensitive
        pattern = re.compile(re.escape(eng), re.IGNORECASE)
        result = pattern.sub(ara, result)
    
    # Clean up spaces and artifacts
    result = re.sub(r'\s+', ' ', result).strip()
    result = re.sub(r'\s*-\s*', ' - ', result)
    result = re.sub(r'\s*/\s*', ' / ', result)
    result = re.sub(r'\s+,', ',', result)
    result = re.sub(r',\s*', '، ', result)
    
    # Remove leading/trailing dashes
    result = result.strip('-').strip()
    
    # Re-attach code
    if code:
        result = f"{result} {code}"
    
    return result

# Fetch all products
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '|||',
     '-c', "SELECT id, name FROM products WHERE company IN ('ايديال', 'دروفيت') ORDER BY company, name"],
    capture_output=True, text=True
)

lines = [l.strip() for l in r.stdout.strip().split('\n') if l.strip()]
print(f"Products to translate: {len(lines)}")

# Generate SQL updates
updates = []
translated_count = 0
for line in lines:
    parts = line.split('|||')
    if len(parts) >= 2:
        pid = parts[0].strip()
        old_name = parts[1].strip()
        new_name = translate_name(old_name)
        
        if new_name and new_name != old_name:
            safe_name = new_name.replace("'", "''")
            updates.append(f"UPDATE products SET name = E'{safe_name}' WHERE id = '{pid}';")
            translated_count += 1

print(f"Translated: {translated_count} products")

# Write SQL to file
sql = '\n'.join(updates)
sql_path = r'C:\eg-co-erp\translate_products.sql'
with open(sql_path, 'w', encoding='utf-8') as f:
    f.write(sql)

# Copy to Docker and execute
subprocess.run(['docker', 'cp', sql_path, 'eg-co-erp-db-1:/tmp/translate.sql'], capture_output=True)
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-f', '/tmp/translate.sql'],
    capture_output=True, text=True
)

errors = r2.stderr.count('ERROR')
print(f"DB updates: {translated_count} attempted, {errors} errors")

# Show samples
r3 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-c', "SELECT name FROM products WHERE company = 'ايديال' AND length(name) < 90 ORDER BY random() LIMIT 10"],
    capture_output=True, text=True
)
print("\nSamples after translation:")
print(r3.stdout)
