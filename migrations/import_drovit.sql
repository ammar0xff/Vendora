INSERT INTO categories (id, name) SELECT gen_random_uuid(), 'دروفيت' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'دروفيت');

INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'STARCK 1'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'STARCK 1' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'HAPPY D.'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'X-LARGE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'DURASTYLE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'KETHO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'KETHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'CARO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'CARO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'L-CUBE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'DARLING'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'VITRIUM'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'VITRIUM' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'PURAVIDA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'VERO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'P3 COMFORTS'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'STARCK 3'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'D-NEO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'D-CODE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'ECHO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'DURAPLUS'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'EMILIA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'GOLF'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'SEPARATES'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'دروفيت'), 'ACCESSORIES'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت'));


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 1' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '460 mm 460 mm Ø 460 [0445460000]', 'قطعة', 24645.0, 0, 0, true, 'دروفيت', '0445460000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '460 mm 460 mm Ø 460 [0445460000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 1' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '580 mm 580 mm Ø 580 [0406580000]', 'قطعة', 32575.0, 0, 0, true, 'دروفيت', '0406580000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '580 mm 580 mm Ø 580 [0406580000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 1' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم650 x 390 [8727100005]', 'قطعة', 51215.0, 0, 0, true, 'دروفيت', '8727100005', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم650 x 390 [8727100005]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm   1000 mm 1000 x 525 [0417100027]', 'قطعة', 31525.0, 0, 0, true, 'دروفيت', '0417100027', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm   1000 mm 1000 x 525 [0417100027]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '430 mm  430 mm 430 x 280 [0336430000]', 'قطعة', 5210.0, 0, 0, true, 'دروفيت', '0336430000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '430 mm  430 mm 430 x 280 [0336430000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for stone counter topsحوض تحت الرخامة [0050280000]', 'قطعة', 915.0, 0, 0, true, 'دروفيت', '0050280000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for stone counter topsحوض تحت الرخامة [0050280000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1200 mm 1200 mm 1200 x 505 [0491120000]', 'قطعة', 20205.0, 0, 0, true, 'دروفيت', '0491120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1200 mm 1200 mm 1200 x 505 [0491120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1200 mm    1200 mm    1200 x 505 [0491120024]', 'قطعة', 20205.0, 0, 0, true, 'دروفيت', '0491120024', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1200 mm    1200 mm    1200 x 505 [0491120024]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 049112, 049180 049180 - #049112مع للاستخدام200 x 215 [0863190000]', 'قطعة', 9965.0, 0, 0, true, 'دروفيت', '0863190000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 049112, 049180 049180 - #049112مع للاستخدام200 x 215 [0863190000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for darling new #049983 049983لحوض دارلنج نيو522 x800 XL6062 17,885 20,430 [XL6062]', 'قطعة', 49983.0, 0, 0, true, 'دروفيت', 'XL6062', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for darling new #049983 049983لحوض دارلنج نيو522 x800 XL6062 17,885 20,430 [XL6062]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Vero # 045460 (not ground) 045460لحوض الفيرو445x550 XL6044 15,320 17,885 [XL6044]', 'قطعة', 45460.0, 0, 0, true, 'دروفيت', 'XL6044', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Vero # 045460 (not ground) 045460لحوض الفيرو445x550 XL6044 15,320 17,885 [XL6044]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Vero # 032985 (not ground) 032985لحوض فيرو470 x 800 XL6052 18,655 21,210 [XL6052]', 'قطعة', 32985.0, 0, 0, true, 'دروفيت', 'XL6052', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Vero # 032985 (not ground) 032985لحوض فيرو470 x 800 XL6052 18,655 21,210 [XL6052]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Vero # 032910 (not ground) 032910لحوض فيرو470 x 1000 XL6053 20,430 22,980 [XL6053]', 'قطعة', 32910.0, 0, 0, true, 'دروفيت', 'XL6053', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Vero # 032910 (not ground) 032910لحوض فيرو470 x 1000 XL6053 20,430 22,980 [XL6053]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Vero # 032912 (not ground) 032912لحوض فيرو470 x 1200 XL6054 21,210 23,760 [XL6054]', 'قطعة', 32912.0, 0, 0, true, 'دروفيت', 'XL6054', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Vero # 032912 (not ground) 032912لحوض فيرو470 x 1200 XL6054 21,210 23,760 [XL6054]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1200 mm. 1200 mm. 550 XL063C 6,375 [XL063]', 'قطعة', 1200.0, 0, 0, true, 'دروفيت', 'XL063', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1200 mm. 1200 mm. 550 XL063C 6,375 [XL063]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm. 800 mm. 550 XL025C 8,030 8,890 [XL025]', 'قطعة', 800.0, 0, 0, true, 'دروفيت', 'XL025', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm. 800 mm. 550 XL025C 8,030 8,890 [XL025]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm. 600 mm. 545 XL6717 21,455 22,980 [XL6717]', 'قطعة', 600.0, 0, 0, true, 'دروفيت', 'XL6717', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm. 600 mm. 545 XL6717 21,455 22,980 [XL6717]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm. 800 mm. 545 XL6714 24,260 26,545 [XL6714]', 'قطعة', 800.0, 0, 0, true, 'دروفيت', 'XL6714', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm. 800 mm. 545 XL6714 24,260 26,545 [XL6714]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm. 1000 mm. 545 XL6716 24,775 27,315 [XL6716]', 'قطعة', 1000.0, 0, 0, true, 'دروفيت', 'XL6716', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm. 1000 mm. 545 XL6716 24,775 27,315 [XL6716]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '300 mm. 300 mm. 545 XL6721 17,775 19,025 [XL6721]', 'قطعة', 300.0, 0, 0, true, 'دروفيت', 'XL6721', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '300 mm. 300 mm. 545 XL6721 17,775 19,025 [XL6721]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '400 mm. 400 mm. 545 XL6722 18,655 20,955 [XL6722]', 'قطعة', 400.0, 0, 0, true, 'دروفيت', 'XL6722', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '400 mm. 400 mm. 545 XL6722 18,655 20,955 [XL6722]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm. 500 mm. 545 XL6723 19,155 21,210 [XL6723]', 'قطعة', 500.0, 0, 0, true, 'دروفيت', 'XL6723', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm. 500 mm. 545 XL6723 19,155 21,210 [XL6723]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm. 600 mm. 545 XL6724 19,665 23,180 [XL6724]', 'قطعة', 600.0, 0, 0, true, 'دروفيت', 'XL6724', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm. 600 mm. 545 XL6724 19,665 23,180 [XL6724]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Chrome, glossingكروم لامع480 x 30 XL9928 2,555 [XL9928]', 'قطعة', 480.0, 0, 0, true, 'دروفيت', 'XL9928', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Chrome, glossingكروم لامع480 x 30 XL9928 2,555 [XL9928]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'grey, powder-coated 480 x 30 XL9927 1,140 [XL9927]', 'قطعة', 480.0, 0, 0, true, 'دروفيت', 'XL9927', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'grey, powder-coated 480 x 30 XL9927 1,140 [XL9927]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1600 mm. 1600 mm. 550 DS828 10,705 [DS828]', 'قطعة', 1600.0, 0, 0, true, 'دروفيت', 'DS828', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1600 mm. 1600 mm. 550 DS828 10,705 [DS828]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Chromeكروم لامعDS9933 2,555 [DS9933]', 'قطعة', 9933.0, 0, 0, true, 'دروفيت', 'DS9933', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Chromeكروم لامعDS9933 2,555 [DS9933]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KETHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for D-Code # 034812  034812 #للإستخدام مع1150 x 455 KT6669 21,635 [KT6669]', 'قطعة', 34812.0, 0, 0, true, 'دروفيت', 'KT6669', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for D-Code # 034812  034812 #للإستخدام مع1150 x 455 KT6669 21,635 [KT6669]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KETHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '231055, # 231060, # 231065 # 231055, # 231060, # 231065 400 x 360 KT6658 L/R 12, [KT6658]', 'قطعة', 231055.0, 0, 0, true, 'دروفيت', 'KT6658', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '231055, # 231060, # 231065 # 231055, # 231060, # 231065 400 x 360 KT6658 L/R 12, [KT6658]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CARO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Caro 046190  046190لحوض كارو460 X 550 CA9584 L/R 11,785 16,620 [CA9584]', 'قطعة', 46190.0, 0, 0, true, 'دروفيت', 'CA9584', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Caro 046190  046190لحوض كارو460 X 550 CA9584 L/R 11,785 16,620 [CA9584]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CARO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Caro 046114  046114لحوض كارو455 X 1100 CA9583 16,385 22,495 [CA9583]', 'قطعة', 46114.0, 0, 0, true, 'دروفيت', 'CA9583', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Caro 046114  046114لحوض كارو455 X 1100 CA9583 16,385 22,495 [CA9583]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '33285 كومفورت3لحوض بي820x481 LC6147 21,680 24,315 [LC6147]', 'قطعة', 33285.0, 0, 0, true, 'دروفيت', 'LC6147', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '33285 كومفورت3لحوض بي820x481 LC6147 21,680 24,315 [LC6147]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '33210 كومفورت3لحوض بي1020x620 LC6150 23,440 26,715 [LC6150]', 'قطعة', 33210.0, 0, 0, true, 'دروفيت', 'LC6150', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '33210 كومفورت3لحوض بي1020x620 LC6150 23,440 26,715 [LC6150]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '33212 كومفورت3لحوض بي1220x550 LC6153 26,060 29,335 [LC6153]', 'قطعة', 33212.0, 0, 0, true, 'دروفيت', 'LC6153', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '33212 كومفورت3لحوض بي1220x550 LC6153 26,060 29,335 [LC6153]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Darling # 040181 040181لحوض دارلينج300 x 810 DA6231 11,760 [DA6231]', 'قطعة', 40181.0, 0, 0, true, 'دروفيت', 'DA6231', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Darling # 040181 040181لحوض دارلينج300 x 810 DA6231 11,760 [DA6231]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for Darling # 040110 040110لحوض دارلينج300 x 1000 XL6435 13,285 [XL6435]', 'قطعة', 40110.0, 0, 0, true, 'دروفيت', 'XL6435', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for Darling # 040110 040110لحوض دارلينج300 x 1000 XL6435 13,285 [XL6435]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VITRIUM' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '460 mm   460 mm   Ø 460 [2662463271]', 'قطعة', 12560.0, 0, 0, true, 'دروفيت', '2662463271', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '460 mm   460 mm   Ø 460 [2662463271]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VITRIUM' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '460 mm 460 mm  Ø 460 [2661463279]', 'قطعة', 12930.0, 0, 0, true, 'دروفيت', '2661463279', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '460 mm 460 mm  Ø 460 [2661463279]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm   1000 mm   1000 x 525 [0371100000]', 'قطعة', 11130.0, 0, 0, true, 'دروفيت', '0371100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm   1000 mm   1000 x 525 [0371100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '700 mm  700 X 465 [0369700000]', 'قطعة', 7080.0, 0, 0, true, 'دروفيت', '0369700000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '700 mm  700 X 465 [0369700000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '700 mm   700 mm   700 x 500 [2701700000]', 'قطعة', 6945.0, 0, 0, true, 'دروفيت', '2701700000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '700 mm   700 mm   700 x 500 [2701700000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 270170 270170 # مع للاستخدام [0858100000]', 'قطعة', 4565.0, 0, 0, true, 'دروفيت', '0858100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 270170 270170 # مع للاستخدام [0858100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 270170 270170 # مع للاستخدام [0858120000]', 'قطعة', 3910.0, 0, 0, true, 'دروفيت', '0858120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 270170 270170 # مع للاستخدام [0858120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون360 x 630 [2119090000]', 'قطعة', 12625.0, 0, 0, true, 'دروفيت', '2119090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون360 x 630 [2119090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش360 x 630 [2119490075]', 'قطعة', 12790.0, 0, 0, true, 'دروفيت', '2119490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش360 x 630 [2119490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون360 x 545 [2219090000]', 'قطعة', 12485.0, 0, 0, true, 'دروفيت', '2219090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون360 x 545 [2219090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش360 x 545 [2219490075]', 'قطعة', 12650.0, 0, 0, true, 'دروفيت', '2219490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش360 x 545 [2219490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'included 360 x 630 [2247100000]', 'قطعة', 8630.0, 0, 0, true, 'دروفيت', '2247100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'included 360 x 630 [2247100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PURAVIDA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'includedأبيض360 x 545 [2247150000]', 'قطعة', 9470.0, 0, 0, true, 'دروفيت', '2247150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'includedأبيض360 x 545 [2247150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1250 mm 1250 mm 1250 x 490 [0329120000]', 'قطعة', 13145.0, 0, 0, true, 'دروفيت', '0329120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1250 mm 1250 mm 1250 x 490 [0329120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1050 mm 1050 mm 1050 x 490 [0329100000]', 'قطعة', 11070.0, 0, 0, true, 'دروفيت', '0329100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1050 mm 1050 mm 1050 x 490 [0329100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '850 mm   850 mm 850 x 490 [0329850000]', 'قطعة', 8975.0, 0, 0, true, 'دروفيت', '0329850000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '850 mm   850 mm 850 x 490 [0329850000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm      1000 mm      1000 x 470 [0454100024]', 'قطعة', 10725.0, 0, 0, true, 'دروفيت', '0454100024', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm      1000 mm      1000 x 470 [0454100024]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm 1000 mm 1000 x 470 [0454100000]', 'قطعة', 10725.0, 0, 0, true, 'دروفيت', '0454100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm 1000 mm 1000 x 470 [0454100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm 800 mm 800 x 470 [0454800000]', 'قطعة', 8290.0, 0, 0, true, 'دروفيت', '0454800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm 800 mm 800 x 470 [0454800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 600 x 470 [0454600027]', 'قطعة', 2900.0, 0, 0, true, 'دروفيت', '0454600027', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 600 x 470 [0454600027]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm 500 mm 500 x 470 [0454500000]', 'قطعة', 2765.0, 0, 0, true, 'دروفيت', '0454500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm 500 mm 500 x 470 [0454500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 600 x 470 [0452600000]', 'قطعة', 3550.0, 0, 0, true, 'دروفيت', '0452600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 600 x 470 [0452600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '450 mm 450 mm  450 x 350 [0704450000]', 'قطعة', 2755.0, 0, 0, true, 'دروفيت', '0704450000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '450 mm 450 mm  450 x 350 [0704450000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm 500 mm  500 x 465 [0315500000]', 'قطعة', 3535.0, 0, 0, true, 'دروفيت', '0315500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm 500 mm  500 x 465 [0315500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '485 mm • 485 mm • 485 x 315 [0330480000]', 'قطعة', 3385.0, 0, 0, true, 'دروفيت', '0330480000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '485 mm • 485 mm • 485 x 315 [0330480000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون370 x 630 [2116090000]', 'قطعة', 11790.0, 0, 0, true, 'دروفيت', '2116090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون370 x 630 [2116090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش370 x 630 [2116490075]', 'قطعة', 11955.0, 0, 0, true, 'دروفيت', '2116490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش370 x 630 [2116490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم380 x 160 [0909300001]', 'قطعة', 5980.0, 0, 0, true, 'دروفيت', '0909300001', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم380 x 160 [0909300001]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون370 x 540 [2217090000]', 'قطعة', 9025.0, 0, 0, true, 'دروفيت', '2217090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون370 x 540 [2217090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche, valveو المحبس بالدوش370 x 540 [2217490078]', 'قطعة', 9190.0, 0, 0, true, 'دروفيت', '2217490078', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche, valveو المحبس بالدوش370 x 540 [2217490078]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Universal chair supportشاسيه للمرحاض و البيديه [0014900094]', 'قطعة', 1725.0, 0, 0, true, 'دروفيت', '0014900094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Universal chair supportشاسيه للمرحاض و البيديه [0014900094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without douche   بدون دش370 x 570 [2240100000]', 'قطعة', 8470.0, 0, 0, true, 'دروفيت', '2240100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without douche   بدون دش370 x 570 [2240100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش370 x 570 [2240100030]', 'قطعة', 8470.0, 0, 0, true, 'دروفيت', '2240100030', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش370 x 570 [2240100030]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'VERO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with tap platformللخلاط بفتحة370 x 540 [2239150000]', 'قطعة', 8235.0, 0, 0, true, 'دروفيت', '2239150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with tap platformللخلاط بفتحة370 x 540 [2239150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm 650 mm 650 x 500 [2331650000]', 'قطعة', 4350.0, 0, 0, true, 'دروفيت', '2331650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm 650 mm 650 x 500 [2331650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '233212-233210-233285-233165 [0858360000]', 'قطعة', 2985.0, 0, 0, true, 'دروفيت', '0858360000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '233212-233210-233285-233165 [0858360000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 233165 233165للاستخدام مع [0858370000]', 'قطعة', 2330.0, 0, 0, true, 'دروفيت', '0858370000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 233165 233165للاستخدام مع [0858370000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm • 550 mm • 550 x 360 [0377550000]', 'قطعة', 4350.0, 0, 0, true, 'دروفيت', '0377550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm • 550 mm • 550 x 360 [0377550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '850 mm 850 mm 850 x 495 [2332850000]', 'قطعة', 7085.0, 0, 0, true, 'دروفيت', '2332850000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '850 mm 850 mm 850 x 495 [2332850000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1050 mm 1050 mm 1050 x 495 [2332100000]', 'قطعة', 9360.0, 0, 0, true, 'دروفيت', '2332100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1050 mm 1050 mm 1050 x 495 [2332100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1250 mm 1250 mm 1250 x 495 [2332120000]', 'قطعة', 11185.0, 0, 0, true, 'دروفيت', '2332120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1250 mm 1250 mm 1250 x 495 [2332120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش380 x 650 [2167090000]', 'قطعة', 6680.0, 0, 0, true, 'دروفيت', '2167090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش380 x 650 [2167090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش380 x 650 [2167490075]', 'قطعة', 6845.0, 0, 0, true, 'دروفيت', '2167490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش380 x 650 [2167490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق [0020490094]', 'قطعة', 3995.0, 0, 0, true, 'دروفيت', '0020490094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق [0020490094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeبضاغط كروم410 x 170 [0937500003]', 'قطعة', 4900.0, 0, 0, true, 'دروفيت', '0937500003', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeبضاغط كروم410 x 170 [0937500003]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش380 x 570 [2561090000]', 'قطعة', 6025.0, 0, 0, true, 'دروفيت', '2561090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش380 x 570 [2561090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدوش بالمحبس380 x 570 [2561490075]', 'قطعة', 6190.0, 0, 0, true, 'دروفيت', '2561490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدوش بالمحبس380 x 570 [2561490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'P3 COMFORTS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق [0020390094]', 'قطعة', 3995.0, 0, 0, true, 'دروفيت', '0020390094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق [0020390094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm 650 mm 650 x 485 [0300650000]', 'قطعة', 5110.0, 0, 0, true, 'دروفيت', '0300650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm 650 mm 650 x 485 [0300650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 600 x 450 [0300600000]', 'قطعة', 4870.0, 0, 0, true, 'دروفيت', '0300600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 600 x 450 [0300600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 550 x 430 [0300550000]', 'قطعة', 3830.0, 0, 0, true, 'دروفيت', '0300550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 550 x 430 [0300550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '700 mm 700 mm 700 x 490 [0304700000]', 'قطعة', 5520.0, 0, 0, true, 'دروفيت', '0304700000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '700 mm 700 mm 700 x 490 [0304700000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1050 mm 1050 mm 1050 x 485 [0304100000]', 'قطعة', 11955.0, 0, 0, true, 'دروفيت', '0304100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1050 mm 1050 mm 1050 x 485 [0304100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '030410, 030470 030470 ,030410 710 x 210 [0865160000]', 'قطعة', 2960.0, 0, 0, true, 'دروفيت', '0865160000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '030410, 030470 030470 ,030410 710 x 210 [0865160000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '030410, 030470 030470 ,030410 320 x 285 [0865150000]', 'قطعة', 2845.0, 0, 0, true, 'دروفيت', '0865150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '030410, 030470 030470 ,030410 320 x 285 [0865150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 550 x 460 [0310550000]', 'قطعة', 5720.0, 0, 0, true, 'دروفيت', '0310550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 550 x 460 [0310550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '490 mm    mm 490 490 x 365 [0305490000]', 'قطعة', 4920.0, 0, 0, true, 'دروفيت', '0305490000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '490 mm    mm 490 490 x 365 [0305490000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '480 mm  480 x 425 [0313480000]', 'قطعة', 4330.0, 0, 0, true, 'دروفيت', '0313480000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '480 mm  480 x 425 [0313480000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'xing included [0050011000]', 'قطعة', 7680.0, 0, 0, true, 'دروفيت', '0050011000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'xing included [0050011000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'X-LARGE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for mounting utility basinفي حالة عدم طلب الشبكة [0067121000]', 'قطعة', 2050.0, 0, 0, true, 'دروفيت', '0067121000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for mounting utility basinفي حالة عدم طلب الشبكة [0067121000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش360 x 655 [0128490075]', 'قطعة', 9130.0, 0, 0, true, 'دروفيت', '0128490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش360 x 655 [0128490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق [0063890094]', 'قطعة', 2700.0, 0, 0, true, 'دروفيت', '0063890094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق [0063890094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeكروم بضاغط390 x 370 [0920100004]', 'قطعة', 5520.0, 0, 0, true, 'دروفيت', '0920100004', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeكروم بضاغط390 x 370 [0920100004]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش420 x 740 [2104490075]', 'قطعة', 11620.0, 0, 0, true, 'دروفيت', '2104490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش420 x 740 [2104490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseالغلق ذاتي [0067790094]', 'قطعة', 4050.0, 0, 0, true, 'دروفيت', '0067790094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseالغلق ذاتي [0067790094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeكروم بضاغط470 x 210 [0928100004]', 'قطعة', 5920.0, 0, 0, true, 'دروفيت', '0928100004', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeكروم بضاغط470 x 210 [0928100004]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش360 x 560 [0124090000]', 'قطعة', 6070.0, 0, 0, true, 'دروفيت', '0124090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش360 x 560 [0124090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'With doucheبالدوش360 x 560 [0124490075]', 'قطعة', 6235.0, 0, 0, true, 'دروفيت', '0124490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'With doucheبالدوش360 x 560 [0124490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون360 x 540 [2200090000]', 'قطعة', 6045.0, 0, 0, true, 'دروفيت', '2200090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون360 x 540 [2200090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالمحبس بالدوش360 x 540 [2200490078]', 'قطعة', 6210.0, 0, 0, true, 'دروفيت', '2200490078', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالمحبس بالدوش360 x 540 [2200490078]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون360 x 560 [2230100000]', 'قطعة', 8005.0, 0, 0, true, 'دروفيت', '2230100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون360 x 560 [2230100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش360 x 560 [2230600000]', 'قطعة', 8005.0, 0, 0, true, 'دروفيت', '2230600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش360 x 560 [2230600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheدوش بدون360 x 540 [2230150000]', 'قطعة', 6470.0, 0, 0, true, 'دروفيت', '2230150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheدوش بدون360 x 540 [2230150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm   650 mm   650 x 440 [2366650000]', 'قطعة', 4695.0, 0, 0, true, 'دروفيت', '2366650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm   650 mm   650 x 440 [2366650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 440 [2366600000]', 'قطعة', 3800.0, 0, 0, true, 'دروفيت', '2366600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 440 [2366600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm   550 mm   550 x 440 [2366550000]', 'قطعة', 3290.0, 0, 0, true, 'دروفيت', '2366550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm   550 mm   550 x 440 [2366550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 236665, 236660, 236655 236655 ,236660  ,236665 # مع للاستخدام [0858420000]', 'قطعة', 2020.0, 0, 0, true, 'دروفيت', '0858420000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 236665, 236660, 236655 236655 ,236660  ,236665 # مع للاستخدام [0858420000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 236665, 236660, 236655 236655 ,236660  ,236665 # مع للاستخدام [0858430000]', 'قطعة', 1815.0, 0, 0, true, 'دروفيت', '0858430000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 236665, 236660, 236655 236655 ,236660  ,236665 # مع للاستخدام [0858430000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '450 mm   450 mm   450 x 335 [0738450000]', 'قطعة', 2290.0, 0, 0, true, 'دروفيت', '0738450000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '450 mm   450 mm   450 x 335 [0738450000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm [2367800000]', 'قطعة', 5650.0, 0, 0, true, 'دروفيت', '2367800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm [2367800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1005 mm   1005 mm [2367100000]', 'قطعة', 6735.0, 0, 0, true, 'دروفيت', '2367100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1005 mm   1005 mm [2367100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 mm • 600 x 400 [2372600070]', 'قطعة', 5315.0, 0, 0, true, 'دروفيت', '2372600070', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 mm • 600 x 400 [2372600070]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 x 400 [2372601370]', 'قطعة', 6460.0, 0, 0, true, 'دروفيت', '2372601370', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 x 400 [2372601370]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '400 mm • 400 mm • 400 x 400 [2371400070]', 'قطعة', 4105.0, 0, 0, true, 'دروفيت', '2371400070', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '400 mm • 400 mm • 400 x 400 [2371400070]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '400 mm • 400 x 400 [2371401370]', 'قطعة', 4980.0, 0, 0, true, 'دروفيت', '2371401370', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '400 mm • 400 x 400 [2371401370]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm •  600 mm • 600 x 435 [0358600079]', 'قطعة', 4925.0, 0, 0, true, 'دروفيت', '0358600079', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm •  600 mm • 600 x 435 [0358600079]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   560 x 455 [0357600027]', 'قطعة', 4525.0, 0, 0, true, 'دروفيت', '0357600027', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   560 x 455 [0357600027]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 370 x 650 [2002090000]', 'قطعة', 8495.0, 0, 0, true, 'دروفيت', '2002090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 370 x 650 [2002090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش 370 x 650 [2002490075]', 'قطعة', 8660.0, 0, 0, true, 'دروفيت', '2002490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش 370 x 650 [2002490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for bottom supplyتغذية سفلية395 x 180 [0944150094]', 'قطعة', 3865.0, 0, 0, true, 'دروفيت', '0944150094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for bottom supplyتغذية سفلية395 x 180 [0944150094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0021690000]', 'قطعة', 3835.0, 0, 0, true, 'دروفيت', '0021690000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0021690000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Slim - with Soft Closeالغلق ذاتي [0021890094]', 'قطعة', 3995.0, 0, 0, true, 'دروفيت', '0021890094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Slim - with Soft Closeالغلق ذاتي [0021890094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 370 x 540 [2577090000]', 'قطعة', 7205.0, 0, 0, true, 'دروفيت', '2577090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 370 x 540 [2577090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche & Valveبالدش والمحبس 370 x 540 [2577490078]', 'قطعة', 7370.0, 0, 0, true, 'دروفيت', '2577490078', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche & Valveبالدش والمحبس 370 x 540 [2577490078]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0021691394]', 'قطعة', 4855.0, 0, 0, true, 'دروفيت', '0021691394', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0021691394]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Slim Black - with Soft Closeالغلق ذاتي [0021891394]', 'قطعة', 4955.0, 0, 0, true, 'دروفيت', '0021891394', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Slim Black - with Soft Closeالغلق ذاتي [0021891394]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-NEO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Fixings and ceramic coveredالتثبيت مجموعة شامل370 x 540 [2294150000]', 'قطعة', 6665.0, 0, 0, true, 'دروفيت', '2294150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Fixings and ceramic coveredالتثبيت مجموعة شامل370 x 540 [2294150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 440 [2319600000]', 'قطعة', 3100.0, 0, 0, true, 'دروفيت', '2319600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 440 [2319600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm   800 x 480 [2325800000]', 'قطعة', 6170.0, 0, 0, true, 'دروفيت', '2325800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm   800 x 480 [2325800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm   800 x 480 [2326800000]', 'قطعة', 6170.0, 0, 0, true, 'دروفيت', '2326800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm   800 x 480 [2326800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm   800 x 480 [2320800000]', 'قطعة', 6170.0, 0, 0, true, 'دروفيت', '2320800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm   800 x 480 [2320800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 231960, 232680, 232580, 232080232080 ,232580 ,232680 ,231960 # مع للاستخدا [0858290000]', 'قطعة', 2020.0, 0, 0, true, 'دروفيت', '0858290000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 231960, 232680, 232580, 232080232080 ,232580 ,232680 ,231960 # مع للاستخدا [0858290000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 231960, 232680, 232580, 232080232080 ,232580 ,232680 ,231960 # مع للاستخدا [0858300000]', 'قطعة', 1815.0, 0, 0, true, 'دروفيت', '0858300000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 231960, 232680, 232580, 232080232080 ,232580 ,232680 ,231960 # مع للاستخدا [0858300000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 mm • 600 x 380 [0349600000]', 'قطعة', 5245.0, 0, 0, true, 'دروفيت', '0349600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 mm • 600 x 380 [0349600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 mm • 600 x 380 [0349601300]', 'قطعة', 6525.0, 0, 0, true, 'دروفيت', '0349601300', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 mm • 600 x 380 [0349601300]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '615 mm   615 mm   615 x 495 [0374620000]', 'قطعة', 4845.0, 0, 0, true, 'دروفيت', '0374620000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '615 mm   615 mm   615 x 495 [0374620000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '560 mm   560 mm   560 x 455 [0374560000]', 'قطعة', 4580.0, 0, 0, true, 'دروفيت', '0374560000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '560 mm   560 mm   560 x 455 [0374560000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without douche بدون دش370 x 700 [2156090000]', 'قطعة', 10615.0, 0, 0, true, 'دروفيت', '2156090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without douche بدون دش370 x 700 [2156090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدش370 x 700 [2156490075]', 'قطعة', 10780.0, 0, 0, true, 'دروفيت', '2156490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدش370 x 700 [2156490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for bottom supplyتغذية سفلية390 x 170 [0935500001]', 'قطعة', 4020.0, 0, 0, true, 'دروفيت', '0935500001', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for bottom supplyتغذية سفلية390 x 170 [0935500001]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0060590000]', 'قطعة', 3485.0, 0, 0, true, 'دروفيت', '0060590000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0060590000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without douche بدون دش370 x 630 [2155090000]', 'قطعة', 9365.0, 0, 0, true, 'دروفيت', '2155090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without douche بدون دش370 x 630 [2155090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدش370 x 630 [2155490075]', 'قطعة', 9530.0, 0, 0, true, 'دروفيت', '2155490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدش370 x 630 [2155490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0063790000]', 'قطعة', 3415.0, 0, 0, true, 'دروفيت', '0063790000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0063790000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without douche بدون دش370 x 620 [2542090000]', 'قطعة', 9375.0, 0, 0, true, 'دروفيت', '2542090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without douche بدون دش370 x 620 [2542090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche بالدش370 x 620 [2542490075]', 'قطعة', 9540.0, 0, 0, true, 'دروفيت', '2542490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche بالدش370 x 620 [2542490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0060591394]', 'قطعة', 5010.0, 0, 0, true, 'دروفيت', '0060591394', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0060591394]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURASTYLE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Fixings and ceramic coveredالتثبيت مجموعة شامل370 x 630 [2283100000]', 'قطعة', 19530.0, 0, 0, true, 'دروفيت', '2283100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Fixings and ceramic coveredالتثبيت مجموعة شامل370 x 630 [2283100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '830 mm 830 mm 830 x 545 [0499830000]', 'قطعة', 10940.0, 0, 0, true, 'دروفيت', '0499830000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '830 mm 830 mm 830 x 545 [0499830000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm 650 mm 650 x 550 [2621650000]', 'قطعة', 3885.0, 0, 0, true, 'دروفيت', '2621650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm 650 mm 650 x 550 [2621650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 550 x 480 [2621550000]', 'قطعة', 3305.0, 0, 0, true, 'دروفيت', '2621550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 550 x 480 [2621550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 262165, 262155 262155 ,262165لـ [0858240000]', 'قطعة', 1865.0, 0, 0, true, 'دروفيت', '0858240000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 262165, 262155 262155 ,262165لـ [0858240000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 262165, 262155 262155 ,262165لـ [0858250000]', 'قطعة', 1750.0, 0, 0, true, 'دروفيت', '0858250000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 262165, 262155 262155 ,262165لـ [0858250000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '470 mm 470 mm Ø 470 [0497470000]', 'قطعة', 4405.0, 0, 0, true, 'دروفيت', '0497470000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '470 mm 470 mm Ø 470 [0497470000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش370 x 630 [2138090000]', 'قطعة', 8465.0, 0, 0, true, 'دروفيت', '2138090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش370 x 630 [2138090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش370 x 630 [2138490075]', 'قطعة', 8630.0, 0, 0, true, 'دروفيت', '2138490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش370 x 630 [2138490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق [0069890094]', 'قطعة', 4710.0, 0, 0, true, 'دروفيت', '0069890094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق [0069890094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش370 x 620 [2544090000]', 'قطعة', 8535.0, 0, 0, true, 'دروفيت', '2544090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش370 x 620 [2544090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش370 x 620 [2544490075]', 'قطعة', 8700.0, 0, 0, true, 'دروفيت', '2544490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش370 x 620 [2544490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق [0063390094]', 'قطعة', 3460.0, 0, 0, true, 'دروفيت', '0063390094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق [0063390094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'xings includedشامل مجموعة التثبيت370 x 630 [2251100000]', 'قطعة', 8590.0, 0, 0, true, 'دروفيت', '2251100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'xings includedشامل مجموعة التثبيت370 x 630 [2251100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DARLING' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Durafix includedشامل مجموعة التثبيت370 x 540 [2249150000]', 'قطعة', 8235.0, 0, 0, true, 'دروفيت', '2249150000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Durafix includedشامل مجموعة التثبيت370 x 540 [2249150000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm   650 mm   650 x 495 [2316650000]', 'قطعة', 2750.0, 0, 0, true, 'دروفيت', '2316650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm   650 mm   650 x 495 [2316650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 475 [2316600000]', 'قطعة', 2585.0, 0, 0, true, 'دروفيت', '2316600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 475 [2316600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 231660, 231665  231665 ,231660  #مع  للاستخدام 170 [0858270000]', 'قطعة', 1320.0, 0, 0, true, 'دروفيت', '0858270000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 231660, 231665  231665 ,231660  #مع  للاستخدام 170 [0858270000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 231660, 231665  231665 ,231660  #مع  للاستخدام 210 x 310 [0858280000]', 'قطعة', 870.0, 0, 0, true, 'دروفيت', '0858280000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 231660, 231665  231665 ,231660  #مع  للاستخدام 210 x 310 [0858280000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 mm • 600 x 400 [2359600000]', 'قطعة', 3195.0, 0, 0, true, 'دروفيت', '2359600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 mm • 600 x 400 [2359600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '400 mm • 400 mm • 400 x 400 [2359400000]', 'قطعة', 3025.0, 0, 0, true, 'دروفيت', '2359400000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '400 mm • 400 mm • 400 x 400 [2359400000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 460 [2360600000]', 'قطعة', 3395.0, 0, 0, true, 'دروفيت', '2360600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 460 [2360600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm   500 mm   500 x 400 [2360500000]', 'قطعة', 2965.0, 0, 0, true, 'دروفيت', '2360500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm   500 mm   500 x 400 [2360500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm   500 mm   500 x 360 [0710500000]', 'قطعة', 2415.0, 0, 0, true, 'دروفيت', '0710500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm   500 mm   500 x 360 [0710500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1200 mm   1200 mm   1200 x 505 [2318120000]', 'قطعة', 6425.0, 0, 0, true, 'دروفيت', '2318120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1200 mm   1200 mm   1200 x 505 [2318120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1000 mm   1000 mm   1000 x 505 [2318100000]', 'قطعة', 5430.0, 0, 0, true, 'دروفيت', '2318100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1000 mm   1000 mm   1000 x 505 [2318100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm   800 x 505 [2318800000]', 'قطعة', 4450.0, 0, 0, true, 'دروفيت', '2318800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm   800 x 505 [2318800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm   650 mm   650 x 505 [2318650000]', 'قطعة', 4290.0, 0, 0, true, 'دروفيت', '2318650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm   650 mm   650 x 505 [2318650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 505 [2318600000]', 'قطعة', 4120.0, 0, 0, true, 'دروفيت', '2318600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 505 [2318600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm   500 mm   500 x 360 [0709500000]', 'قطعة', 2405.0, 0, 0, true, 'دروفيت', '0709500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm   500 mm   500 x 360 [0709500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for # 070950  070950  #مع  للاستخدام 180 x 250 [0858320000]', 'قطعة', 865.0, 0, 0, true, 'دروفيت', '0858320000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for # 070950  070950  #مع  للاستخدام 180 x 250 [0858320000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '520 mm • 520 mm • 520 x 385 [0457480000]', 'قطعة', 2585.0, 0, 0, true, 'دروفيت', '0457480000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '520 mm • 520 mm • 520 x 385 [0457480000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm • 600 mm • 600 x 400 [2314600000]', 'قطعة', 3195.0, 0, 0, true, 'دروفيت', '2314600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm • 600 mm • 600 x 400 [2314600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش365 x 630 [2134090000]', 'قطعة', 7235.0, 0, 0, true, 'دروفيت', '2134090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش365 x 630 [2134090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche & Valveبالدش و المحبس365 x 630 [2134490075]', 'قطعة', 7400.0, 0, 0, true, 'دروفيت', '2134490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche & Valveبالدش و المحبس365 x 630 [2134490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق359 x 430 [0064590000]', 'قطعة', 3620.0, 0, 0, true, 'دروفيت', '0064590000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق359 x 430 [0064590000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Chrome push buttonبضاغط كروم395 x 160 [0934150094]', 'قطعة', 3080.0, 0, 0, true, 'دروفيت', '0934150094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Chrome push buttonبضاغط كروم395 x 160 [0934150094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش365 x 540 [2222090000]', 'قطعة', 6815.0, 0, 0, true, 'دروفيت', '2222090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش365 x 540 [2222090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche & Valveبالدش والمحبس365 x 540 [2222490075]', 'قطعة', 6980.0, 0, 0, true, 'دروفيت', '2222490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche & Valveبالدش والمحبس365 x 540 [2222490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 460 [2315600000]', 'قطعة', 3085.0, 0, 0, true, 'دروفيت', '2315600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 460 [2315600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش365 x 620 [2550090000]', 'قطعة', 7680.0, 0, 0, true, 'دروفيت', '2550090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش365 x 620 [2550090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with douche & Valveبالدش والمحبس365 x 620 [2550490075]', 'قطعة', 7845.0, 0, 0, true, 'دروفيت', '2550490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with douche & Valveبالدش والمحبس365 x 620 [2550490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'SoftCloseذاتي الغلق359 x 430 [0064690000]', 'قطعة', 2900.0, 0, 0, true, 'دروفيت', '0064690000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SoftCloseذاتي الغلق359 x 430 [0064690000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '800 mm   800 mm   800 x 460 [2375800000]', 'قطعة', 4135.0, 0, 0, true, 'دروفيت', '2375800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '800 mm   800 mm   800 x 460 [2375800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm   650 mm   650 x 460 [2375650000]', 'قطعة', 2805.0, 0, 0, true, 'دروفيت', '2375650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm   650 mm   650 x 460 [2375650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm   600 mm   600 x 460 [2375600000]', 'قطعة', 2700.0, 0, 0, true, 'دروفيت', '2375600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm   600 mm   600 x 460 [2375600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm  550 mm   550 x 460 [2375550000]', 'قطعة', 2600.0, 0, 0, true, 'دروفيت', '2375550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm  550 mm   550 x 460 [2375550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Siphon Coverعامود معلق [0858450000]', 'قطعة', 1815.0, 0, 0, true, 'دروفيت', '0858450000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Siphon Coverعامود معلق [0858450000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Pedestalعامود حوض [0858440000]', 'قطعة', 2020.0, 0, 0, true, 'دروفيت', '0858440000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pedestalعامود حوض [0858440000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm   500 mm   500 x 400 [0743500000]', 'قطعة', 2535.0, 0, 0, true, 'دروفيت', '0743500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm   500 mm   500 x 400 [0743500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '450 mm   450 mm   450 x 350 [0743450000]', 'قطعة', 2355.0, 0, 0, true, 'دروفيت', '0743450000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '450 mm   450 mm   450 x 350 [0743450000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '545 mm   545 mm   545 x 435 [0355550027]', 'قطعة', 3370.0, 0, 0, true, 'دروفيت', '0355550027', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '545 mm   545 mm   545 x 435 [0355550027]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm   550 mm   550 x 460 [0376550000]', 'قطعة', 4590.0, 0, 0, true, 'دروفيت', '0376550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm   550 mm   550 x 460 [0376550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 365 x 540 [2562090000]', 'قطعة', 5705.0, 0, 0, true, 'دروفيت', '2562090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 365 x 540 [2562090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش 365 x 540 [2562490075]', 'قطعة', 5870.0, 0, 0, true, 'دروفيت', '2562490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش 365 x 540 [2562490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0020790000]', 'قطعة', 2665.0, 0, 0, true, 'دروفيت', '0020790000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0020790000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 365 x 650 [2512090000]', 'قطعة', 6270.0, 0, 0, true, 'دروفيت', '2512090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 365 x 650 [2512090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش 365 x 650 [2512490075]', 'قطعة', 6435.0, 0, 0, true, 'دروفيت', '2512490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش 365 x 650 [2512490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0026190000]', 'قطعة', 2110.0, 0, 0, true, 'دروفيت', '0026190000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0026190000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 325 x 480 [2574090000]', 'قطعة', 4575.0, 0, 0, true, 'دروفيت', '2574090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 325 x 480 [2574090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش 325 x 480 [2574490075]', 'قطعة', 4740.0, 0, 0, true, 'دروفيت', '2574490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش 325 x 480 [2574490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closeالغلق ذاتي [0021390000]', 'قطعة', 1860.0, 0, 0, true, 'دروفيت', '0021390000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closeالغلق ذاتي [0021390000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دش 365 x 650 [2182090000]', 'قطعة', 7710.0, 0, 0, true, 'دروفيت', '2182090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دش 365 x 650 [2182090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدش 365 x 650 [2182490075]', 'قطعة', 7890.0, 0, 0, true, 'دروفيت', '2182490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدش 365 x 650 [2182490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650  650 650 x 480 [0342650000]', 'قطعة', 3465.0, 0, 0, true, 'دروفيت', '0342650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650  650 650 x 480 [0342650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '850  850 850 x 480 [0342850000]', 'قطعة', 5350.0, 0, 0, true, 'دروفيت', '0342850000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '850  850 850 x 480 [0342850000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1050  1050 1050 x 480 [0342100000]', 'قطعة', 7085.0, 0, 0, true, 'دروفيت', '0342100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1050  1050 1050 x 480 [0342100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm  mm 600 600 x 550 [2312600000]', 'قطعة', 3210.0, 0, 0, true, 'دروفيت', '2312600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm  mm 600 600 x 550 [2312600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '360 mm 360 mm 360 x 270 [0705360000]', 'قطعة', 1750.0, 0, 0, true, 'دروفيت', '0705360000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '360 mm 360 mm 360 x 270 [0705360000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '560 mm    mm 560 560 x 400 [0338560000]', 'قطعة', 3420.0, 0, 0, true, 'دروفيت', '0338560000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '560 mm    mm 560 560 x 400 [0338560000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1200 mm   mm 1200 1200 x 480 [0348120000]', 'قطعة', 10545.0, 0, 0, true, 'دروفيت', '0348120000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1200 mm   mm 1200 1200 x 480 [0348120000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش355 x 650 [2118090000]', 'قطعة', 7240.0, 0, 0, true, 'دروفيت', '2118090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش355 x 650 [2118090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش355 x 650 [2118490075]', 'قطعة', 7415.0, 0, 0, true, 'دروفيت', '2118490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش355 x 650 [2118490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'hinges includedشامل المفصلات [0067910000]', 'قطعة', 1230.0, 0, 0, true, 'دروفيت', '0067910000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'hinges includedشامل المفصلات [0067910000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Softclose Pergamonذاتي الغلق برجامون [0067394700]', 'قطعة', 2985.0, 0, 0, true, 'دروفيت', '0067394700', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Softclose Pergamonذاتي الغلق برجامون [0067394700]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Without doucheبدون دوش355 x 545 [2535090000]', 'قطعة', 5515.0, 0, 0, true, 'دروفيت', '2535090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Without doucheبدون دوش355 x 545 [2535090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'With doucheبالدوش355 x 545 [2535490075]', 'قطعة', 5680.0, 0, 0, true, 'دروفيت', '2535490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'With doucheبالدوش355 x 545 [2535490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش335 x 480 [2211090000]', 'قطعة', 5075.0, 0, 0, true, 'دروفيت', '2211090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش335 x 480 [2211090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش بدون المحبس335 x 480 [2211490075]', 'قطعة', 5240.0, 0, 0, true, 'دروفيت', '2211490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش بدون المحبس335 x 480 [2211490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'hinges includedشامل المفصلات [0060310094]', 'قطعة', 4125.0, 0, 0, true, 'دروفيت', '0060310094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'hinges includedشامل المفصلات [0060310094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Seat ring D-Code, elongatedسيديلي بدون غطاء شامل المفصلات [0060910000]', 'قطعة', 3705.0, 0, 0, true, 'دروفيت', '0060910000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat ring D-Code, elongatedسيديلي بدون غطاء شامل المفصلات [0060910000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Without doucheبدون دوش355 x 560 [2241100000]', 'قطعة', 4780.0, 0, 0, true, 'دروفيت', '2241100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Without doucheبدون دوش355 x 560 [2241100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'With doucheبالدوش355 x 560 [2241600000]', 'قطعة', 4780.0, 0, 0, true, 'دروفيت', '2241600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'With doucheبالدوش355 x 560 [2241600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01990 21,300 [KT01990]', 'قطعة', 1990.0, 0, 0, true, 'دروفيت', 'KT01990', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01990 21,300 [KT01990]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01950 24,160 [KT01950]', 'قطعة', 1950.0, 0, 0, true, 'دروفيت', 'KT01950', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01950 24,160 [KT01950]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01980 26,160 [KT01980]', 'قطعة', 1980.0, 0, 0, true, 'دروفيت', 'KT01980', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01980 26,160 [KT01980]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01960 15,405 [KT01960]', 'قطعة', 1960.0, 0, 0, true, 'دروفيت', 'KT01960', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01960 15,405 [KT01960]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01970 17,595 [KT01970]', 'قطعة', 1970.0, 0, 0, true, 'دروفيت', 'KT01970', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01970 17,595 [KT01970]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT01940 19,910 [KT01940]', 'قطعة', 1940.0, 0, 0, true, 'دروفيت', 'KT01940', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT01940 19,910 [KT01940]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01960 [XB01960]', 'قطعة', 1960.0, 0, 0, true, 'دروفيت', 'XB01960', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01960 [XB01960]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01970 [XB01970]', 'قطعة', 1970.0, 0, 0, true, 'دروفيت', 'XB01970', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01970 [XB01970]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01940 [XB01940]', 'قطعة', 1940.0, 0, 0, true, 'دروفيت', 'XB01940', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01940 [XB01940]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01910 [XB01910]', 'قطعة', 1910.0, 0, 0, true, 'دروفيت', 'XB01910', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01910 [XB01910]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01900 [XB01900]', 'قطعة', 1900.0, 0, 0, true, 'دروفيت', 'XB01900', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01900 [XB01900]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01990 [XB01990]', 'قطعة', 1990.0, 0, 0, true, 'دروفيت', 'XB01990', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01990 [XB01990]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01950 [XB01950]', 'قطعة', 1950.0, 0, 0, true, 'دروفيت', 'XB01950', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01950 [XB01950]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01980 [XB01980]', 'قطعة', 1980.0, 0, 0, true, 'دروفيت', 'XB01980', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01980 [XB01980]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01930 [XB01930]', 'قطعة', 1930.0, 0, 0, true, 'دروفيت', 'XB01930', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01930 [XB01930]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STARCK 3' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'XB01920 [XB01920]', 'قطعة', 1920.0, 0, 0, true, 'دروفيت', 'XB01920', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'XB01920 [XB01920]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'WF7202004010 17,255 [WF7202004010]', 'قطعة', 7202004010.0, 0, 0, true, 'دروفيت', 'WF7202004010', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'WF7202004010 17,255 [WF7202004010]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'HAPPY D.' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'WF7202015010 16,580 [WF7202015010]', 'قطعة', 7202015010.0, 0, 0, true, 'دروفيت', 'WF7202015010', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'WF7202015010 16,580 [WF7202015010]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'WF7202014010 16,035 [WF7202014010]', 'قطعة', 7202014010.0, 0, 0, true, 'دروفيت', 'WF7202014010', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'WF7202014010 16,035 [WF7202014010]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'WF7202008010 14,510 [WF7202008010]', 'قطعة', 7202008010.0, 0, 0, true, 'دروفيت', 'WF7202008010', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'WF7202008010 14,510 [WF7202008010]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'WF7202010010 14,330 [WF7202010010]', 'قطعة', 7202010010.0, 0, 0, true, 'دروفيت', 'WF7202010010', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'WF7202010010 14,330 [WF7202010010]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 595 x 470 [3212600000]', 'قطعة', 1930.0, 0, 0, true, 'دروفيت', '3212600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 595 x 470 [3212600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 321260 321260لـ [0865020000]', 'قطعة', 1050.0, 0, 0, true, 'دروفيت', '0865020000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 321260 321260لـ [0865020000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 321260 321260لـ [0871000000]', 'قطعة', 995.0, 0, 0, true, 'دروفيت', '0871000000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 321260 321260لـ [0871000000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش695 x 365 [0109090000]', 'قطعة', 4590.0, 0, 0, true, 'دروفيت', '0109090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش695 x 365 [0109090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش695 x 365 [0109490075]', 'قطعة', 4725.0, 0, 0, true, 'دروفيت', '0109490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش695 x 365 [0109490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'hinges includedشامل المفصلات [0060600000]', 'قطعة', 895.0, 0, 0, true, 'دروفيت', '0060600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'hinges includedشامل المفصلات [0060600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with Soft Closureذاتي الغلق [0020990094]', 'قطعة', 1630.0, 0, 0, true, 'دروفيت', '0020990094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with Soft Closureذاتي الغلق [0020990094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ECHO' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeبضاغط كروم [0918000002]', 'قطعة', 1980.0, 0, 0, true, 'دروفيت', '0918000002', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeبضاغط كروم [0918000002]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 600 x 495 [0344600000]', 'قطعة', 1665.0, 0, 0, true, 'دروفيت', '0344600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 600 x 495 [0344600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 550 x 440 [0344550000]', 'قطعة', 1450.0, 0, 0, true, 'دروفيت', '0344550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 550 x 440 [0344550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 034455 - 034460 034460 - 034455لـ [0863300000]', 'قطعة', 995.0, 0, 0, true, 'دروفيت', '0863300000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 034455 - 034460 034460 - 034455لـ [0863300000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 034455 - 034460 034460 - 034455لـ [0863350000]', 'قطعة', 985.0, 0, 0, true, 'دروفيت', '0863350000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 034455 - 034460 034460 - 034455لـ [0863350000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش355 x 645 [0229090000]', 'قطعة', 3845.0, 0, 0, true, 'دروفيت', '0229090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش355 x 645 [0229090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش355 x 645 [0229490075]', 'قطعة', 3985.0, 0, 0, true, 'دروفيت', '0229490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش355 x 645 [0229490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش355 x 645 [0229010000]', 'قطعة', 3845.0, 0, 0, true, 'دروفيت', '0229010000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش355 x 645 [0229010000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش355 x 645 [0229410075]', 'قطعة', 3985.0, 0, 0, true, 'دروفيت', '0229410075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش355 x 645 [0229410075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'hinges includedشامل المفصلات [0066300000]', 'قطعة', 985.0, 0, 0, true, 'دروفيت', '0066300000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'hinges includedشامل المفصلات [0066300000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with plastic hingesبمفصلات بلاستيك [8700800000]', 'قطعة', 790.0, 0, 0, true, 'دروفيت', '8700800000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with plastic hingesبمفصلات بلاستيك [8700800000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeبضاغط كروم385 x 180 [0879210084]', 'قطعة', 2025.0, 0, 0, true, 'دروفيت', '0879210084', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeبضاغط كروم385 x 180 [0879210084]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش360 x 640 [0230090000]', 'قطعة', 3960.0, 0, 0, true, 'دروفيت', '0230090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش360 x 640 [0230090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DURAPLUS' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش360 x 640 [0230490075]', 'قطعة', 4100.0, 0, 0, true, 'دروفيت', '0230490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش360 x 640 [0230490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 595 x 470 [0429600051]', 'قطعة', 1425.0, 0, 0, true, 'دروفيت', '0429600051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 595 x 470 [0429600051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 545 x 470 [0429550051]', 'قطعة', 1205.0, 0, 0, true, 'دروفيت', '0429550051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 545 x 470 [0429550051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 042960-042955 042955-042960لـ [0865030000]', 'قطعة', 995.0, 0, 0, true, 'دروفيت', '0865030000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 042960-042955 042955-042960لـ [0865030000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش655 x 365 [2059090000]', 'قطعة', 3665.0, 0, 0, true, 'دروفيت', '2059090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش655 x 365 [2059090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش655 x 365 [2059490075]', 'قطعة', 3805.0, 0, 0, true, 'دروفيت', '2059490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش655 x 365 [2059490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'EMILIA' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeبضاغط كروم [0952500094]', 'قطعة', 1575.0, 0, 0, true, 'دروفيت', '0952500094', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeبضاغط كروم [0952500094]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 mm 600 mm 595 x 470 [3312600000]', 'قطعة', 1250.0, 0, 0, true, 'دروفيت', '3312600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 mm 600 mm 595 x 470 [3312600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '550 mm 550 mm 545 x 470 [0331550000]', 'قطعة', 1270.0, 0, 0, true, 'دروفيت', '0331550000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '550 mm 550 mm 545 x 470 [0331550000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش655 x 365 [0232090000]', 'قطعة', 3475.0, 0, 0, true, 'دروفيت', '0232090000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش655 x 365 [0232090000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش655 x 365 [0232490075]', 'قطعة', 3615.0, 0, 0, true, 'دروفيت', '0232490075', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش655 x 365 [0232490075]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'GOLF' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with push-button chromeبضاغط كروم [8726300001]', 'قطعة', 1505.0, 0, 0, true, 'دروفيت', '8726300001', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with push-button chromeبضاغط كروم [8726300001]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'mm 730  mm 730 730 x 560 [0429700051]', 'قطعة', 3190.0, 0, 0, true, 'دروفيت', '0429700051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'mm 730  mm 730 730 x 560 [0429700051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'mm 480  mm 480 480 x 380 [0429480051]', 'قطعة', 1520.0, 0, 0, true, 'دروفيت', '0429480051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'mm 480  mm 480 480 x 380 [0429480051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 042970 042970 لـ [0865060000]', 'قطعة', 860.0, 0, 0, true, 'دروفيت', '0865060000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 042970 042970 لـ [0865060000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 042948 042948 لـ [0865050000]', 'قطعة', 860.0, 0, 0, true, 'دروفيت', '0865050000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 042948 042948 لـ [0865050000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'mm 590  mm 590 590 x 470 [0433590051]', 'قطعة', 2045.0, 0, 0, true, 'دروفيت', '0433590051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'mm 590  mm 590 590 x 470 [0433590051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'without doucheبدون دوش550 x 350 [0251090051]', 'قطعة', 4575.0, 0, 0, true, 'دروفيت', '0251090051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'without doucheبدون دوش550 x 350 [0251090051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with doucheبالدوش550 x 350 [0251490076]', 'قطعة', 4715.0, 0, 0, true, 'دروفيت', '0251490076', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with doucheبالدوش550 x 350 [0251490076]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'frosted glassطبق زجاجي [0099001000]', 'قطعة', 1900.0, 0, 0, true, 'دروفيت', '0099001000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'frosted glassطبق زجاجي [0099001000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'frosted glassطبق زجاجي [0099101000]', 'قطعة', 1900.0, 0, 0, true, 'دروفيت', '0099101000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'frosted glassطبق زجاجي [0099101000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'frosted glassطبق زجاجي [0099011000]', 'قطعة', 1880.0, 0, 0, true, 'دروفيت', '0099011000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'frosted glassطبق زجاجي [0099011000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'frosted glassطبق زجاجي [0099111000]', 'قطعة', 1880.0, 0, 0, true, 'دروفيت', '0099111000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'frosted glassطبق زجاجي [0099111000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099061000]', 'قطعة', 1600.0, 0, 0, true, 'دروفيت', '0099061000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099061000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099041000]', 'قطعة', 590.0, 0, 0, true, 'دروفيت', '0099041000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099041000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم445 [0099051000]', 'قطعة', 3600.0, 0, 0, true, 'دروفيت', '0099051000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم445 [0099051000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم830 [0099071000]', 'قطعة', 3300.0, 0, 0, true, 'دروفيت', '0099071000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم830 [0099071000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم630 [0099081000]', 'قطعة', 2900.0, 0, 0, true, 'دروفيت', '0099081000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم630 [0099081000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم630 x 220 [0099131000]', 'قطعة', 8500.0, 0, 0, true, 'دروفيت', '0099131000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم630 x 220 [0099131000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099021000]', 'قطعة', 1600.0, 0, 0, true, 'دروفيت', '0099021000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099021000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'frosted glassبكاس زجاجي [0099031000]', 'قطعة', 2750.0, 0, 0, true, 'دروفيت', '0099031000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'frosted glassبكاس زجاجي [0099031000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099121000]', 'قطعة', 4450.0, 0, 0, true, 'دروفيت', '0099121000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099121000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099281000]', 'قطعة', 3700.0, 0, 0, true, 'دروفيت', '0099281000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099281000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099141000]', 'قطعة', 3100.0, 0, 0, true, 'دروفيت', '0099141000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099141000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099151000]', 'قطعة', 1950.0, 0, 0, true, 'دروفيت', '0099151000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099151000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'chromeكروم [0099161000]', 'قطعة', 3050.0, 0, 0, true, 'دروفيت', '0099161000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'chromeكروم [0099161000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '500 mm  500 mm 500 x 350 [0380500000]', 'قطعة', 5790.0, 0, 0, true, 'دروفيت', '0380500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '500 mm  500 mm 500 x 350 [0380500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '700 mm 700 mm 700 x 400 [0380700000]', 'قطعة', 6225.0, 0, 0, true, 'دروفيت', '0380700000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '700 mm 700 mm 700 x 400 [0380700000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '900 mm 900 x 525 [0461900000]', 'قطعة', 4110.0, 0, 0, true, 'دروفيت', '0461900000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '900 mm 900 x 525 [0461900000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1400 mm 1400 mm 1400 x 520 [0461140000]', 'قطعة', 6440.0, 0, 0, true, 'دروفيت', '0461140000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1400 mm 1400 mm 1400 x 520 [0461140000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '495 mm  495 mm 495 x 350 [0335500000]', 'قطعة', 5540.0, 0, 0, true, 'دروفيت', '0335500000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '495 mm  495 mm 495 x 350 [0335500000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '620 mm 620 mm 620 x 505 [0460620000]', 'قطعة', 3120.0, 0, 0, true, 'دروفيت', '0460620000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '620 mm 620 mm 620 x 505 [0460620000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '815 mm 815 mm 815 x 550 [0401810000]', 'قطعة', 5850.0, 0, 0, true, 'دروفيت', '0401810000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '815 mm 815 mm 815 x 550 [0401810000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '1015 mm 1015 mm 1015 x 550 [0401100000]', 'قطعة', 8495.0, 0, 0, true, 'دروفيت', '0401100000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1015 mm 1015 mm 1015 x 550 [0401100000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '560 mm 560 mm 560 x 420 [0439560051]', 'قطعة', 2380.0, 0, 0, true, 'دروفيت', '0439560051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '560 mm 560 mm 560 x 420 [0439560051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '470 mm Ø 470 [0468470000]', 'قطعة', 3080.0, 0, 0, true, 'دروفيت', '0468470000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '470 mm Ø 470 [0468470000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '430 mm 430 mm Ø 430 [0468400000]', 'قطعة', 3010.0, 0, 0, true, 'دروفيت', '0468400000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '430 mm 430 mm Ø 430 [0468400000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '420 mm 420 mm Ø 420 [0325420000]', 'قطعة', 4885.0, 0, 0, true, 'دروفيت', '0325420000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '420 mm 420 mm Ø 420 [0325420000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '420 mm 420 mm 420 x420 [0333420000]', 'قطعة', 4885.0, 0, 0, true, 'دروفيت', '0333420000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '420 mm 420 mm 420 x420 [0333420000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '570 mm 570 mm  570 x 490 [0340490011]', 'قطعة', 5585.0, 0, 0, true, 'دروفيت', '0340490011', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '570 mm 570 mm  570 x 490 [0340490011]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'for 034049 034049لـ [0863080000]', 'قطعة', 4705.0, 0, 0, true, 'دروفيت', '0863080000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'for 034049 034049لـ [0863080000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '650 mm  650 mm    650 x 530 [0474650000]', 'قطعة', 2950.0, 0, 0, true, 'دروفيت', '0474650000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '650 mm  650 mm    650 x 530 [0474650000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '480 mm 480 mm 480 x 480 [5220480000]', 'قطعة', 2510.0, 0, 0, true, 'دروفيت', '5220480000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '480 mm 480 mm 480 x 480 [5220480000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '470 mm 470 mm 470 x 340 [3314470000]', 'قطعة', 1615.0, 0, 0, true, 'دروفيت', '3314470000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '470 mm 470 mm 470 x 340 [3314470000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Without doucheبدون دوش450 x 350 [0825440000]', 'قطعة', 6995.0, 0, 0, true, 'دروفيت', '0825440000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Without doucheبدون دوش450 x 350 [0825440000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'With doucheبالدوش450 x 350 [2802440000]', 'قطعة', 7200.0, 0, 0, true, 'دروفيت', '2802440000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'With doucheبالدوش450 x 350 [2802440000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'Without doucheبدون دوش450 x 350 [0824440000]', 'قطعة', 6995.0, 0, 0, true, 'دروفيت', '0824440000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Without doucheبدون دوش450 x 350 [0824440000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'With doucheبالدوش450 x 350 [2803440000]', 'قطعة', 7200.0, 0, 0, true, 'دروفيت', '2803440000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'With doucheبالدوش450 x 350 [2803440000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'D-CODE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'xings includedشامل مجموعة التثبيت705 x 400 [8500000000]', 'قطعة', 2955.0, 0, 0, true, 'دروفيت', '8500000000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'xings includedشامل مجموعة التثبيت705 x 400 [8500000000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'with antislipبمانع التزحلق800 x 800 [4600000000]', 'قطعة', 5905.0, 0, 0, true, 'دروفيت', '4600000000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'with antislipبمانع التزحلق800 x 800 [4600000000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SEPARATES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  '600 600 600 x 455 [7501000051]', 'قطعة', 3815.0, 0, 0, true, 'دروفيت', '7501000051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '600 600 600 x 455 [7501000051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك315 x 185 [0096720051]', 'قطعة', 585.0, 0, 0, true, 'دروفيت', '0096720051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك315 x 185 [0096720051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك160 x 160 [0096730051]', 'قطعة', 550.0, 0, 0, true, 'دروفيت', '0096730051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك160 x 160 [0096730051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك160 x 160 [0096740051]', 'قطعة', 570.0, 0, 0, true, 'دروفيت', '0096740051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك160 x 160 [0096740051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك600 x 170 [0893600000]', 'قطعة', 630.0, 0, 0, true, 'دروفيت', '0893600000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك600 x 170 [0893600000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك160 x 95 [0096770000]', 'قطعة', 380.0, 0, 0, true, 'دروفيت', '0096770000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك160 x 95 [0096770000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك600 [0096760000]', 'قطعة', 450.0, 0, 0, true, 'دروفيت', '0096760000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك600 [0096760000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك160 x 95 [0096750051]', 'قطعة', 480.0, 0, 0, true, 'دروفيت', '0096750051', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك160 x 95 [0096750051]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك280 x 100 [0083020000]', 'قطعة', 535.0, 0, 0, true, 'دروفيت', '0083020000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك280 x 100 [0083020000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك170 x 100 [0083010000]', 'قطعة', 530.0, 0, 0, true, 'دروفيت', '0083010000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك170 x 100 [0083010000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك170 x 120 [0083030000]', 'قطعة', 535.0, 0, 0, true, 'دروفيت', '0083030000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك170 x 120 [0083030000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك500 x 145 [0083000000]', 'قطعة', 570.0, 0, 0, true, 'دروفيت', '0083000000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك500 x 145 [0083000000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك70 x 60 [0083050000]', 'قطعة', 380.0, 0, 0, true, 'دروفيت', '0083050000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك70 x 60 [0083050000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك90 x 65 [0083060000]', 'قطعة', 410.0, 0, 0, true, 'دروفيت', '0083060000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك90 x 65 [0083060000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'ceramicسيراميك600 [0083040000]', 'قطعة', 440.0, 0, 0, true, 'دروفيت', '0083040000', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ceramicسيراميك600 [0083040000]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'DS1239 DS1249 DS6393 [DS1239]', 'قطعة', 1239.0, 0, 0, true, 'دروفيت', 'DS1239', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'DS1239 DS1249 DS6393 [DS1239]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'DS1239 DS1249 DS6393 [DS1249]', 'قطعة', 1239.0, 0, 0, true, 'دروفيت', 'DS1249', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'DS1239 DS1249 DS6393 [DS1249]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'DS1239 DS1249 DS6393 [DS6393]', 'قطعة', 1239.0, 0, 0, true, 'دروفيت', 'DS6393', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'DS1239 DS1249 DS6393 [DS6393]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'DS6394 DS6784 DS6784 [DS6394]', 'قطعة', 6394.0, 0, 0, true, 'دروفيت', 'DS6394', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'DS6394 DS6784 DS6784 [DS6394]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT1267 KT6647 KT6648 [KT6647]', 'قطعة', 1267.0, 0, 0, true, 'دروفيت', 'KT6647', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT1267 KT6647 KT6648 [KT6647]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT1267 KT6647 KT6648 [KT6648]', 'قطعة', 1267.0, 0, 0, true, 'دروفيت', 'KT6648', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT1267 KT6647 KT6648 [KT6648]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT6650 KT6658 KT6667 [KT6650]', 'قطعة', 6650.0, 0, 0, true, 'دروفيت', 'KT6650', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT6650 KT6658 KT6667 [KT6650]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT6650 KT6658 KT6667 [KT6667]', 'قطعة', 6650.0, 0, 0, true, 'دروفيت', 'KT6667', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT6650 KT6658 KT6667 [KT6667]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT6668 KT6669 KT6670 [KT6668]', 'قطعة', 6668.0, 0, 0, true, 'دروفيت', 'KT6668', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT6668 KT6669 KT6670 [KT6668]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT6668 KT6669 KT6670 [KT6670]', 'قطعة', 6668.0, 0, 0, true, 'دروفيت', 'KT6670', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT6668 KT6669 KT6670 [KT6670]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT6694 KT6695 KT7532 [KT7532]', 'قطعة', 6694.0, 0, 0, true, 'دروفيت', 'KT7532', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT6694 KT6695 KT7532 [KT7532]' AND company = 'دروفيت');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'L-CUBE' AND category_id = (SELECT id FROM categories WHERE name = 'دروفيت')),
  'KT7533 [KT7533]', 'قطعة', 7533.0, 0, 0, true, 'دروفيت', 'KT7533', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'KT7533 [KT7533]' AND company = 'دروفيت');
