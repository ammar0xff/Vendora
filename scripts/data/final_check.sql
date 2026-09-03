-- Count remaining
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}';

-- Show them
SELECT name FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}';
