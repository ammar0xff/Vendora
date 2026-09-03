-- Fix remaining English names
-- Price range entries - use model numbers
UPDATE products SET name = concat('سعر حسب المقاس من ', substring(name, 'From \d+ to \d+'), ' موديل ', substring(name, 'G\d{3,}'))
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%From % to % سم%';

-- Series names - translate to Arabic
UPDATE products SET name = 'آيوم' WHERE company = 'ايديال' AND name = 'IOM' AND subcategory_id IN (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES');
UPDATE products SET name = 'DEA' WHERE company = 'ايديال' AND name = 'DEA';
UPDATE products SET name = 'أكوا' WHERE company = 'ايديال' AND name = 'AQUA';
UPDATE products SET name = 'تيسي' WHERE company = 'ايديال' AND name = 'TESI';
UPDATE products SET name = 'ستيب' WHERE company = 'ايديال' AND name = 'STEP';
UPDATE products SET name = 'إنترك' WHERE company = 'ايديال' AND name = 'ENTRY';
UPDATE products SET name = 'كريدو' WHERE company = 'ايديال' AND name = 'CREDO';
UPDATE products SET name = 'ميديا' WHERE company = 'ايديال' AND name = 'MEDIA';
UPDATE products SET name = 'ستوديو' WHERE company = 'ايديال' AND name = 'STUDIO';
UPDATE products SET name = 'فينيس' WHERE company = 'ايديال' AND name = 'VENICE';
UPDATE products SET name = 'نيو سيميراميس' WHERE company = 'ايديال' AND name = 'NEW SEMIRAMIS';

-- ceramic -> قطعة سيراميك
UPDATE products SET name = 'قطعة سيراميك' WHERE company IN ('ايديال', 'دروفيت') AND name = 'ceramic';

-- Fix IOM with different subcategory
UPDATE products SET name = 'آيوم' WHERE company IN ('ايديال', 'دروفيت') AND name = 'IOM';
