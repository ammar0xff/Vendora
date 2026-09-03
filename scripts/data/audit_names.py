import subprocess
import re
import json

# Fetch all products into Python where Unicode works properly
r = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db',
     '-t', '-A', '-F', '\t',
     '-c', "SELECT id, name, company, subcategory_id FROM products WHERE company IN ('ايديال', 'دروفيت') ORDER BY company, subcategory_id"],
    capture_output=True, text=True, encoding='utf-8'
)

raw = r.stdout.strip()
lines = [l for l in raw.split('\n') if l.strip()]
print(f"Total products: {len(lines)}")

# Check for corrupted text
corrupted_count = 0
for line in lines:
    parts = line.split('\t')
    if len(parts) >= 2:
        name = parts[1]
        # Check if name contains garbled chars (common mojibake patterns)
        garbled = False
        for ch in name:
            if '\u0600' <= ch <= '\u06FF':
                continue
            if '\u0030' <= ch <= '\u0039':
                continue
            if '\u0041' <= ch <= '\u005A':
                continue
            if '\u0061' <= ch <= '\u007A':
                continue
            if ch in ' ()[]-.,/&+xX*:°©®♿✓●•→×✓✓✓✓✓✓' or ch.isspace() or ch in '،""''':
                continue
            # If it's any other char, might be garbled
            if ord(ch) > 127:
                garbled = True
                break
        if garbled:
            corrupted_count += 1

print(f"Products with garbled/corrupted text: {corrupted_count}")

# Sample corrupted
print("\n=== Sample corrupted names ===")
sample_count = 0
for line in lines:
    parts = line.split('\t')
    if len(parts) >= 2:
        name = parts[1]
        garbled = False
        for ch in name:
            if ord(ch) > 127 and not ('\u0600' <= ch <= '\u06FF') and not ('\u0660' <= ch <= '\u0669'):
                garbled = True
                break
        if garbled:
            pid = parts[0]
            print(f"[{pid}] {repr(name)[:120]}")
            sample_count += 1
            if sample_count >= 10:
                break

# Sample clean Arabic
print("\n=== Sample clean Arabic names ===")
sample_count = 0
for line in lines:
    parts = line.split('\t')
    if len(parts) >= 2:
        name = parts[1]
        clean = True
        for ch in name:
            if ord(ch) > 127 and not ('\u0600' <= ch <= '\u06FF') and not ('\u0660' <= ch <= '\u0669'):
                clean = False
                break
        if clean and re.search(r'[\u0600-\u06FF]', name):
            pid = parts[0]
            print(f"[{pid}] {name[:100]}")
            sample_count += 1
            if sample_count >= 10:
                break

# Count products with English only
eng_only = 0
for line in lines:
    parts = line.split('\t')
    if len(parts) >= 2:
        name = parts[1]
        if not re.search(r'[\u0600-\u06FF]', name):
            eng_only += 1
print(f"\nProducts with NO Arabic (English only): {eng_only}")
