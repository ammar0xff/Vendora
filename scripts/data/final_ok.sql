SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND (name ~ '[A-Za-z]{3,}' OR length(name) <= 3);
