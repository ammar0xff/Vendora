-- Fix remaining English names using subcategory context

-- 1. D-CODE: products with reference codes
UPDATE products SET name = concat('D-CODE ', substring(name, 'WF\d+|XB\d+|KT\d+'))
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '^(WF|XB|KT)'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'D-CODE');

-- 2. HAPPY D.
UPDATE products SET name = concat('HAPPY D. ', substring(name, 'WF\d+'))
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '^WF'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'HAPPY D.');

-- 3. KIMERA price ranges
UPDATE products SET name = concat('كيميرا - بانيلي ', substring(name, 'From \d+ to \d+'), ' موديل ', substring(name, '[G]\s*\d{3,}'))
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ 'From'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'KIMERA');

-- 4. L-CUBE part numbers
UPDATE products SET name = concat('L-CUBE ', substring(name, 'DS\d+|KT\d+'))
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '^(DS|KT)'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'L-CUBE');

-- 5. PROSYS DEA
UPDATE products SET name = 'PROSYS DEA'
WHERE company IN ('ايديال', 'دروفيت')
AND name = 'DEA'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'PROSYS');

-- 6. STARCK 3
UPDATE products SET name = concat('STARCK 3 ', name)
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '^XB'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'STARCK 3');

-- 7. TONIC DEA
UPDATE products SET name = 'TONIC DEA'
WHERE company IN ('ايديال', 'دروفيت')
AND name = 'DEA'
AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'TONIC');
