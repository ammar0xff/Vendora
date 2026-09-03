-- Clean Ideal Standard names
DELETE FROM products WHERE company = 'ايديال' AND name LIKE '%Moltaqua%';

-- Remove Arabic text suffix from names
UPDATE products p
SET name = trim(
  regexp_replace(
    regexp_replace(p.name, '[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF].*$', '', 'g'),
    '\s+', ' ', 'g'
  )
)
WHERE company = 'ايديال';

-- Delete products with very short names after cleanup
DELETE FROM products WHERE company = 'ايديال' AND length(trim(name)) < 5;

-- Fix specific garbled entry
UPDATE products p SET name = 'Bidet without douche [G0093AC]' WHERE company = 'ايديال' AND name LIKE '%G0093AC%';
