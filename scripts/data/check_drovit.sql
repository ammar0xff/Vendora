SELECT count(*) FROM products
WHERE company = 'دروفيت'
AND name ~ '[A-Za-z]{2,}';
