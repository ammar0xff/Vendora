SELECT p.name, sc.name AS subcat, p.company
FROM products p
JOIN subcategories sc ON p.subcategory_id = sc.id
WHERE p.company IN ('ايديال', 'دروفيت')
AND length(p.name) <= 5
ORDER BY sc.name;
