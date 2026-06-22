SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{2,}';

SELECT name FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{2,}';
