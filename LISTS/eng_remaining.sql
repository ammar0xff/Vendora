SELECT name FROM products WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}' AND name !~ '\['
LIMIT 25;
