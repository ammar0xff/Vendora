SELECT name, size, retail_price FROM products 
WHERE company = 'كومر' AND name LIKE 'كومر%' 
ORDER BY name LIMIT 20;
