SELECT count(*) AS garbage FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND length(name) <= 5
AND NOT name ~ '[A-Za-z0-9\[\]]{3,}';
