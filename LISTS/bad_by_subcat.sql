SELECT sc.name, count(p.id) 
FROM products p
JOIN subcategories sc ON p.subcategory_id = sc.id
WHERE p.company IN ('ايديال', 'دروفيت')
AND position(chr(0x0679) in p.name) > 0
GROUP BY sc.name
ORDER BY count DESC;
