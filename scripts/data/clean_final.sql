-- More aggressive cleanup for both companies

-- Remove [nan] from names
UPDATE products SET name = regexp_replace(name, E'\\[nan\\]', '', 'g') WHERE company IN ('ايديال', 'دروفيت');

-- Remove trailing unfinished text (lines ending without complete words)
UPDATE products p
SET name = trim(regexp_replace(
  regexp_replace(name, '\s*\[.*$', '', 'g'),  -- remove bracketed suffix that isn't a clean code
  '\s+', ' ', 'g'
))
WHERE company IN ('ايديال', 'دروفيت') AND name ~ '\[[A-Z0-9]+\]' = false;

-- For any name that still has brackets with junk (not clean codes), remove them
UPDATE products p
SET name = trim(regexp_replace(name, '\s*\[[^]]*\]', '', 'g'))
WHERE company IN ('ايديال', 'دروفيت') AND name ~ '\[.*\]' AND name !~ '\[[A-Z][0-9]{3,}\]';

-- Trim whitespace
UPDATE products p SET name = trim(regexp_replace(name, '\s+', ' ', 'g')) WHERE company IN ('ايديال', 'دروفيت');

-- Delete any with empty names
DELETE FROM products WHERE company IN ('ايديال', 'دروفيت') AND length(trim(name)) < 3;
