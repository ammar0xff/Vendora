"""
Clean up product names for Ideal Standard and Duravit.
"""
import subprocess
import re

# Clean Ideal Standard names
sql_ideal = """
-- Delete the address row that got parsed as a product
DELETE FROM products WHERE company = 'ايديال' AND name ~ 'Moltaqua|Sheraton|info@idealstandard';

-- Fix names: remove garbled Arabic text suffix (anything after Latin chars that's Arabic-only from page footers)
-- Pattern: keep only up to the last English word before Arabic garbage starts
UPDATE products p
SET name = regexp_replace(
    regexp_replace(name, E'[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]', '', 'g'),  -- control chars
    E'[\\u0600-\\u06FF\\u0750-\\u077F\\u08A0-\\u08FF\\uFB50-\\uFDFF\\uFE70-\\uFEFF]+.*$',  -- Arabic unicode block and everything after
    '',
    'g'
)
WHERE company = 'ايديال';

-- Remove leading/trailing spaces, dashes, and normalize spaces
UPDATE products p
SET name = trim(regexp_replace(
    regexp_replace(name, E'[\\s-]+$', ''),
    E'\\s+', ' ', 'g'
))
WHERE company = 'ايديال';

-- Remove entries where name is empty or too short after cleaning
DELETE FROM products WHERE company = 'ايديال' AND length(trim(name)) < 3;

-- Set product names to just the code part for very messy ones
UPDATE products p
SET name = substring(name from '\\[([^]]+)\\]$')
WHERE company = 'ايديال' AND length(name) < 5;
""";

# Run Ideal cleanup
r = subprocess.run(
    ['docker', 'exec', '-i', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db'],
    input=sql_ideal, capture_output=True, text=True
)
print("Ideal cleanup:", r.stdout[-500:] if r.stdout else "")
if r.stderr:
    print("Errors:", r.stderr[-500:])

# Check results
r2 = subprocess.run(
    ['docker', 'exec', 'eg-co-erp-db-1', 'psql', '-U', 'postgres', '-d', 'inventory_db', '-c',
     "SELECT name FROM products WHERE company = 'ايديال' LIMIT 15"],
    capture_output=True, text=True
)
print("\nCleaned Ideal names:")
print(r2.stdout)
