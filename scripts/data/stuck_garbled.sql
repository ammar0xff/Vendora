-- Find any names that still look wrong
SELECT name, encode(name::bytea, 'hex') FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND (
  name ~ '[' || chr(0x0638) || ']'
  OR name ~ '[' || chr(0x0637) || ']'
)
AND name !~ '[' || chr(0x0627) || ']'
AND name !~ '[' || chr(0x064A) || ']'
LIMIT 10;
