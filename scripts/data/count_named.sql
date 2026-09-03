SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name LIKE 'قطعة %';
