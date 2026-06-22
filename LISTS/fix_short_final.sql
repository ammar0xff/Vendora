-- Fix remaining short names
UPDATE products p SET name = 'قطعة ايديال'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'OTHERS'
AND p.name = 'قطعة' AND p.company = 'ايديال';

UPDATE products p SET name = 'قطعة دروفيت'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'SEPARATES'
AND p.name = 'قطعة' AND p.company = 'دروفيت';

UPDATE products p SET name = concat('إل كيوب ', p.name)
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'L-CUBE'
AND p.name ~ '^\d+$' AND p.company = 'دروفيت';
