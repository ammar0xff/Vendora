SELECT sc.name, count(p.id)
FROM products p
JOIN subcategories sc ON p.subcategory_id = sc.id
WHERE p.company IN ('ايديال', 'دروفيت')
AND length(p.name) <= 5
AND NOT p.name ~ '[A-Za-z0-9\[\]]{3,}'
GROUP BY sc.name
ORDER BY count DESC;
