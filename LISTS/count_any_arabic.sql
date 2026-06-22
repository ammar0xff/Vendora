SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name LIKE '%مرحاض%'
OR name LIKE '%حوض%'
OR name LIKE '%بانيو%';
