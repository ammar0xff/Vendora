SELECT
  id,
  name,
  encode(name::bytea, 'hex') AS name_hex
FROM products
WHERE name LIKE '%سيديلي%' OR name LIKE '%س%يد%يل%'
LIMIT 1;
