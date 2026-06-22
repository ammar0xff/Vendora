SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{3,}';

SELECT count(*) AS garbage_short FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND length(name) <= 5;

SELECT count(*) AS garbage FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND length(name) <= 3;
