SELECT count(*) AS products_with_english FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[A-Za-z]{2,}';

SELECT count(*) AS total_ideal FROM products WHERE company = 'ايديال';
SELECT count(*) AS total_drovit FROM products WHERE company = 'دروفيت';
