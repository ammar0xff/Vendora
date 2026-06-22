SELECT name FROM products 
WHERE company = 'كومر' 
  AND (name ~ '^[0-9]' OR name ~ '^"' OR name LIKE 'كومر%' OR length(name) < 10)
ORDER BY name;
