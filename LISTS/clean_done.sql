-- Delete clearly non-product rows
DELETE FROM products WHERE company = 'ايديال' AND (
  name LIKE '%Al Fardous%' OR
  name LIKE '%Awlad Gabr%' OR
  name LIKE '%ZAKAZIK%' OR
  name LIKE '%El Nasr%' OR
  name LIKE '%October%' OR
  name LIKE '%info@idealstandard%' OR
  name LIKE '%Moltaqua%' OR
  name LIKE '%Sheraton%' OR
  name LIKE '%26969700%'
);

-- For names with leftover junk after [code], truncate at the bracket
UPDATE products p
SET name = CASE
  WHEN name ~ '\[[A-Z0-9]{3,}\]' THEN
    substring(name from '^(.*\[[A-Z0-9]{3,}\])') || 
    CASE WHEN substring(name from '^(.*\[[A-Z0-9]{3,}\])') != name THEN '' ELSE '' END
  ELSE name
END
WHERE company IN ('ايديال', 'دروفيت');

-- Trim
UPDATE products SET name = trim(regexp_replace(name, '\s+', ' ', 'g')) WHERE company IN ('ايديال', 'دروفيت');

SELECT company, count(*) FROM products WHERE company IN ('ايديال', 'دروفيت') GROUP BY company;
