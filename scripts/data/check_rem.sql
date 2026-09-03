SELECT count(*) AS remaining_english FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}'
AND name !~ '\[[A-Z0-9]+\]';
