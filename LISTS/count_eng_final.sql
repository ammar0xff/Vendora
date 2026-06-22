-- Count remaining with English characters
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}';
