-- Check encoding issues
SELECT id, name::bytea, encode(name::bytea, 'escape')
FROM products
WHERE company = 'ايديال'
AND (
  name LIKE '%ط¨%' OR
  name LIKE '%ظ%' OR
  name LIKE '%ط%' OR
  name LIKE '%?%'
)
LIMIT 5;
