SELECT p.name, sc.name AS subcategory
FROM products p
JOIN subcategories sc ON p.subcategory_id = sc.id
WHERE p.company IN ('ايديال', 'دروفيت')
AND p.name ~ '[A-Za-z]{2,}'
ORDER BY sc.name, p.name;
