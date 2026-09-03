SELECT sc.name, count(p.id)
FROM subcategories sc
JOIN products p ON p.subcategory_id = sc.id
WHERE p.company IN ('ايديال', 'دروفيت')
GROUP BY sc.name
ORDER BY count DESC;
