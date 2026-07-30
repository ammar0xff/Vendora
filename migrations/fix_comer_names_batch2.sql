-- Generated 103 UPDATE statements
-- Fix remaining Comer product names (batch 2)
UPDATE products SET name = 'محبس كرة 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 729.89) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 130.89) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 673.19) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صمام عدم رجوع 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'صمامات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 723.15) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 52.13) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 154.57) < 0.01
  AND size = '1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'كوع 45 محول انجليزي 1 1/2"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 130.33) < 0.01
  AND size = '1 1/2"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1 1/2"*1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 16.29) < 0.01
  AND size = '1 1/2"*1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1 1/2"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 16.29) < 0.01
  AND size = '1 1/2"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 1 1/2"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 114.01) < 0.01
  AND size = '1 1/2"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 1 1/2"*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 74.80) < 0.01
  AND size = '1 1/2"*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1 1/2"*3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 16.29) < 0.01
  AND size = '1 1/2"*3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 112.80) < 0.01
  AND size = '1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 448.19) < 0.01
  AND size = '1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 623.72) < 0.01
  AND size = '1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 133.35) < 0.01
  AND size = '1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 49.10) < 0.01
  AND size = '1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1 1/4"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 8.45) < 0.01
  AND size = '1 1/4"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صمام عدم رجوع 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'صمامات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 534.03) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 508.51) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 20.61) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 98.81) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 83.85) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 297.39) < 0.01
  AND size = '1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1" x 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 7.24) < 0.01
  AND size = '1" x 3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 1"*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 7.24) < 0.01
  AND size = '1"*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 59.41) < 0.01
  AND size = '1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 15.76) < 0.01
  AND size = '1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 335.99) < 0.01
  AND size = '1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 50.07) < 0.01
  AND size = '1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 216.56) < 0.01
  AND size = '1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 110*4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 4238.85) < 0.01
  AND size = '110*4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'سرج 160*1.5"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'سرج وجلبة سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 721.33) < 0.01
  AND size = '160*1.5"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نقاص 160*110MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'مسلوب وفلنشة'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 661.12) < 0.01
  AND size = '160*110MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صمام عدم رجوع 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'صمامات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1014.10) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 240.03) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 63.04) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'سرج 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'سرج وجلبة سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 724.96) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 203.28) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'مسلوب 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 79.02) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 986.25) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1071.90) < 0.01
  AND size = '2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 2"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 32.58) < 0.01
  AND size = '2"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 2"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 571.85) < 0.01
  AND size = '2"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص سن 2"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 218.22) < 0.01
  AND size = '2"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 2"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 268.43) < 0.01
  AND size = '2"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 2"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 32.58) < 0.01
  AND size = '2"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 2"*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 944.39) < 0.01
  AND size = '2"*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 2"*3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 136.93) < 0.01
  AND size = '2"*3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 20*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 9.05) < 0.01
  AND size = '20*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون محول 20*3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 72.14) < 0.01
  AND size = '20*3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نقاص 200*160MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'مسلوب وفلنشة'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1628.07) < 0.01
  AND size = '200*160MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 25*3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 12.07) < 0.01
  AND size = '25*3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي 25MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'مسلوب وفلنشة'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 109.56) < 0.01
  AND size = '25MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 4389.58) < 0.01
  AND size = '3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 710.42) < 0.01
  AND size = '3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 2236.11) < 0.01
  AND size = '3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'مسلوب 3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 114.62) < 0.01
  AND size = '3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 3"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 85.66) < 0.01
  AND size = '3"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 3"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 407.78) < 0.01
  AND size = '3"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 3"*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 85.66) < 0.01
  AND size = '3"*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 3"*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 407.78) < 0.01
  AND size = '3"*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 72.14) < 0.01
  AND size = '3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 255.76) < 0.01
  AND size = '3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون انجليزي 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 61.54) < 0.01
  AND size = '3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'نبل سن 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 17.58) < 0.01
  AND size = '3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 355.90) < 0.01
  AND size = '3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'ناقص سن 3/4"*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'سرج وجلبة سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 48.49) < 0.01
  AND size = '3/4"*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 3/4"*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 6.03) < 0.01
  AND size = '3/4"*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 32*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 16.90) < 0.01
  AND size = '32*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 253.38) < 0.01
  AND size = '32*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 326.11) < 0.01
  AND size = '32*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص محول 32*3/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 44.26) < 0.01
  AND size = '32*3/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 258.22) < 0.01
  AND size = '32MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 484.99) < 0.01
  AND size = '32MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي 32MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'مسلوب وفلنشة'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 118.74) < 0.01
  AND size = '32MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 524.19) < 0.01
  AND size = '32MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 32MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 272.78) < 0.01
  AND size = '32MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون سن 4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات سن'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1091.69) < 0.01
  AND size = '4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 5549.56) < 0.01
  AND size = '4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'مسلوب 4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 188.20) < 0.01
  AND size = '4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 4472.82) < 0.01
  AND size = '4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 4"*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 135.72) < 0.01
  AND size = '4"*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص انجليزي 4"*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 506.10) < 0.01
  AND size = '4"*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 4"*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 132.71) < 0.01
  AND size = '4"*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'جلبة نقص محول انجليزي 4"*3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 132.71) < 0.01
  AND size = '4"*3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 40*1 1/4"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 22.32) < 0.01
  AND size = '40*1 1/4"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 40*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 450.38) < 0.01
  AND size = '40*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 50*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 38.01) < 0.01
  AND size = '50*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون محول 50*1 1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 186.69) < 0.01
  AND size = '50*1 1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص محول 50*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 86.69) < 0.01
  AND size = '50*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص محول 50*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 86.69) < 0.01
  AND size = '50*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 50MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 548.58) < 0.01
  AND size = '50MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 50MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 702.14) < 0.01
  AND size = '50MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص محول 63*1"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 127.91) < 0.01
  AND size = '63*1"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'تي نقص محول 63*1/2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 140.03) < 0.01
  AND size = '63*1/2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 63*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1038.95) < 0.01
  AND size = '63*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 63*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 51.27) < 0.01
  AND size = '63*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'يونيون محول 63*2"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محولات'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 272.78) < 0.01
  AND size = '63*2"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 63MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 819.52) < 0.01
  AND size = '63MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 63MM'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 1017.02) < 0.01
  AND size = '63MM'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'محبس كرة 90*3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'محابس'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 2119.11) < 0.01
  AND size = '90*3"'
  AND name LIKE 'كومر%';
UPDATE products SET name = 'صولة انجليزي 90*3"'
WHERE company = 'كومر'
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات لصق انجليزي'
                        AND category_id = (SELECT id FROM categories WHERE name = 'كومر'))
  AND ABS(retail_price - 214.75) < 0.01
  AND size = '90*3"'
  AND name LIKE 'كومر%';