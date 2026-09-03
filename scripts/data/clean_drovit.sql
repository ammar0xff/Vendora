-- Clean Duravit names
-- They're mostly dimensions + model codes, keep model codes as primary identifier

-- Remove Arabic text suffix
UPDATE products p
SET name = trim(
  regexp_replace(
    regexp_replace(p.name, '[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF].*$', '', 'g'),
    '\s+', ' ', 'g'
  )
)
WHERE company = 'دروفيت';

-- Convert names like "460 mm 460 mm Ø 460 [0445460000]" to "Model 0445460000"
UPDATE products p
SET name = regexp_replace(name, '^\d[\d, .mmØ]+(\[[A-Z0-9]+\])', 'Model \1')
WHERE company = 'دروفيت' AND name ~ '^\d[\d, .mmØ]+';

-- Clean up excessive spaces
UPDATE products p
SET name = trim(regexp_replace(name, '\s+', ' ', 'g'))
WHERE company = 'دروفيت';

-- Delete products with very short names
DELETE FROM products WHERE company = 'دروفيت' AND length(trim(name)) < 5;
