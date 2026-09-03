SELECT name FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND length(name) <= 5;
