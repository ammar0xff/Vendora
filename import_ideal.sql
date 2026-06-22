INSERT INTO categories (id, name) SELECT gen_random_uuid(), 'ايديال' WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'ايديال');

INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'CONNECT'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'DIAGONAL'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'I.LIFE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'INDEPENDENT'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'IOM ACCESSORIES'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'KIMERA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'MANTA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'NEW CAPRI'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'NEW ESEDRA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'OTHERS'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'PLAN'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'PLAYA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'PROSYS'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'SAN REMO'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'SAN REMO SPECIAL NEEDS'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'SOPHIA'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'SPACE'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'STUDIO ACCESSORIES'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'TESI'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'TONIC'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO subcategories (id, category_id, name)
SELECT gen_random_uuid(), (SELECT id FROM categories WHERE name = 'ايديال'), 'Unknown'
WHERE NOT EXISTS (SELECT 1 FROM subcategories WHERE name = 'Unknown' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال'));


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'Unknown' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton - Cairo Egypt Tel.: 26969700 Fax [nan]', 'قطعة', 88.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton - Cairo Egypt Tel.: 26969700 Fax [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [K3104]', 'قطعة', 6550.0, 0, 0, true, 'ايديال', '34.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [K3104]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [K3103]', 'قطعة', 6550.0, 0, 0, true, 'ايديال', '38.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [K3103]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G3121]', 'قطعة', 6890.0, 0, 0, true, 'ايديال', '34.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G3121]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G3122]', 'قطعة', 6890.0, 0, 0, true, 'ايديال', '38.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G3122]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & trim - Dual flush [K4035]', 'قطعة', 3780.0, 0, 0, true, 'ايديال', '15.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & trim - Dual flush [K4035]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover [G7047]', 'قطعة', 2500.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover [G7047]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [G7061]', 'قطعة', 4060.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [G7061]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl w/out douche [K3101]', 'قطعة', 8720.0, 0, 0, true, 'ايديال', '21.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl w/out douche [K3101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl with douche & handle [G3192]', 'قطعة', 9220.0, 0, 0, true, 'ايديال', '21.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl with douche & handle [G3192]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bidet w/out douche [K5050]', 'قطعة', 8660.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bidet w/out douche [K5050]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet without douche - 1320 6 Chair Support [G0093AC]', 'قطعة', 6720.0, 0, 0, true, 'ايديال', '21.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet without douche - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lavatory 75 cm [G3175]', 'قطعة', 6110.0, 0, 0, true, 'ايديال', '23.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lavatory 75 cm [G3175]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lavatory 60 cm [G3160]', 'قطعة', 5170.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lavatory 60 cm [G3160]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [K0058]', 'قطعة', 2110.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [K0058]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal [K0071]', 'قطعة', 1950.0, 0, 0, true, 'ايديال', '8.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal [K0071]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Guest Basin 60cm / Right [K0704]', 'قطعة', 3130.0, 0, 0, true, 'ايديال', '8.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Guest Basin 60cm / Right [K0704]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Guest Basin 60cm / Left [K0703]', 'قطعة', 3130.0, 0, 0, true, 'ايديال', '8.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Guest Basin 60cm / Left [K0703]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Guest Basin 50 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف ﻣﺮ [K0705]', 'قطعة', 2180.0, 0, 0, true, 'ايديال', '7.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Guest Basin 50 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف ﻣﺮ [K0705]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic Guest Furniture 60cm R/L Grey [G2146PH]', 'قطعة', 7550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic Guest Furniture 60cm R/L Grey [G2146PH]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic Guest Furniture 60cm R/L Walnut [G2146XA]', 'قطعة', 7550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic Guest Furniture 60cm R/L Walnut [G2146XA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic Guest Furniture 50cm Grey [G2147PH]', 'قطعة', 6330.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic Guest Furniture 50cm Grey [G2147PH]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic Guest Furniture 50cm Walnut [G2147XA]', 'قطعة', 6330.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic Guest Furniture 50cm Walnut [G2147XA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic tall unit, 1 door, 120cm, Dark Oak [G2210EG]', 'قطعة', 9900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic tall unit, 1 door, 120cm, Dark Oak [G2210EG]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tonic VTY unit, 1 drawer,75 cm, Dark Oak ﺷG2146PH˾˽ [G2146XAG2210EG]', 'قطعة', 12050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tonic VTY unit, 1 drawer,75 cm, Dark Oak ﺷG2146PH˾˽ [G2146XAG2210EG]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Bowl S/P back to wall without douche [G3076]', 'قطعة', 9860.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Bowl S/P back to wall without douche [G3076]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Bowl S/P back to wall with douche & handle [G3086]', 'قطعة', 10390.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Bowl S/P back to wall with douche & handle [G3086]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover - 1050 - White connecting bend From (P) to (S) [G900701]', 'قطعة', 4130.0, 0, 0, true, 'ايديال', '3.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover - 1050 - White connecting bend From (P) to (S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Semi-Countertop Lava 64 cm [T0878]', 'قطعة', 8560.0, 0, 0, true, 'ايديال', '18.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Semi-Countertop Lava 64 cm [T0878]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'DIAGONAL' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single-hole Countertop Lava 66 cm دوش ﺑﺪون ﻣﻴﻨﻲ S/P ﴏف ﻣﺮﺣﺎض واﳌﻘﺒﺾ ﺑﺎﻟﺪوش  ﻣﻴﻨﻲ S/P ﴏف ﻣﺮ [T0875]', 'قطعة', 7500.0, 0, 0, true, 'ايديال', '17.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single-hole Countertop Lava 66 cm دوش ﺑﺪون ﻣﻴﻨﻲ S/P ﴏف ﻣﺮﺣﺎض واﳌﻘﺒﺾ ﺑﺎﻟﺪوش  ﻣﻴﻨﻲ S/P ﴏف ﻣﺮ [T0875]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G3401]', 'قطعة', 6240.0, 0, 0, true, 'ايديال', '31.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G3401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G3402]', 'قطعة', 6240.0, 0, 0, true, 'ايديال', '35.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G3402]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G3421]', 'قطعة', 6600.0, 0, 0, true, 'ايديال', '31.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G3421]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G3422]', 'قطعة', 6600.0, 0, 0, true, 'ايديال', '35.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G3422]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [G3434]', 'قطعة', 4080.0, 0, 0, true, 'ايديال', '16.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [G3434]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover [K7000]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover [K7000]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [G6900]', 'قطعة', 3600.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [G6900]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl without douche [G3481]', 'قطعة', 5940.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl without douche [G3481]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl with douche [G3491]', 'قطعة', 6180.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl with douche [G3491]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet without douche [G3783]', 'قطعة', 6120.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet without douche [G3783]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet with douche [G3780]', 'قطعة', 6120.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet with douche [G3780]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet without douche [R3763]', 'قطعة', 6120.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet without douche [R3763]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet with douche - 1320 6 Chair Support [G0093AC]', 'قطعة', 6120.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet with douche - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '70cm Lava [R3163]', 'قطعة', 5700.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '70cm Lava [R3163]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '62cm Lava [R3133]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '16.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '62cm Lava [R3133]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '50cm Hand wash Basin [R4263]', 'قطعة', 2220.0, 0, 0, true, 'ايديال', '8.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '50cm Hand wash Basin [R4263]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [R3363]', 'قطعة', 2460.0, 0, 0, true, 'ايديال', '12.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [R3363]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Large Wall Pedestal (70/62cm - Lava) [R3334]', 'قطعة', 2220.0, 0, 0, true, 'ايديال', '8.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Large Wall Pedestal (70/62cm - Lava) [R3334]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Small wall Pedestal (50cm - Hand w.b.) [R3364]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '5.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Small wall Pedestal (50cm - Hand w.b.) [R3364]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'MANTA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '60cm Counter Top Lava دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏ [G0093AC]', 'قطعة', 4380.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '60cm Counter Top Lava دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏ [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '30 Close Coupled Bowl S/P back to wall W/Out douche [E803701]', 'قطعة', 5160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '30 Close Coupled Bowl S/P back to wall W/Out douche [E803701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '30 Close Coupled Bowl S/P back to wall with douche [E782101]', 'قطعة', 5650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '30 Close Coupled Bowl S/P back to wall with douche [E782101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '27 Connect Bowl P W/Out douche [E803601]', 'قطعة', 4960.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '27 Connect Bowl P W/Out douche [E803601]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '27 Connect Bowl P with douche [G804601]', 'قطعة', 5310.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '27 Connect Bowl P with douche [G804601]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Hung Bowl w/out douch [E785001]', 'قطعة', 5560.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Hung Bowl w/out douch [E785001]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Hung Bowl with douch & handle [G785101]', 'قطعة', 6050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Hung Bowl with douch & handle [G785101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'White connecting bend From (P) to (S) [G900701]', 'قطعة', 1050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'White connecting bend From (P) to (S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12 Tank & Trim Cube [E714301]', 'قطعة', 2970.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12 Tank & Trim Cube [E714301]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2 Seat & Cover [E712801]', 'قطعة', 2340.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2 Seat & Cover [E712801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover Slim (Soft Close) [E772401]', 'قطعة', 3420.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover Slim (Soft Close) [E772401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '22 Lavatory 70 cm [G812801]', 'قطعة', 4450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '22 Lavatory 70 cm [G812801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7 Large Semi Pedestal [E797401]', 'قطعة', 2400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7 Large Semi Pedestal [E797401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8 Countertop Rectangular Basin 58x41 cm [E505901]', 'قطعة', 5650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8 Countertop Rectangular Basin 58x41 cm [E505901]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8 Under Counter Basin 58x41 ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ ﻛﻮﻧﻜﺖ S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوشS/P  ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P  [E506101]', 'قطعة', 5930.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8 Under Counter Basin 58x41 ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ ﻛﻮﻧﻜﺖ S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوشS/P  ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P  [E506101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '22 Lavatory 70 cm [G812801]', 'قطعة', 4450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '22 Lavatory 70 cm [G812801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Connect Furniture Walnut 70cm 2 Drawers [G1842XA]', 'قطعة', 11880.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Connect Furniture Walnut 70cm 2 Drawers [G1842XA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Connect Furniture Light Oak 70cm 2 Drawers [G812801]', 'قطعة', 11880.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Connect Furniture Light Oak 70cm 2 Drawers [G812801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Close Coupled Bowl P back to wall without douche [G350701]', 'قطعة', 4780.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Close Coupled Bowl P back to wall without douche [G350701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Close Coupled Bowl P back to wall with douche [G350801]', 'قطعة', 5250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Close Coupled Bowl P back to wall with douche [G350801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G350501]', 'قطعة', 4570.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G350501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G350601]', 'قطعة', 4890.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G350601]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl without douche [T350201]', 'قطعة', 4730.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl without douche [T350201]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl with douche [G359301]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl with douche [G359301]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'White Connecting Bend From (P) to (S) [G900701]', 'قطعة', 1050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'White Connecting Bend From (P) to (S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11 Tank & Trim 4.5/3L [G357501]', 'قطعة', 3520.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11 Tank & Trim 4.5/3L [G357501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover [T352801]', 'قطعة', 2110.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover [T352801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [T352701]', 'قطعة', 2760.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [T352701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lavatory 65 cm [G351301]', 'قطعة', 4050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lavatory 65 cm [G351301]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor pedestal [G351901]', 'قطعة', 1840.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor pedestal [G351901]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lavatory 55 cm [G351501]', 'قطعة', 3260.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lavatory 55 cm [G351501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall pedestal دوش ﺑﺪون ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف  [J503101]', 'قطعة', 1180.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall pedestal دوش ﺑﺪون ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش ﻟﻠﺤﺎﺋﻂ ﻣﻼﺻﻖ P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف  [J503101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Vanity basin 62.5 cm [G351001]', 'قطعة', 3690.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Vanity basin 62.5 cm [G351001]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tesi Furniture Glossy Grey [nan]', 'قطعة', 14360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tesi Furniture Glossy Grey [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'cm 2Drawers [G0045PH]', 'قطعة', 60.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'cm 2Drawers [G0045PH]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tesi Furniture Glossy White [nan]', 'قطعة', 14360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tesi Furniture Glossy White [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TESI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'cm 2Drawers [G0045OV]', 'قطعة', 60.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'cm 2Drawers [G0045OV]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G0101]', 'قطعة', 4990.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G0101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G0102]', 'قطعة', 4990.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G0102]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G0121]', 'قطعة', 5320.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G0121]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G0122]', 'قطعة', 5320.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G0122]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [G0134]', 'قطعة', 3200.0, 0, 0, true, 'ايديال', '15.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [G0134]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) G 5121 [nan]', 'قطعة', 2280.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) G 5121 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet without douche [G0113]', 'قطعة', 4820.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet without douche [G0113]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet with douche [G0110]', 'قطعة', 4820.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet with douche [G0110]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '50cm Hand Wash Basin [G0150]', 'قطعة', 1960.0, 0, 0, true, 'ايديال', '11.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '50cm Hand Wash Basin [G0150]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '70cm Lava [G0171]', 'قطعة', 4540.0, 0, 0, true, 'ايديال', '21.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '70cm Lava [G0171]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [G0214]', 'قطعة', 1850.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [G0214]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW CAPRI' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Large Wall Pedestal دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف  [G0171]', 'قطعة', 1740.0, 0, 0, true, 'ايديال', '7.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Large Wall Pedestal دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف  [G0171]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G0201]', 'قطعة', 4880.0, 0, 0, true, 'ايديال', '23.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G0201]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G0202]', 'قطعة', 4880.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G0202]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G0221]', 'قطعة', 5210.0, 0, 0, true, 'ايديال', '23.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G0221]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G0222]', 'قطعة', 5210.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G0222]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [G0234]', 'قطعة', 3080.0, 0, 0, true, 'ايديال', '13.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [G0234]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover [G5129]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '2.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover [G5129]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl without douche [G0281]', 'قطعة', 4820.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl without douche [G0281]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl with douche [G0291]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl with douche [G0291]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet without douche [G0283]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet without douche [G0283]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet with douche - 1320 6 Chair Support [G0093AC]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet with douche - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet without douche [G0213]', 'قطعة', 4600.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet without douche [G0213]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet with douche [G0210]', 'قطعة', 4600.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet with douche [G0210]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '70cm Lavatory [G0270]', 'قطعة', 4150.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '70cm Lavatory [G0270]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '48cm Lavatory [G0248]', 'قطعة', 1740.0, 0, 0, true, 'ايديال', '9.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '48cm Lavatory [G0248]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [G0214]', 'قطعة', 1850.0, 0, 0, true, 'ايديال', '11.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [G0214]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal ( 70 cm Lava ) [G0226]', 'قطعة', 1520.0, 0, 0, true, 'ايديال', '8.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal ( 70 cm Lava ) [G0226]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal ( 48 cm Lava ) [G0223]', 'قطعة', 1240.0, 0, 0, true, 'ايديال', '6.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal ( 48 cm Lava ) [G0223]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Counter top Lava 60 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S  [G0093AC]', 'قطعة', 3870.0, 0, 0, true, 'ايديال', '13.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Counter top Lava 60 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S  [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'New Esedra C/C back to wall bowl universal outlet without douche [G282001]', 'قطعة', 4570.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'New Esedra C/C back to wall bowl universal outlet without douche [G282001]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'New Esedra C/C back to wall bowl universal outlet with douche [G282101]', 'قطعة', 5040.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'New Esedra C/C back to wall bowl universal outlet with douche [G282101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [T282401]', 'قطعة', 4320.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [T282401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G282501]', 'قطعة', 4650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G282501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl without douche [G281701]', 'قطعة', 5130.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl without douche [G281701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl with douche & handle [G282801]', 'قطعة', 5600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl with douche & handle [G282801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & trim - dual flush [G283401]', 'قطعة', 2520.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & trim - dual flush [G283401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover [T318201]', 'قطعة', 1800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover [T318201]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [T318101]', 'قطعة', 2750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [T318101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55 cm Lavatory [G285501]', 'قطعة', 2860.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55 cm Lavatory [G285501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '65 cm Lavatory [G286501]', 'قطعة', 3250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '65 cm Lavatory [G286501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor pedestal [G281401]', 'قطعة', 1520.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor pedestal [G281401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'NEW ESEDRA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall pedestal دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض وشﺑﺎﻟﺪ S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮ [G281701-G282801]', 'قطعة', 1400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall pedestal دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض وشﺑﺎﻟﺪ S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮ [G281701-G282801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Playa C/C back to wall bowl universal outlet without douche [G4905]', 'قطعة', 3810.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Playa C/C back to wall bowl universal outlet without douche [G4905]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Playa C/C back to wall bowl universal outlet with douche [G4925]', 'قطعة', 4320.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Playa C/C back to wall bowl universal outlet with douche [G4925]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [J5017]', 'قطعة', 3640.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [J5017]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [J5018]', 'قطعة', 3640.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [J5018]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G4921]', 'قطعة', 3980.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G4921]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G4922]', 'قطعة', 3980.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G4922]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [J5028]', 'قطعة', 2520.0, 0, 0, true, 'ايديال', '13.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [J5028]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover [J4929]', 'قطعة', 2240.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover [J4929]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [J4930]', 'قطعة', 2860.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [J4930]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S/P without douche [J4683]', 'قطعة', 4540.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S/P without douche [J4683]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S/P with douche & handle [G4986]', 'قطعة', 4760.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S/P with douche & handle [G4986]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet without douche [J5014]', 'قطعة', 3590.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet without douche [J5014]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet with douche - 1050 - White connecting bend From (P) to (S) [G900701]', 'قطعة', 3590.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet with douche - 1050 - White connecting bend From (P) to (S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-hung bowl without douche [J5019]', 'قطعة', 4500.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-hung bowl without douche [J5019]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl with douche & handle [G4994]', 'قطعة', 4900.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl with douche & handle [G4994]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-hung bidet without douche - 1320 6 Chair Support [G0093AC]', 'قطعة', 4400.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-hung bidet without douche - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '65 x 48 cm Lava [J5013]', 'قطعة', 3080.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '65 x 48 cm Lava [J5013]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55 x 48 cm Lava [J5011]', 'قطعة', 2580.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55 x 48 cm Lava [J5011]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [J4678]', 'قطعة', 1350.0, 0, 0, true, 'ايديال', '12.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [J4678]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAYA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal (65 / 55 cm Lava) دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮ [G4994]', 'قطعة', 1240.0, 0, 0, true, 'ايديال', '7.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal (65 / 55 cm Lava) دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮ [G4994]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12.4 i.life B Rectangular Vessel 550x400 mm in white glossy finish, without overflow [G572801]', 'قطعة', 4410.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12.4 i.life B Rectangular Vessel 550x400 mm in white glossy finish, without overflow [G572801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11.2 i.life B Rectangular Vessel 500x380 mm in white glossy finish, without overflow [G572901]', 'قطعة', 4200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11.2 i.life B Rectangular Vessel 500x380 mm in white glossy finish, without overflow [G572901]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8.8 i.life B Square Vessel 380x380 mm in white glossy finish, without overflow [G573001]', 'قطعة', 3260.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8.8 i.life B Square Vessel 380x380 mm in white glossy finish, without overflow [G573001]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12.1 i.life O Oval Vessel 600x380 mm in white glossy finish, without overflow [G573101]', 'قطعة', 4470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12.1 i.life O Oval Vessel 600x380 mm in white glossy finish, without overflow [G573101]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '10.7 i.life O Oval Vessel 550x360 mm in white glossy finish, without overflow [G573201]', 'قطعة', 4200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '10.7 i.life O Oval Vessel 550x360 mm in white glossy finish, without overflow [G573201]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8.3 i.life O Round Vessel 400 mm in white glossy finish, without overflow [G573301]', 'قطعة', 2630.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8.3 i.life O Round Vessel 400 mm in white glossy finish, without overflow [G573301]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12.8 i.life O Oval Vessel 550x400 mm in white glossy finish, 1 tap hole, with overflow [G573401]', 'قطعة', 4360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12.8 i.life O Oval Vessel 550x400 mm in white glossy finish, 1 tap hole, with overflow [G573401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'I.LIFE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9.2 i.life O Round Vessel 400 mm in white glossy finish, 1 tap hole, with overflow ﺳﻢ ٥٥ X [G573501]', 'قطعة', 3100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9.2 i.life O Round Vessel 400 mm in white glossy finish, 1 tap hole, with overflow ﺳﻢ ٥٥ X [G573501]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Independent - Oval basin 50 X 45 cm [G4150]', 'قطعة', 3300.0, 0, 0, true, 'ايديال', '11.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Independent - Oval basin 50 X 45 cm [G4150]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Independent -rectangular basin 60X45 cm [G4160]', 'قطعة', 3420.0, 0, 0, true, 'ايديال', '13.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Independent -rectangular basin 60X45 cm [G4160]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Independent - Square basin 45 X 45 cm [G4145]', 'قطعة', 3300.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Independent - Square basin 45 X 45 cm [G4145]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Venice 44 cm Above Counter Basin [G3055]', 'قطعة', 4500.0, 0, 0, true, 'ايديال', '7.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Venice 44 cm Above Counter Basin [G3055]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Venice Lavatory 80 cm [K0843]', 'قطعة', 7680.0, 0, 0, true, 'ايديال', '22.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Venice Lavatory 80 cm [K0843]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Venice Lavatory 70 cm [K0842]', 'قطعة', 7140.0, 0, 0, true, 'ايديال', '21.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Venice Lavatory 70 cm [K0842]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'INDEPENDENT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal For Lavatory ﺳﻢ ٥٤ X ٠٥ اﻓﻘﻲ ﺳﻄﺢ ﻓﻮق ﻳﺜﺒﺖ ﺳﻢ ٥٤ X ٠٦ اﻓﻘﻲ ﺳﻄﺢ ﻓﻮق ﻳﺜﺒﺖ ﺳﻢ ٥٤ [K0843]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '8.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal For Lavatory ﺳﻢ ٥٤ X ٠٥ اﻓﻘﻲ ﺳﻄﺢ ﻓﻮق ﻳﺜﺒﺖ ﺳﻢ ٥٤ X ٠٦ اﻓﻘﻲ ﺳﻄﺢ ﻓﻮق ﻳﺜﺒﺖ ﺳﻢ ٥٤ [K0843]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G6401]', 'قطعة', 3720.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G6401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G6402]', 'قطعة', 3720.0, 0, 0, true, 'ايديال', '28.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G6402]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G6421]', 'قطعة', 4060.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G6421]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G6422]', 'قطعة', 4060.0, 0, 0, true, 'ايديال', '28.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G6422]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [G6434]', 'قطعة', 2300.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [G6434]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover [R3902]', 'قطعة', 1400.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover [R3902]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) [G3901]', 'قطعة', 2090.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) [G3901]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl without douche [G6481]', 'قطعة', 3770.0, 0, 0, true, 'ايديال', '18.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl without douche [G6481]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bowl with douche & handle [G6492]', 'قطعة', 4300.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bowl with douche & handle [G6492]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung (Combi) without douche [G6461]', 'قطعة', 4240.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung (Combi) without douche [G6461]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung (Combi) with douche & handle [G6472]', 'قطعة', 4760.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung (Combi) with douche & handle [G6472]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet without douche [G6483]', 'قطعة', 3370.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet without douche [G6483]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall-Hung Bidet with douche [G6480]', 'قطعة', 3370.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall-Hung Bidet with douche [G6480]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet without douche [G6413]', 'قطعة', 2960.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet without douche [G6413]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single hole Bidet with douche - 1320 6 Chair Support [G0093AC]', 'قطعة', 2960.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single hole Bidet with douche - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '70cm Lavatory [E7480]', 'قطعة', 2790.0, 0, 0, true, 'ايديال', '21.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '70cm Lavatory [E7480]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '60cm Lavatory [E7460]', 'قطعة', 2270.0, 0, 0, true, 'ايديال', '16.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '60cm Lavatory [E7460]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '45cm Lavatory [E7420]', 'قطعة', 1280.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '45cm Lavatory [E7420]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [E7400]', 'قطعة', 1280.0, 0, 0, true, 'ايديال', '9.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [E7400]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Large Wall Pedestal (70/60 cm) [E7492]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Large Wall Pedestal (70/60 cm) [E7492]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Small wall Pedestal (45cm) دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪو [G0093AC]', 'قطعة', 990.0, 0, 0, true, 'ايديال', '7.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Small wall Pedestal (45cm) دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪو [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '29 Raised bowl (46 cm height) S/P trap w/out douche [G6450]', 'قطعة', 3310.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '29 Raised bowl (46 cm height) S/P trap w/out douche [G6450]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '29 Raised bowl (46 cm height) S/P trap with douche [G6451]', 'قطعة', 3660.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '29 Raised bowl (46 cm height) S/P trap with douche [G6451]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'White Connecting Bend (From P to S) [G900701]', 'قطعة', 1050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'White Connecting Bend (From P to S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14 Tank & Trim - Dual Flush [G6434]', 'قطعة', 2210.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14 Tank & Trim - Dual Flush [G6434]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3 Seat & Cover [R3902]', 'قطعة', 1340.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3 Seat & Cover [R3902]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3 Seat & cover (Soft Close) [G3901]', 'قطعة', 1980.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3 Seat & cover (Soft Close) [G3901]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3 Seat & cover (Open Front) [G3903]', 'قطعة', 2150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3 Seat & cover (Open Front) [G3903]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15 61cm Lava - disabled [G7470]', 'قطعة', 2900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15 61cm Lava - disabled [G7470]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9.5 Floor Pedestal [E7400]', 'قطعة', 1220.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9.5 Floor Pedestal [E7400]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7.5 Wall pedestal [E7502]', 'قطعة', 930.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7.5 Wall pedestal [E7502]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Hinged support arm 80 cm [S6360AC]', 'قطعة', 6040.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Hinged support arm 80 cm [S6360AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Straight grab rail 60 cm [S6454AC]', 'قطعة', 2500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Straight grab rail 60 cm [S6454AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SAN REMO SPECIAL NEEDS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with extended lever handle with Pop-up Drain دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S/P ﴏ [A1245AA]', 'قطعة', 5660.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with extended lever handle with Pop-up Drain دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S/P ﴏ [A1245AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Plan C/C back to wall bowl universal outlet without douche [G0676]', 'قطعة', 3780.0, 0, 0, true, 'ايديال', '28.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Plan C/C back to wall bowl universal outlet without douche [G0676]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Plan C/C back to wall bowl universal outlet with douche [G0686]', 'قطعة', 4320.0, 0, 0, true, 'ايديال', '28.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Plan C/C back to wall bowl universal outlet with douche [G0686]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G0601]', 'قطعة', 3420.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G0601]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G0602]', 'قطعة', 3420.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G0602]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G0621]', 'قطعة', 3840.0, 0, 0, true, 'ايديال', '25.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G0621]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G0622]', 'قطعة', 3840.0, 0, 0, true, 'ايديال', '26.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G0622]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & trim - dual flush [G0634]', 'قطعة', 2160.0, 0, 0, true, 'ايديال', '13.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & trim - dual flush [G0634]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solid Seat & Cover [G7731]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '2.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solid Seat & Cover [G7731]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & Cover [R3902]', 'قطعة', 1400.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & Cover [R3902]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Seat & cover (Soft Close) - 1050 - White connecting bend From (P) to (S) [G900701]', 'قطعة', 2090.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Seat & cover (Soft Close) - 1050 - White connecting bend From (P) to (S) [G900701]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet without douche [G0613]', 'قطعة', 3120.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet without douche [G0613]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet with douche [G0610]', 'قطعة', 3120.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet with douche [G0610]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '65 cm Lavatory [V1340]', 'قطعة', 2020.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '65 cm Lavatory [V1340]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor pedestal [V9140]', 'قطعة', 1130.0, 0, 0, true, 'ايديال', '9.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor pedestal [V9140]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall pedestal [V9210]', 'قطعة', 890.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall pedestal [V9210]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PLAN' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin above counter 56x44 cm دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض وشﺑﺎﻟﺪ S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض [V1340]', 'قطعة', 2750.0, 0, 0, true, 'ايديال', '15.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin above counter 56x44 cm دوش ﺑﺪون S/P ﴏف ﻣﺮﺣﺎض وشﺑﺎﻟﺪ S/P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض [V1340]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G0801]', 'قطعة', 2650.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G0801]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G0802]', 'قطعة', 2650.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G0802]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G0821]', 'قطعة', 2990.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G0821]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G0822]', 'قطعة', 2990.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G0822]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & Trim - Dual Flush [G0834]', 'قطعة', 2070.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & Trim - Dual Flush [G0834]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solid Seat & Cover [G7731]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '2.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solid Seat & Cover [G7731]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '62cm Lava [G0862]', 'قطعة', 1670.0, 0, 0, true, 'ايديال', '17.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '62cm Lava [G0862]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55cm Lava [G0855]', 'قطعة', 1440.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55cm Lava [G0855]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor Pedestal [E7400]', 'قطعة', 1280.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor Pedestal [E7400]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Pedestal [E7492]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '7.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Pedestal [E7492]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet without douche [G0813]', 'قطعة', 2020.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet without douche [G0813]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SOPHIA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet with douche دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف ﻣﺮ [G0810]', 'قطعة', 2020.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet with douche دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف ﻣﺮ [G0810]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P without douche [G0401]', 'قطعة', 2150.0, 0, 0, true, 'ايديال', '18.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P without douche [G0401]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S without douche [G0402]', 'قطعة', 2150.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S without douche [G0402]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl P with douche [G0421]', 'قطعة', 2500.0, 0, 0, true, 'ايديال', '18.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl P with douche [G0421]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bowl S with douche [G0422]', 'قطعة', 2500.0, 0, 0, true, 'ايديال', '19.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bowl S with douche [G0422]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl without douche [G0481]', 'قطعة', 3060.0, 0, 0, true, 'ايديال', '17.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl without douche [G0481]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall hung bowl with douche and handel - 1320 6 Chair Support [G0093AC]', 'قطعة', 3660.0, 0, 0, true, 'ايديال', '18.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall hung bowl with douche and handel - 1320 6 Chair Support [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Tank & trim - dual flush [V6244]', 'قطعة', 2030.0, 0, 0, true, 'ايديال', '12.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Tank & trim - dual flush [V6244]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solid Seat & Cover [G7731]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '3.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solid Seat & Cover [G7731]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '60 cm Lavatory [V1440]', 'قطعة', 1420.0, 0, 0, true, 'ايديال', '16.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '60 cm Lavatory [V1440]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55 cm Lavatory [V1540]', 'قطعة', 1360.0, 0, 0, true, 'ايديال', '14.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55 cm Lavatory [V1540]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Floor pedestal [V9140]', 'قطعة', 1130.0, 0, 0, true, 'ايديال', '9.5', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Floor pedestal [V9140]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall pedestal [V9210]', 'قطعة', 890.0, 0, 0, true, 'ايديال', '9.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall pedestal [V9210]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'counter top 60x48 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف [G0093AC]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '15.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'counter top 60x48 cm دوش ﺑﺪون P ﴏف ﻣﺮﺣﺎض دوش ﺑﺪون S ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش P ﴏف ﻣﺮﺣﺎض ﺑﺎﻟﺪوش S ﴏف [G0093AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ovalux Lava [G0800]', 'قطعة', 1850.0, 0, 0, true, 'ايديال', '15.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ovalux Lava [G0800]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Isis Lava [G0600]', 'قطعة', 1850.0, 0, 0, true, 'ايديال', '12.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Isis Lava [G0600]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oval Under Counter Basin [G4102]', 'قطعة', 1740.0, 0, 0, true, 'ايديال', '10.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oval Under Counter Basin [G4102]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Circle Under Counter Basin [G4103]', 'قطعة', 1950.0, 0, 0, true, 'ايديال', '11.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Circle Under Counter Basin [G4103]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Washbrook Urinal without douche [G4020]', 'قطعة', 4090.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Washbrook Urinal without douche [G4020]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Washbrook Urinal with douche [G4021]', 'قطعة', 4200.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Washbrook Urinal with douche [G4021]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Urinal Washbrook-back inlet without douche [G4022]', 'قطعة', 4090.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Urinal Washbrook-back inlet without douche [G4022]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Urinal Washbrook-back inlet with douche [G4023]', 'قطعة', 4200.0, 0, 0, true, 'ايديال', '24.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Urinal Washbrook-back inlet with douche [G4023]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Washbrook Urinal without douche [G4030]', 'قطعة', 3110.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Washbrook Urinal without douche [G4030]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Washbrook Urinal with douche [G4031]', 'قطعة', 3220.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Washbrook Urinal with douche [G4031]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Washbrook-back inlet w/out douche [G4032]', 'قطعة', 3110.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Washbrook-back inlet w/out douche [G4032]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Mini Washbrook-back inlet with douche [G4033]', 'قطعة', 3220.0, 0, 0, true, 'ايديال', '20.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mini Washbrook-back inlet with douche [G4033]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'OTHERS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Separator for urinal [G4100]', 'قطعة', 2190.0, 0, 0, true, 'ايديال', '16.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Separator for urinal [G4100]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '330 Soap Holder [G9310]', 'قطعة', 350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '330 Soap Holder [G9310]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '330 Corner Soap Holder [G9320]', 'قطعة', 350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '330 Corner Soap Holder [G9320]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '420 Soap Holder / Shelf [G9330]', 'قطعة', 450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '420 Soap Holder / Shelf [G9330]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '330 Paper Holder with Bar [G9340]', 'قطعة', 350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '330 Paper Holder with Bar [G9340]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '420 Shelf 50cm [G9350]', 'قطعة', 450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '420 Shelf 50cm [G9350]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '290 Single Robe Hook (pair) [G9360]', 'قطعة', 310.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '290 Single Robe Hook (pair) [G9360]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'STUDIO ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '440 Towel Holder, Clear Acrylic bar STUDIO ACCESSORIES [G9380]', 'قطعة', 470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '440 Towel Holder, Clear Acrylic bar STUDIO ACCESSORIES [G9380]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Shower Basket Chrome [A9105AA]', 'قطعة', 1540.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Shower Basket Chrome [A9105AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Soap Basket Chrome [A9112AA]', 'قطعة', 1650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Soap Basket Chrome [A9112AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Grab Rail Chrome & Soap Basket [A9114AA]', 'قطعة', 3470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Grab Rail Chrome & Soap Basket [A9114AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Robe Hook Chrome Double [A9116AA]', 'قطعة', 610.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Robe Hook Chrome Double [A9116AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Towel Rail Chrome 60cm Single [A9118AA]', 'قطعة', 1430.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Towel Rail Chrome 60cm Single [A9118AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Tissue Holder With Cover Chrome [A9127AA]', 'قطعة', 1320.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Tissue Holder With Cover Chrome [A9127AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Towel Ring Chrome [A9130AA]', 'قطعة', 1210.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Towel Ring Chrome [A9130AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'IOM ACCESSORIES' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'IOM Tissue Holder Without Cover Chrome Spare [A9132AA]', 'قطعة', 1100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'IOM Tissue Holder Without Cover Chrome Spare [A9132AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solea M1 Dual White [R0108AC]', 'قطعة', 1050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solea M1 Dual White [R0108AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solea M1 Dual Chrome [R0108AA]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solea M1 Dual Chrome [R0108AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas M2 Dual White [R0121AC]', 'قطعة', 690.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas M2 Dual White [R0121AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas M2 Dual Chrome [R0121AA]', 'قطعة', 1470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas M2 Dual Chrome [R0121AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas M3 Dual White [R0123AC]', 'قطعة', 690.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas M3 Dual White [R0123AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas M3 Dual Chrome [R0123AA]', 'قطعة', 1470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas M3 Dual Chrome [R0123AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Septa Pro M1 F/Plate Dual Chrome A/Vd Pneumatic plates                                     [R0127MY]', 'قطعة', 5410.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Septa Pro M1 F/Plate Dual Chrome A/Vd Pneumatic plates                                     [R0127MY]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solea P1 Dual White [R0133AC]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solea P1 Dual White [R0133AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Solea P1 Dual Chrome [R0133AA]', 'قطعة', 2260.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Solea P1 Dual Chrome [R0133AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas P3 Dual White [R0124AC]', 'قطعة', 1680.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas P3 Dual White [R0124AC]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Oleas P3 Dual Chrome [R0124AA]', 'قطعة', 2160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Oleas P3 Dual Chrome [R0124AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Prosys Conv Kit Mech To Pen Flush 80 أﺑﻴﺾ ﻫﻮا ﺑﻀﻐﻂ ﻣﺰدوج ﺑﺰر P1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻛﺮوم ﻫﻮا ﺑﻀﻐﻂ ﻣ [R014367]', 'قطعة', 1160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Prosys Conv Kit Mech To Pen Flush 80 أﺑﻴﺾ ﻫﻮا ﺑﻀﻐﻂ ﻣﺰدوج ﺑﺰر P1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻛﺮوم ﻫﻮا ﺑﻀﻐﻂ ﻣ [R014367]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'M - (FOR LOW INSTALLATION) أﺑﻴﺾ ﻣﺰدوج ﺑﺰر M1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻛﺮوم ﻣﺰدوج ﺑﺰر M1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻣﺰدوج [R009067]', 'قطعة', 150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'M - (FOR LOW INSTALLATION) أﺑﻴﺾ ﻣﺰدوج ﺑﺰر M1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻛﺮوم ﻣﺰدوج ﺑﺰر M1 ﺳﻮﻟﻴﺎ ﻏﻄﺎء ﻣﺰدوج [R009067]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'SEPTA PRO ELECTRONIC E1 CHROME [R0131AA]', 'قطعة', 27250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SEPTA PRO ELECTRONIC E1 CHROME [R0131AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Prosys Conversion Kit 80 Nt Ir ﻣﺰدوج ﻣﻌﺪE1ﺳﺒﺘﺎ ﻏﻄﺎء Built in accessories                   [R015167]', 'قطعة', 7620.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Prosys Conversion Kit 80 Nt Ir ﻣﺰدوج ﻣﻌﺪE1ﺳﺒﺘﺎ ﻏﻄﺎء Built in accessories                   [R015167]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Sleeve for wall hung bowl & 2 pairs of cover caps white / chrome GP622507ﻏﻄﺎء زوج ٢ ﻣﻊ ﴏف  [R015167]', 'قطعة', 740.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Sleeve for wall hung bowl & 2 pairs of cover caps white / chrome GP622507ﻏﻄﺎء زوج ٢ ﻣﻊ ﴏف  [R015167]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ceraplus urinal flush plate stainless - Kit 2 [A3732XJ]', 'قطعة', 7500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ceraplus urinal flush plate stainless - Kit 2 [A3732XJ]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Urinal flush valve electronic 230 v - Kit 1 [A3795NU]', 'قطعة', 9700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Urinal flush valve electronic 230 v - Kit 1 [A3795NU]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Urinal flush valve electronic battery - Kit 1 [A3794NU]', 'قطعة', 7400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Urinal flush valve electronic battery - Kit 1 [A3794NU]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ceraplus Bsn El_SPT R-Mtd Mix BTR [A7441AA]', 'قطعة', 17200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ceraplus Bsn El_SPT R-Mtd Mix BTR [A7441AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ceraplus Bsn El_SPT R-Mtd Mix MNS ( A6145AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( A6146AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) [A7442AA]', 'قطعة', 16920.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ceraplus Bsn El_SPT R-Mtd Mix MNS ( A6145AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( A6146AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) [A7442AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin Mixer grand with pop-up Drain [A7053AA]', 'قطعة', 6200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin Mixer grand with pop-up Drain [A7053AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer [A7033AA]', 'قطعة', 11050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer [A7033AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Grand Single-lever, ceramic disk, basin fitting with pop up drain. BC941AA [nan]', 'قطعة', 5600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Grand Single-lever, ceramic disk, basin fitting with pop up drain. BC941AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Vessel mixer, 25cm 5lt/min flow rate with Pop-up Drain BC561AA [nan]', 'قطعة', 8715.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Vessel mixer, 25cm 5lt/min flow rate with Pop-up Drain BC561AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Single-lever, ceramic disk, wall exposed bath & shower fitting BC944AA ( B0704 ﺳﺎﺑﻘﺎً اﻟﻜﻮ [nan]', 'قطعة', 6270.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Single-lever, ceramic disk, wall exposed bath & shower fitting BC944AA ( B0704 ﺳﺎﺑﻘﺎً اﻟﻜﻮ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin Mixer, 5lt/min flow rate with Pop-up Drain BC686AA [nan]', 'قطعة', 5410.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin Mixer, 5lt/min flow rate with Pop-up Drain BC686AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer, 5lt/min flow rate with Pop-up Drain BC691AA [nan]', 'قطعة', 5640.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer, 5lt/min flow rate with Pop-up Drain BC691AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower mixer BC692AA BC691AA BC686AA BC692AA [nan]', 'قطعة', 5750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower mixer BC692AA BC691AA BC686AA BC692AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [B0545AA]', 'قطعة', 5060.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [B0545AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer IDYLL CHROME AA DESCRIPTION                                            [B0548AA]', 'قطعة', 5995.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer IDYLL CHROME AA DESCRIPTION                                            [B0548AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [G2715AA]', 'قطعة', 5200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [G2715AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer [G2715AA]', 'قطعة', 6200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer [G2715AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [A1247AA]', 'قطعة', 4500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [A1247AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer Over-rim with Pop-up Drain [A1182AA]', 'قطعة', 4850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer Over-rim with Pop-up Drain [A1182AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer with Douche & Pop-up Drain [G1429AA]', 'قطعة', 6350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer with Douche & Pop-up Drain [G1429AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer [G2500AA]', 'قطعة', 5300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer [G2500AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower only Mixer [A1704AA]', 'قطعة', 4600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower only Mixer [A1704AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Shower Mixer [G2003AA]', 'قطعة', 4830.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Shower Mixer [G2003AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Shower Head [G2001AA]', 'قطعة', 6620.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Shower Head [G2001AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Shower Head & Spout [G2002AA]', 'قطعة', 8610.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Shower Head & Spout [G2002AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with extended lever handle with Pop-up Drain CERAMIX [A1245AA]', 'قطعة', 5660.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with extended lever handle with Pop-up Drain CERAMIX [A1245AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [B0551AA]', 'قطعة', 4430.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [B0551AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer Over-rim with Pop-up Drain [B0552AA]', 'قطعة', 5050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer Over-rim with Pop-up Drain [B0552AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer CERAPLUS [B0553AA]', 'قطعة', 5560.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer CERAPLUS [B0553AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [B7833AA]', 'قطعة', 4470.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [B7833AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with High Swivel Pop-up Drain [B7835AA]', 'قطعة', 7240.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with High Swivel Pop-up Drain [B7835AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer [B7841AA]', 'قطعة', 6220.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer [B7841AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Shower Mixer [G7803AA]', 'قطعة', 4780.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Shower Mixer [G7803AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Shower Head [G7801AA]', 'قطعة', 6620.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Shower Head [G7801AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Shower Head & Spout EUROSTORM [B7841AA]', 'قطعة', 8560.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Shower Head & Spout EUROSTORM [B7841AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin Mixer with pop-up drain [B1708AA]', 'قطعة', 3820.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin Mixer with pop-up drain [B1708AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin Mixer Grand with pop-up drain [B1713AA]', 'قطعة', 4220.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin Mixer Grand with pop-up drain [B1713AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Vessel mixer , 5lt/min flow rate with pop-up drain [B1872AA]', 'قطعة', 7245.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Vessel mixer , 5lt/min flow rate with pop-up drain [B1872AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin mixer with tubular spout BC953AA [nan]', 'قطعة', 5880.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin mixer with tubular spout BC953AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer with pop-up drain BC955AA [nan]', 'قطعة', 4300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer with pop-up drain BC955AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower mixer without accessories BC957AA [nan]', 'قطعة', 5090.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower mixer without accessories BC957AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower built-in mixer [A6758AA]', 'قطعة', 5360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower built-in mixer [A6758AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower built-in mixer ( B1716AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1718AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1721AA ﺳﺎﺑﻘﺎً اﻟﻜ [A6758AA]', 'قطعة', 4410.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower built-in mixer ( B1716AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1718AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1721AA ﺳﺎﺑﻘﺎً اﻟﻜ [A6758AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [G1215AA]', 'قطعة', 4030.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [G1215AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet Mixer with Douche & Pop-up Drain [G1229AA]', 'قطعة', 6500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet Mixer with Douche & Pop-up Drain [G1229AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer [G2200AA]', 'قطعة', 4950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer [G2200AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Shower Mixer [G1203AA]', 'قطعة', 4730.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Shower Mixer [G1203AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Sh.Head [G1201AA]', 'قطعة', 6570.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Sh.Head [G1201AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Built-in Mixer with Sh.Head & Spout [G2200AA]', 'قطعة', 8510.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Built-in Mixer with Sh.Head & Spout [G2200AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lava Mixer with Pop-up Drain [B8577AA]', 'قطعة', 3540.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lava Mixer with Pop-up Drain [B8577AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer SLIMLINE 2 [B8587AA]', 'قطعة', 4820.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer SLIMLINE 2 [B8587AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin mixer with pop up drain BC947AA [nan]', 'قطعة', 3270.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin mixer with pop up drain BC947AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Basin mixer with high spout without pop up drain BC980AA [nan]', 'قطعة', 4320.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Basin mixer with high spout without pop up drain BC980AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bidet mixer with pop up drain BC948AA [nan]', 'قطعة', 4360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bidet mixer with pop up drain BC948AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower mixer BC950AA [nan]', 'قطعة', 4360.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower mixer BC950AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower built-in mixer [A6707AA]', 'قطعة', 5150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower built-in mixer [A6707AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower built-in mixer ( B1262AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1263AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1264AA ﺳﺎﺑﻘﺎً اﻟﻜ [A6706AA]', 'قطعة', 4150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower built-in mixer ( B1262AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1263AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1264AA ﺳﺎﺑﻘﺎً اﻟﻜ [A6706AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Handles & Pop-up Drain [G4813AA]', 'قطعة', 5830.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Handles & Pop-up Drain [G4813AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Swivel Spout, Handles & Pop-up Drain [G4817AA]', 'قطعة', 6600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Swivel Spout, Handles & Pop-up Drain [G4817AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3-Hole, Lava Mixer with Handles & Pop-up Drain [G4821AA]', 'قطعة', 8140.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3-Hole, Lava Mixer with Handles & Pop-up Drain [G4821AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer with Handles [G4811AA]', 'قطعة', 6600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer with Handles [G4811AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower only Mixer with Handles [G4816AA]', 'قطعة', 6000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower only Mixer with Handles [G4816AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3-Hole, Bidet Mixer with Douche, Handles & Pop-up Drain [G4829AA]', 'قطعة', 11550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3-Hole, Bidet Mixer with Douche, Handles & Pop-up Drain [G4829AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Over-rim Bidet Mixer with Handles & Pop-up Drain [G4807AA]', 'قطعة', 7590.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Over-rim Bidet Mixer with Handles & Pop-up Drain [G4807AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Handles & Pop-up Drain [G5013AA]', 'قطعة', 5780.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Handles & Pop-up Drain [G5013AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Swivel Spout, Handles & Pop-up Drain [G5017AA]', 'قطعة', 6550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Swivel Spout, Handles & Pop-up Drain [G5017AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3-Hole, Lava Mixer with Handles & Pop-up Drain [G5021AA]', 'قطعة', 8090.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3-Hole, Lava Mixer with Handles & Pop-up Drain [G5021AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer with Handles [G5011AA]', 'قطعة', 6550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer with Handles [G5011AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower only Mixer with Handles [G5016AA]', 'قطعة', 5940.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower only Mixer with Handles [G5016AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3-Hole, Bidet Mixer with Douche, Handles & Pop-up Drain [G5029AA]', 'قطعة', 11500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3-Hole, Bidet Mixer with Douche, Handles & Pop-up Drain [G5029AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Over-rim Bidet Mixer with Handles & Pop-up Drain [G5007AA]', 'قطعة', 7540.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Over-rim Bidet Mixer with Handles & Pop-up Drain [G5007AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Handles without Pop-up Drain [G1014AA]', 'قطعة', 4140.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Handles without Pop-up Drain [G1014AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with Swivel Spout with Handles without Pop-up Drain [G1017AA]', 'قطعة', 4025.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with Swivel Spout with Handles without Pop-up Drain [G1017AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Lava Mixer with high Swivel Spout with Handles without Pop-up Drain [G1018AA]', 'قطعة', 3105.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Lava Mixer with high Swivel Spout with Handles without Pop-up Drain [G1018AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '1-Hole, Over-rim Bidet Mixer with Handles without Pop-up Drain [G1000AA]', 'قطعة', 6095.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '1-Hole, Over-rim Bidet Mixer with Handles without Pop-up Drain [G1000AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Bath & Shower Mixer with Handles [G2011AA]', 'قطعة', 4830.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bath & Shower Mixer with Handles [G2011AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower only Mixer with Handles [G2016AA]', 'قطعة', 2990.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower only Mixer with Handles [G2016AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pillar Tap with handle [G1005AA]', 'قطعة', 2130.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pillar Tap with handle [G1005AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pop-up Drain & Lift rod (lava,Bidet) [G4750AA]', 'قطعة', 805.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pop-up Drain & Lift rod (lava,Bidet) [G4750AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Angle Stop Valve 1/2 [G4303AA]', 'قطعة', 630.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Angle Stop Valve 1/2 [G4303AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Angle Stop Valve 1/2*1/2 [G4308AA]', 'قطعة', 380.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Angle Stop Valve 1/2*1/2 [G4308AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Angle Stop Valve 1/2*3/8 [G4309AA]', 'قطعة', 380.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Angle Stop Valve 1/2*3/8 [G4309AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'P-Trap 1¼ for Lava P-Trap 1¼ for Bidet & wall hung lava [G8106AA]', 'قطعة', 1520.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'P-Trap 1¼ for Lava P-Trap 1¼ for Bidet & wall hung lava [G8106AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Urinal Flush Valve [G2470AA]', 'قطعة', 3960.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Urinal Flush Valve [G2470AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Idealspray Abs Trigger Spray Set, Chrome [G0925AA]', 'قطعة', 1400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Idealspray Abs Trigger Spray Set, Chrome [G0925AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Square Rainshower Head 30 cm GD025AA [nan]', 'قطعة', 4290.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Square Rainshower Head 30 cm GD025AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Round Rainshower Head 30 cm GD024AA [nan]', 'قطعة', 3900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Round Rainshower Head 30 cm GD024AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua Rain Shower 22 cm GD023AA [nan]', 'قطعة', 1800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua Rain Shower 22 cm GD023AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Evo Diamond Handspray, 115 mm [B2232AA]', 'قطعة', 1400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Evo Diamond Handspray, 115 mm [B2232AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Irain Cube M3 H/Spray 3f Chr 100 mm [B0003AA]', 'قطعة', 1365.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Irain Cube M3 H/Spray 3f Chr 100 mm [B0003AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua H/Spray 3f 100 mm GD952AA [nan]', 'قطعة', 1250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua H/Spray 3f 100 mm GD952AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower Hose G 1/ 2 - G 1/ 2 x 1500 mm GD925AA [nan]', 'قطعة', 650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower Hose G 1/ 2 - G 1/ 2 x 1500 mm GD925AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower Hose G 1/ 2 - G 1/ 2 x 1750 mm GD924AA [nan]', 'قطعة', 780.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower Hose G 1/ 2 - G 1/ 2 x 1750 mm GD924AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Idealrain Wall Arm 30 cm [B9444AA]', 'قطعة', 1110.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Idealrain Wall Arm 30 cm [B9444AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Idealrain Ceiling Arm 15 cm [B9446AA]', 'قطعة', 700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Idealrain Ceiling Arm 15 cm [B9446AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Irain Wall Bracket Cyl 1/ 2 Conn Chr BC807AA [nan]', 'قطعة', 1300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Irain Wall Bracket Cyl 1/ 2 Conn Chr BC807AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Elbow B/I Chrome BC808AA [nan]', 'قطعة', 1000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Elbow B/I Chrome BC808AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'JOY WALL SPOUT 160 mm Chrome BC805AA ١/٢x١/٢ ﻣﻢ ٠٠٥١ ﻣﺮن ﺧﺮﻃﻮم ١/٢x١/٢ ﻣﻢ ٠٥٧١ ﻣﺮن ﺧﺮﻃﻮم G [B2232AA]', 'قطعة', 2000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'JOY WALL SPOUT 160 mm Chrome BC805AA ١/٢x١/٢ ﻣﻢ ٠٠٥١ ﻣﺮن ﺧﺮﻃﻮم ١/٢x١/٢ ﻣﻢ ٠٥٧١ ﻣﺮن ﺧﺮﻃﻮم G [B2232AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Idealrain Shower set ( handspray 1 function +1.5 flex hose + idealrain wall bracket chrome [B9507AA]', 'قطعة', 1170.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Idealrain Shower set ( handspray 1 function +1.5 flex hose + idealrain wall bracket chrome [B9507AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ideal Rain [nan]', 'قطعة', 2180.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ideal Rain [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. with 1 soap holder [B9501AA]', 'قطعة', 1.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. with 1 soap holder [B9501AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ideal Rain [nan]', 'قطعة', 2500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ideal Rain [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. with 1 soap holder [B9503AA]', 'قطعة', 3.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. with 1 soap holder [B9503AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua shower set M1 [nan]', 'قطعة', 2180.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua shower set M1 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. without soap holder [D6050AA]', 'قطعة', 1.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. without soap holder [D6050AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua shower set M3 [nan]', 'قطعة', 2440.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua shower set M3 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. without soap holder [D6051AA]', 'قطعة', 3.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. without soap holder [D6051AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua shower set L1 [nan]', 'قطعة', 2870.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua shower set L1 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. with soap holder [D6045AA]', 'قطعة', 1.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. with soap holder [D6045AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Aqua shower set L3 [nan]', 'قطعة', 3400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Aqua shower set L3 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'fun. with soap holder Aqua Shower Duo With Diverter Shower system, Exposed Connection ﺳﻢ ٨ [B9506AA]', 'قطعة', 3.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'fun. with soap holder Aqua Shower Duo With Diverter Shower system, Exposed Connection ﺳﻢ ٨ [B9506AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Kitchen mixer with high spout BC958AA [nan]', 'قطعة', 5935.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Kitchen mixer with high spout BC958AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Kitchen mixer wall mounted ceraflex BC959AA CERAMIX [nan]', 'قطعة', 4500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Kitchen mixer wall mounted ceraflex BC959AA CERAMIX [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Mount Mixer ( B1727AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1730AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) CHROME AA DESCRIPTION     [A1721AA]', 'قطعة', 6050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Mount Mixer ( B1727AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) ( B1730AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) CHROME AA DESCRIPTION     [A1721AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer IDEALSTREAM [B7845AA]', 'قطعة', 6820.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer IDEALSTREAM [B7845AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer BC951AA Slimline 2 [nan]', 'قطعة', 4620.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer BC951AA Slimline 2 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer [B8592AA]', 'قطعة', 4300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer [B8592AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Mount Mixer [B8599AA]', 'قطعة', 3950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Mount Mixer [B8599AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'SLIMLINE II kitchen mixer deck mounted G1 / 2 KENORA [B0561AA]', 'قطعة', 4610.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'SLIMLINE II kitchen mixer deck mounted G1 / 2 KENORA [B0561AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Mount Mixer with Handles [G5020AA]', 'قطعة', 6270.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Mount Mixer with Handles [G5020AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer with Handles ( B1488AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) BC958AA BC959AA BC951AA [B8599AA]', 'قطعة', 6660.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer with Handles ( B1488AA ﺳﺎﺑﻘﺎً اﻟﻜﻮد) BC958AA BC959AA BC951AA [B8599AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Mount Mixer with Handles [G4820AA]', 'قطعة', 6330.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Mount Mixer with Handles [G4820AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer with Handles EUROPA [G4818AA]', 'قطعة', 6710.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer with Handles EUROPA [G4818AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Wall Mount Mixer with Handles [G1015AA]', 'قطعة', 2950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wall Mount Mixer with Handles [G1015AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer High Spout with Handles [G1019AA]', 'قطعة', 3390.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer High Spout with Handles [G1019AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Pillar Tap with Handle BD022AA CHROME AA DESCRIPTION                            [G4820AA]', 'قطعة', 2130.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Pillar Tap with Handle BD022AA CHROME AA DESCRIPTION                            [G4820AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Deck Mount Mixer BD022AA أﻓﻘﻲ ﺳﻄﺢ ﻋﲇ ﻳﺜﺒﺖ  ﻧﻮرا ﻣﻄﺒﺦ ﺧﻼط( B9332 ﺳﺎﺑﻘﺎً اﻟﻜﻮد) [nan]', 'قطعة', 5600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Deck Mount Mixer BD022AA أﻓﻘﻲ ﺳﻄﺢ ﻋﲇ ﻳﺜﺒﺖ  ﻧﻮرا ﻣﻄﺒﺦ ﺧﻼط( B9332 ﺳﺎﺑﻘﺎً اﻟﻜﻮد) [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Sink Mixer with High Tubular Spout and Pull Out Spout 1F BC176AA [nan]', 'قطعة', 7260.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Sink Mixer with High Tubular Spout and Pull Out Spout 1F BC176AA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'PROSYS' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Sink Mixer with High Tubular and pull out Spout L - Shape 2F BC178AA BC176AA BC178AA CERAL [nan]', 'قطعة', 7430.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Sink Mixer with High Tubular and pull out Spout L - Shape 2F BC178AA BC176AA BC178AA CERAL [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '356700 Spa 213 x 190 x 82 cm [nan]', 'قطعة', 358700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '356700 Spa 213 x 190 x 82 cm [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Jet without Panel [G9274]', 'قطعة', 32.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Jet without Panel [G9274]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '157200 Mini Spa 190 x 170 x 82cm [nan]', 'قطعة', 159200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '157200 Mini Spa 190 x 170 x 82cm [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Jet without Panel ﺳﻢ ٢٨ X ٠٩١ X ٣١٢ ﺳﺒﺎ ﺳﻢ ٢٨ X ٠٧١ X ٠٩١ ﺳﺒﺎ ﻣﻴﻨﻲ WHITE PANELS            [G9286]', 'قطعة', 10.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Jet without Panel ﺳﻢ ٢٨ X ٠٩١ X ٣١٢ ﺳﺒﺎ ﺳﻢ ٢٨ X ٠٧١ X ٠٩١ ﺳﺒﺎ ﻣﻴﻨﻲ WHITE PANELS            [G9286]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7300 Spa 213 cm Panel [G8775]', 'قطعة', 7800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7300 Spa 213 cm Panel [G8775]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7150 Spa 190 cm panel GA160 [nan]', 'قطعة', 7650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7150 Spa 190 cm panel GA160 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7150 Mini Spa 190 cm PANEL [G8835]', 'قطعة', 7650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7150 Mini Spa 190 cm PANEL [G8835]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6650 Mini Spa 170 cm PANEL GA856 اﻷﺳﻌﺎرSUPER SHOWER       ﺳﻮﺑﺮ ﺷﺎور WHITE Description      [nan]', 'قطعة', 7150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6650 Mini Spa 170 cm PANEL GA856 اﻷﺳﻌﺎرSUPER SHOWER       ﺳﻮﺑﺮ ﺷﺎور WHITE Description      [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Super 1000 - 90 x 90 cm G9294 [G9294]', 'قطعة', 176100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Super 1000 - 90 x 90 cm G9294 [G9294]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Super 2000 - 170 x 90 cm right or left G9297 GA386 ( ٠٩ X  ٠٩ - ) ٠٠٠١ ﺷﺎور ﺳﻮﺑﺮ (٠٩ X  ٠٧ [nan]', 'قطعة', 139900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Super 2000 - 170 x 90 cm right or left G9297 GA386 ( ٠٩ X  ٠٩ - ) ٠٠٠١ ﺷﺎور ﺳﻮﺑﺮ (٠٩ X  ٠٧ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Combi- 20 system / panel / chrome finish G9300 GA388 [nan]', 'قطعة', 213200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Combi- 20 system / panel / chrome finish G9300 GA388 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'New Combi-18 system / panel / chrome finish G9301 GA217 [nan]', 'قطعة', 192100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'New Combi-18 system / panel / chrome finish G9301 GA217 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Standard 6 system / panel / chrome finish G9298 GA387 اﻷﺳﻌﺎرSHOWER COLUMN       وﺣﺪة دوش W [nan]', 'قطعة', 155700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Standard 6 system / panel / chrome finish G9298 GA387 اﻷﺳﻌﺎرSHOWER COLUMN       وﺣﺪة دوش W [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower Column - Wall - 180 x 40cm [G9035]', 'قطعة', 68600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower Column - Wall - 180 x 40cm [G9035]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower Column - Wall - 120 x 40cm GA474 [nan]', 'قطعة', 66800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower Column - Wall - 120 x 40cm GA474 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Shower Column - Corner - 123 x 54cm ﻛﺮوم ﺟﻴﺖ ٦ ﺳﻢ( ٠٤ X ٠٨١ ) ﺣﺎﺋﻄﻴﺔ دوش وﺣﺪة ﻛﺮوم ﺟﻴﺖ ٦ ﺳ [G9038]', 'قطعة', 66800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Shower Column - Corner - 123 x 54cm ﻛﺮوم ﺟﻴﺖ ٦ ﺳﻢ( ٠٤ X ٠٨١ ) ﺣﺎﺋﻄﻴﺔ دوش وﺣﺪة ﻛﺮوم ﺟﻴﺖ ٦ ﺳ [G9038]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'TONIC II Freestanding bathtub 180X80 cm White X Black GA256V3 ﺳﻢ ٠٨ x ٠٨١  ﺗﻮ ﺗﻮﻧﻚ ﺑﺎﻧﻴﻮ ﺳ [nan]', 'قطعة', 41000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'TONIC II Freestanding bathtub 180X80 cm White X Black GA256V3 ﺳﻢ ٠٨ x ٠٨١  ﺗﻮ ﺗﻮﻧﻚ ﺑﺎﻧﻴﻮ ﺳ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'DEA Seamless bathtub 175X80 cm White X Black GA255V3 ﺳﻢ ٠٨ x ٥٧١  دﻳﺎ ﺑﺎﻧﻴﻮ ﺳﻢ ٠٨ x ٥٧١  د [nan]', 'قطعة', 35000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'DEA Seamless bathtub 175X80 cm White X Black GA255V3 ﺳﻢ ٠٨ x ٥٧١  دﻳﺎ ﺑﺎﻧﻴﻮ ﺳﻢ ٠٨ x ٥٧١  د [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X 90 cm right White GA25301 - 32800 PLAN Seamless bathtub [nan]', 'قطعة', 160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X 90 cm right White GA25301 - 32800 PLAN Seamless bathtub [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X 90 cm left White GA25401 [nan]', 'قطعة', 160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X 90 cm left White GA25401 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'PLAN Seamless bathtub [nan]', 'قطعة', 34150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'PLAN Seamless bathtub [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X 90 cm right White X Black GA253V3 [nan]', 'قطعة', 160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X 90 cm right White X Black GA253V3 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'PLAN Seamless bathtub [nan]', 'قطعة', 34150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'PLAN Seamless bathtub [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X 90 cm left White X Black GA254V3 ﺳﻢ ٠٩ x ٠٦١ ﺳﻴﻤﻠﺲ ﺑﻼن ﺑﺎﻧﻴﻮ ﺳﻢ ٠٩ x ٠٦١ ﺳﻴﻤﻠﺲ ﺑﻼن ﺑﺎﻧﻴﻮ [nan]', 'قطعة', 160.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X 90 cm left White X Black GA254V3 ﺳﻢ ٠٩ x ٠٦١ ﺳﻴﻤﻠﺲ ﺑﻼن ﺑﺎﻧﻴﻮ ﺳﻢ ٠٩ x ٠٦١ ﺳﻴﻤﻠﺲ ﺑﻼن ﺑﺎﻧﻴﻮ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'MINI CORNER Seamless bathtub 120X120 cm White X Black GA252V3 ﺳﻢ ٠٢١ x ٠٢١  ﻛﻮرﻧﺮ ﻣﻴﻨﻰ ﺑﺎﻧ [nan]', 'قطعة', 33750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'MINI CORNER Seamless bathtub 120X120 cm White X Black GA252V3 ﺳﻢ ٠٢١ x ٠٢١  ﻛﻮرﻧﺮ ﻣﻴﻨﻰ ﺑﺎﻧ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '199900 Turbo 36 system / chrome finish / light [G9262]', 'قطعة', 200400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '199900 Turbo 36 system / chrome finish / light [G9262]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '125600 Combi-20 system / chrome finish [G9100]', 'قطعة', 126100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '125600 Combi-20 system / chrome finish [G9100]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '106100 New Combi-18 system / chrome finish [G9103]', 'قطعة', 106600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '106100 New Combi-18 system / chrome finish [G9103]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '102500 Combi plus-24 system / chrome  finish GA627 PRICES                اﻷﺳﻌﺎرISLAND      [nan]', 'قطعة', 103000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '102500 Combi plus-24 system / chrome  finish GA627 PRICES                اﻷﺳﻌﺎرISLAND      [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14750 Island 180cm round [G8661]', 'قطعة', 15100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14750 Island 180cm round [G8661]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '27100 Island 180 cm Surround Panel G8736 WHITE WHIRLPOOL 180 x 105 cm SMILE                [G8735]', 'قطعة', 27400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '27100 Island 180 cm Surround Panel G8736 WHITE WHIRLPOOL 180 x 105 cm SMILE                [G8735]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '188400 Turbo 36 system / chrome finish/ Light [G9276]', 'قطعة', 188900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '188400 Turbo 36 system / chrome finish/ Light [G9276]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '114100 Combi-20 system / chrome finish [G9194]', 'قطعة', 114600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '114100 Combi-20 system / chrome finish [G9194]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '94800 New Combi-18 system / chrome finish [G9196]', 'قطعة', 95300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '94800 New Combi-18 system / chrome finish [G9196]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 Combi plus-24 system / chrome  finish GA651 [nan]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 Combi plus-24 system / chrome  finish GA651 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '60700 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎرSMILE       ﺳﻤﺎﻳﻞ WHIT [G9029]', 'قطعة', 61200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '60700 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎرSMILE       ﺳﻤﺎﻳﻞ WHIT [G9029]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9300 Smile 180 x 105cm [G8791]', 'قطعة', 9650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9300 Smile 180 x 105cm [G8791]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16400 Smile 180 cm panel G8794 ﺳﻢ ٥٠١ X ٠٨١ ﺳ [G8793]', 'قطعة', 16700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16400 Smile 180 cm panel G8794 ﺳﻢ ٥٠١ X ٠٨١ ﺳ [G8793]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '192800 Turbo 36 system / chrome finish/ Light G9280 [G9284]', 'قطعة', 193300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '192800 Turbo 36 system / chrome finish/ Light G9280 [G9284]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '118400 Combi-20 system / chrome finish G9216 [G9227]', 'قطعة', 118900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '118400 Combi-20 system / chrome finish G9216 [G9227]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '98800 New Combi-18 system / chrome finish G9218 [G9229]', 'قطعة', 99300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '98800 New Combi-18 system / chrome finish G9218 [G9229]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '95800 Combi plus-24 system / chrome  finish GA638 GA637 WHITE PANELS                       [nan]', 'قطعة', 96300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '95800 Combi plus-24 system / chrome  finish GA638 GA637 WHITE PANELS                       [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16400 Tonic 180 x 120 cm right panel G8831 [G8830]', 'قطعة', 16700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16400 Tonic 180 x 120 cm right panel G8831 [G8830]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16400 Tonic 180 x 120 cm left panel G8831 GA551 ˾˽ ﺳﻢ ٠٢١ X ٠٨١ ﺗﻮﻧﻚ ﺟﺎﻧﺐ ﺷ ﺳﻢ ٠٢١ X ٠٨١ ﺗ [nan]', 'قطعة', 16700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16400 Tonic 180 x 120 cm left panel G8831 GA551 ˾˽ ﺳﻢ ٠٢١ X ٠٨١ ﺗﻮﻧﻚ ﺟﺎﻧﺐ ﺷ ﺳﻢ ٠٢١ X ٠٨١ ﺗ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12900 Tonic 180 x 120 With Chrome handgrips G8822 G8834ﺷ او ˾˽ ﻛﺮوم ɬ ﺳﻢ ٠٢١ X ٠٨١ ﺗﻮﻧﻚ PR [nan]', 'قطعة', 13250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12900 Tonic 180 x 120 With Chrome handgrips G8822 G8834ﺷ او ˾˽ ﻛﺮوم ɬ ﺳﻢ ٠٢١ X ٠٨١ ﺗﻮﻧﻚ PR [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '19800 Media Plus 180x90 cm w.panel one piece GA260 [nan]', 'قطعة', 20250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '19800 Media Plus 180x90 cm w.panel one piece GA260 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '18900 Media Plus 175 x 80 cm w.panel one piece GA250 ﺳﻢ ٠٩ X ٠٨١ ﺑﻠﺲ ﻣﻴﺪﻳﺎ [nan]', 'قطعة', 19350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '18900 Media Plus 175 x 80 cm w.panel one piece GA250 ﺳﻢ ٠٩ X ٠٨١ ﺑﻠﺲ ﻣﻴﺪﻳﺎ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X ٥٧١ ﺑﻠﺲ ﻣﻴﺪﻳﺎ [nan]', 'قطعة', 8.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X ٥٧١ ﺑﻠﺲ ﻣﻴﺪﻳﺎ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '192100 Turbo 36 system /  chrome finish/ Light GA487 [nan]', 'قطعة', 192600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '192100 Turbo 36 system /  chrome finish/ Light GA487 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '117600 Combi-20 system /  chrome finish GA486 [nan]', 'قطعة', 118100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '117600 Combi-20 system /  chrome finish GA486 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '97900 New Combi-18 system /  chrome finish GA484 [nan]', 'قطعة', 98400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '97900 New Combi-18 system /  chrome finish GA484 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '94600 Combi plus-24 system / chrome  finish GA670 WHIRLPOOL 140 x 140 cm NIAGRA PLUS     ﻣ [nan]', 'قطعة', 95100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '94600 Combi plus-24 system / chrome  finish GA670 WHIRLPOOL 140 x 140 cm NIAGRA PLUS     ﻣ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '190300 Turbo 36 system / chrome finish/ Light [G9277]', 'قطعة', 190800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '190300 Turbo 36 system / chrome finish/ Light [G9277]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '115800 Combi-20 system / chrome finish [G9203]', 'قطعة', 116300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '115800 Combi-20 system / chrome finish [G9203]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '96300 New Combi-18 system / chrome finish [G9206]', 'قطعة', 96800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '96300 New Combi-18 system / chrome finish [G9206]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92800 Combi plus-24 system / chrome  finish GA669 [nan]', 'قطعة', 93300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92800 Combi plus-24 system / chrome  finish GA669 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '62700 Standard-8 system / chrome finish WHIRLPOOL 130 x 130 cm NIAGRA PLUS       ﻣﺴﺎج( ﺷﻼل [G9048]', 'قطعة', 63200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '62700 Standard-8 system / chrome finish WHIRLPOOL 130 x 130 cm NIAGRA PLUS       ﻣﺴﺎج( ﺷﻼل [G9048]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '114100 Combi-20 system / chrome finish [G9220]', 'قطعة', 114600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '114100 Combi-20 system / chrome finish [G9220]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '94600 New Combi-18 system / chrome finish [G9222]', 'قطعة', 95100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '94600 New Combi-18 system / chrome finish [G9222]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 Combi plus-24 system / chrome  finish GA668 [nan]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 Combi plus-24 system / chrome  finish GA668 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '61100 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎر WHITE DESCRIPTION     [G9061]', 'قطعة', 61600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '61100 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎر WHITE DESCRIPTION     [G9061]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12300 Niagra Plus 150 x 150 cm GA461 [nan]', 'قطعة', 12650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12300 Niagra Plus 150 x 150 cm GA461 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11000 Niagra Plus 140 x 140cm [G8806]', 'قطعة', 11350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11000 Niagra Plus 140 x 140cm [G8806]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9700 Niagra Plus 130 x 130cm [G8828]', 'قطعة', 10000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9700 Niagra Plus 130 x 130cm [G8828]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13950 Niagra plus 150 panel GA483 GA477 [nan]', 'قطعة', 14250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13950 Niagra plus 150 panel GA483 GA477 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13500 Niagra plus 140 panel G8809 GA394 [nan]', 'قطعة', 13800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13500 Niagra plus 140 panel G8809 GA394 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12800 Niagra plus 130 panel G8825 ﺷﻼل ﺳﻢ ٠٥١ X ٠٥١ ﺑﻠﺲ ﻧﻴﺎﺟﺮا ﺷﻼل ﺳﻢ ٠٤١ X ٠٤١ ﺑﻠﺲ ﻧﻴﺎﺟﺮا  [G8824]', 'قطعة', 13100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12800 Niagra plus 130 panel G8825 ﺷﻼل ﺳﻢ ٠٥١ X ٠٥١ ﺑﻠﺲ ﻧﻴﺎﺟﺮا ﺷﻼل ﺳﻢ ٠٤١ X ٠٤١ ﺑﻠﺲ ﻧﻴﺎﺟﺮا  [G8824]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '186600 Turbo 36 system / chrome finish/ Light [G9275]', 'قطعة', 187100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '186600 Turbo 36 system / chrome finish/ Light [G9275]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '112300 Combi-20 system / chrome finish [G9180]', 'قطعة', 112800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '112300 Combi-20 system / chrome finish [G9180]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92800 New Combi-18 system / chrome finish [G9182]', 'قطعة', 93300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92800 New Combi-18 system / chrome finish [G9182]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '89300 Combi plus-24 system / chrome  finish GA 656 [nan]', 'قطعة', 89800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '89300 Combi plus-24 system / chrome  finish GA 656 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '59200 Standard-8 system / chrome finish WHITE WHIRLPOOL 130 x 130cm CREDO               ﻣﺴ [G9015]', 'قطعة', 59700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '59200 Standard-8 system / chrome finish WHITE WHIRLPOOL 130 x 130cm CREDO               ﻣﺴ [G9015]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '110600 Combi-20 system / chrome finish [G9186]', 'قطعة', 111100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '110600 Combi-20 system / chrome finish [G9186]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 New Combi-18 system / chrome finish [G8528]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 New Combi-18 system / chrome finish [G8528]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '57400 Standard-8 system / chrome finish WHITE WHIRLPOOL 135 x 135cm CREDO                  [G9020]', 'قطعة', 57900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '57400 Standard-8 system / chrome finish WHITE WHIRLPOOL 135 x 135cm CREDO                  [G9020]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '185800 Turbo 36 system / chrome finish/ Light [G9268]', 'قطعة', 186300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '185800 Turbo 36 system / chrome finish/ Light [G9268]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '111600 Combi-20 system / chrome finish [G9147]', 'قطعة', 112100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '111600 Combi-20 system / chrome finish [G9147]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92000 New Combi-18 system / chrome finish [G9149]', 'قطعة', 92500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92000 New Combi-18 system / chrome finish [G9149]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '88500 Combi plus-24 system / chrome  finish GA655 [nan]', 'قطعة', 89000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '88500 Combi plus-24 system / chrome  finish GA655 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '58200 Standard-8 system / chrome finish WHITE WHIRLPOOL 150 x 150cm CREDO                  [G8957]', 'قطعة', 58700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '58200 Standard-8 system / chrome finish WHITE WHIRLPOOL 150 x 150cm CREDO                  [G8957]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '188400 Turbo 36 system /  chrome finish/ Light GA109 [nan]', 'قطعة', 188900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '188400 Turbo 36 system /  chrome finish/ Light GA109 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '114100 Combi-20 system /  chrome finish GA110 [nan]', 'قطعة', 114600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '114100 Combi-20 system /  chrome finish GA110 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '94600 New Combi-18 system /  chrome finish GA111 [nan]', 'قطعة', 95100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '94600 New Combi-18 system /  chrome finish GA111 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 Combi plus-24 system / chrome  finish GA112 PRICES                اﻷﺳﻌﺎر WHITE DESCR [nan]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 Combi plus-24 system / chrome  finish GA112 PRICES                اﻷﺳﻌﺎر WHITE DESCR [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9300 Credo 150 x 150cm GA963 [nan]', 'قطعة', 9600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9300 Credo 150 x 150cm GA963 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8050 Credo 140 x 140cm [G8782]', 'قطعة', 8400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8050 Credo 140 x 140cm [G8782]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7500 Credo 135 x 135cm [G8710]', 'قطعة', 7800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7500 Credo 135 x 135cm [G8710]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7100 Credo 130 x 130cm [G8786]', 'قطعة', 7400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7100 Credo 130 x 130cm [G8786]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14100 Credo 150 cm side panel GA148 GA105 [nan]', 'قطعة', 14400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14100 Credo 150 cm side panel GA148 GA105 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13300 Credo 140 cm side panel GA522 GA396 [nan]', 'قطعة', 13600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13300 Credo 140 cm side panel GA522 GA396 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12900 Credo 135 cm side panel G8740 GA395 [nan]', 'قطعة', 13200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12900 Credo 135 cm side panel G8740 GA395 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12800 Credo 130 cm side panel G8666 ﺳﻢ ٠٥١ X ٠٥١ ﻛﺮﻳﺪو ﺳﻢ ٠٤١ X ٠٤١ ﻛﺮﻳﺪو ﺳﻢ ٥٣١ X ٥٣١ ﻛﺮﻳ [G8739]', 'قطعة', 13100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12800 Credo 130 cm side panel G8666 ﺳﻢ ٠٥١ X ٠٥١ ﻛﺮﻳﺪو ﺳﻢ ٠٤١ X ٠٤١ ﻛﺮﻳﺪو ﺳﻢ ٥٣١ X ٥٣١ ﻛﺮﻳ [G8739]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8000 Stream 140 x 140 cm [G8813]', 'قطعة', 8300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8000 Stream 140 x 140 cm [G8813]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7500 Stream 135 x 135 cm GA729 [nan]', 'قطعة', 7800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7500 Stream 135 x 135 cm GA729 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7100 Stream 130 x 130 cm GA728 [nan]', 'قطعة', 7400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7100 Stream 130 x 130 cm GA728 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6900 Stream 125 x 125 cm [G8844]', 'قطعة', 7200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6900 Stream 125 x 125 cm [G8844]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Stream 120 x 120 cm [G8802]', 'قطعة', 6900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Stream 120 x 120 cm [G8802]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6400 Stream 115 x 115 cm [G8898]', 'قطعة', 6700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6400 Stream 115 x 115 cm [G8898]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13300 Stream 140 cm  panel G8815 GA399 [nan]', 'قطعة', 13600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13300 Stream 140 cm  panel G8815 GA399 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12900 Stream 135 cm  panel GA739 [nan]', 'قطعة', 13200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12900 Stream 135 cm  panel GA739 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12800 Stream 130 cm  panel GA738 [nan]', 'قطعة', 13100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12800 Stream 130 cm  panel GA738 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12600 Stream 125 cm  panel GA513 GA398 [nan]', 'قطعة', 12900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12600 Stream 125 cm  panel GA513 GA398 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12500 Stream 120 cm  panel GA508 GA397 [nan]', 'قطعة', 12800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12500 Stream 120 cm  panel GA508 GA397 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12300 Stream 115 cm panel ﺳﻢ ٠٤١ X ٠٤١ ﺳﱰﻳﻢ ﺳﻢ ٥٣١ X ٥٣١ ﺳﱰﻳﻢ ﺳﻢ ٠٣١ X ٠٣١ ﺳﱰﻳﻢ ﺳﻢ ٥٢١ X ٥ [G8804]', 'قطعة', 12600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12300 Stream 115 cm panel ﺳﻢ ٠٤١ X ٠٤١ ﺳﱰﻳﻢ ﺳﻢ ٥٣١ X ٥٣١ ﺳﱰﻳﻢ ﺳﻢ ٠٣١ X ٠٣١ ﺳﱰﻳﻢ ﺳﻢ ٥٢١ X ٥ [G8804]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '112300 Combi-20 system / chrome finish [G9207]', 'قطعة', 112800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '112300 Combi-20 system / chrome finish [G9207]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92800 New Combi-18 system / chrome finish [G9208]', 'قطعة', 93300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92800 New Combi-18 system / chrome finish [G9208]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '89300 Combi plus-24 system / chrome  finish GA650 [nan]', 'قطعة', 89800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '89300 Combi plus-24 system / chrome  finish GA650 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '59200 Standard-8 system / chrome finish WHITE WHIRLPOOL 125 x 125 cm STREAM                [G9058]', 'قطعة', 59700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '59200 Standard-8 system / chrome finish WHITE WHIRLPOOL 125 x 125 cm STREAM                [G9058]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109800 Combi-20 system / chrome finish [G7326]', 'قطعة', 110300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109800 Combi-20 system / chrome finish [G7326]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90200 New Combi-18 system / chrome finish [G7336]', 'قطعة', 90700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90200 New Combi-18 system / chrome finish [G7336]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '86800 Combi plus-24 system / chrome  finish GA649 [nan]', 'قطعة', 87300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '86800 Combi plus-24 system / chrome  finish GA649 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 120 x 120 cm STREAM                [G9070]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 120 x 120 cm STREAM                [G9070]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55800 Standard-8 system / chrome finish G9039ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم [nan]', 'قطعة', 56300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55800 Standard-8 system / chrome finish G9039ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109800 Combi-20 system / chrome finish [G9158]', 'قطعة', 110300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109800 Combi-20 system / chrome finish [G9158]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90200 New Combi-18 system / chrome finish [G9160]', 'قطعة', 90700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90200 New Combi-18 system / chrome finish [G9160]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '86800 Combi plus-24 system / chrome  finish GA661 [nan]', 'قطعة', 87300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '86800 Combi plus-24 system / chrome  finish GA661 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 135 x 135 cm CONTOUR      ﻣﺴﺎج ﺳﻢ  [G8968]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 135 x 135 cm CONTOUR      ﻣﺴﺎج ﺳﻢ  [G8968]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '111600 Combi-20 system /  chrome finish GA061 [nan]', 'قطعة', 112100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '111600 Combi-20 system /  chrome finish GA061 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92000 New Combi-18 system / chrome finish [G9253]', 'قطعة', 92500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92000 New Combi-18 system / chrome finish [G9253]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '88500 Combi plus-24 system / chrome  finish GA662 [nan]', 'قطعة', 89000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '88500 Combi plus-24 system / chrome  finish GA662 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '58200 Standard-8 system / chrome finish X X  [G9085]', 'قطعة', 58700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '58200 Standard-8 system / chrome finish X X  [G9085]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7500 Contour 135 x 135 cm [G8897]', 'قطعة', 7800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7500 Contour 135 x 135 cm [G8897]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6900 Contour 125 x 125 cm [G8715]', 'قطعة', 7200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6900 Contour 125 x 125 cm [G8715]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6000 Contour 110 x 110 cm GA961 [nan]', 'قطعة', 6300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6000 Contour 110 x 110 cm GA961 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12900 Contour 135 cm side panel GA536 GA400 [nan]', 'قطعة', 13200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12900 Contour 135 cm side panel GA536 GA400 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12600 Contour 125 cm side panel G8708 [G8707]', 'قطعة', 12900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12600 Contour 125 cm side panel G8708 [G8707]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12400 Contour 110 cm side panel GA103 ﺳﻢ ٥٣١ X ٥٣١ ﻛﻮﻧﺘﻮر ﺳﻢ ٥٢١ X ٥٢١ ﻛﻮﻧﺘﻮر ﺳﻢ ٠١١ X ٠١١ [nan]', 'قطعة', 12700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12400 Contour 110 cm side panel GA103 ﺳﻢ ٥٣١ X ٥٣١ ﻛﻮﻧﺘﻮر ﺳﻢ ٥٢١ X ٥٢١ ﻛﻮﻧﺘﻮر ﺳﻢ ٠١١ X ٠١١ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55800 Standard-8 system / chrome finish GA108ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]', 'قطعة', 56300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55800 Standard-8 system / chrome finish GA108ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Mini Corner 120x120 cm GA962 [nan]', 'قطعة', 6900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Mini Corner 120x120 cm GA962 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6000 Mini Corner 110x110 cm GA003 [nan]', 'قطعة', 6300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6000 Mini Corner 110x110 cm GA003 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5800 Mini Corner 100x100 cm GA002 [nan]', 'قطعة', 6100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5800 Mini Corner 100x100 cm GA002 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12500 Mini Corner 120 panel GA101 GA102 [nan]', 'قطعة', 12800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12500 Mini Corner 120 panel GA101 GA102 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11200 Mini Corner 110 panel GA401 [nan]', 'قطعة', 11500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11200 Mini Corner 110 panel GA401 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11000 Mini Corner 100 panel GA006 ﺳﻢ ٠٢١ X ٠٢١ ﻛﻮرﻧﺮ ﻣﻴﻨﻲ ﺳﻢ ٠١١ X ٠١١ ﻛﻮرﻧﺮ ﻣﻴﻨﻲ ﺳﻢ ٠٠١ X [nan]', 'قطعة', 11300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11000 Mini Corner 100 panel GA006 ﺳﻢ ٠٢١ X ٠٢١ ﻛﻮرﻧﺮ ﻣﻴﻨﻲ ﺳﻢ ٠١١ X ٠١١ ﻛﻮرﻧﺮ ﻣﻴﻨﻲ ﺳﻢ ٠٠١ X [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '187500 Combi 36 system /  chrome finish / light G9288 GA065 [nan]', 'قطعة', 188000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '187500 Combi 36 system /  chrome finish / light G9288 GA065 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '113300 Combi-20 system / chrome finish G9237 [G9234]', 'قطعة', 113800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '113300 Combi-20 system / chrome finish G9237 [G9234]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '93800 New Combi-18 system / chrome finish G9239 [G9236]', 'قطعة', 94300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '93800 New Combi-18 system / chrome finish G9239 [G9236]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90200 Combi plus-24 system / chrome  finish GA633   GA631 [nan]', 'قطعة', 90700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90200 Combi plus-24 system / chrome  finish GA633   GA631 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '59900 Standard-8 system / chrome finish G9077 WHITE PANELS                                 [G9072]', 'قطعة', 60400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '59900 Standard-8 system / chrome finish G9077 WHITE PANELS                                 [G9072]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13650 Plan 170x110cm Right Panel G8855 [G8854]', 'قطعة', 13950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13650 Plan 170x110cm Right Panel G8855 [G8854]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13650 Plan 170x110cm Left Panel G8855 GA548 ˾˽  ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن ﺟﺎﻧﺐ ﺷ  ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن  [nan]', 'قطعة', 13950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13650 Plan 170x110cm Left Panel G8855 GA548 ˾˽  ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن ﺟﺎﻧﺐ ﺷ  ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12300 Plan 160x90cm Panel G8862 GA547 [nan]', 'قطعة', 12600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12300 Plan 160x90cm Panel G8862 GA547 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12950 Plan 150x100cm Panel GA107 GA106 ﺳﻢ ٠٩ X ٠٦١ ﺑﻼن ﺟﺎﻧﺐ ﺳﻢ ٠٠١ X ٠٥١ ﺑﻼن ﺟﺎﻧﺐ PRICES   [nan]', 'قطعة', 13250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12950 Plan 150x100cm Panel GA107 GA106 ﺳﻢ ٠٩ X ٠٦١ ﺑﻼن ﺟﺎﻧﺐ ﺳﻢ ٠٠١ X ٠٥١ ﺑﻼن ﺟﺎﻧﺐ PRICES   [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8100 Plan 170 x 110 G8849 [G8848]', 'قطعة', 8400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8100 Plan 170 x 110 G8849 [G8848]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7200 Plan 160 x 90 GA951 GA952 [nan]', 'قطعة', 7500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7200 Plan 160 x 90 GA951 GA952 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7500 Plan 150 x 100 GA948 GA949 ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن ﺳﻢ ٠٩ X ٠٦١ ﺑﻼن ﺳﻢ ٠٠١ X ٠٥١ ﺑﻼن [nan]', 'قطعة', 7800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7500 Plan 150 x 100 GA948 GA949 ﺳﻢ ٠١١ X ٠٧١ ﺑﻼن ﺳﻢ ٠٩ X ٠٦١ ﺑﻼن ﺳﻢ ٠٠١ X ٠٥١ ﺑﻼن [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109800 Combi-20 system / chrome finish G9133 [G9129]', 'قطعة', 110300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109800 Combi-20 system / chrome finish G9133 [G9129]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90200 New Combi-18 system / chrome finish G9135 [G9131]', 'قطعة', 90700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90200 New Combi-18 system / chrome finish G9135 [G9131]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '86800 Combi plus-24 system / chrome  finish GA653   GA652 [nan]', 'قطعة', 87300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '86800 Combi plus-24 system / chrome  finish GA653   GA652 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish G8948 PRICES                اﻷﺳﻌﺎرSURF       ﺳﻴﺮف  [G8945]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish G8948 PRICES                اﻷﺳﻌﺎرSURF       ﺳﻴﺮف  [G8945]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7100 Surf 160 x 90cm G8689 [G8688]', 'قطعة', 7400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7100 Surf 160 x 90cm G8689 [G8688]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6100 Surf 150 x 80 cm GA464 GA465 ﺳﻢ ٠٩ X ٠٦١ ﺳ ﺳﻢ   ٠٨  X ٠٥١  ﺳ WHITE PANELS             [nan]', 'قطعة', 6400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6100 Surf 150 x 80 cm GA464 GA465 ﺳﻢ ٠٩ X ٠٦١ ﺳ ﺳﻢ   ٠٨  X ٠٥١  ﺳ WHITE PANELS             [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12300 Surf 160x90 cm Right Panel G8663 [G8662]', 'قطعة', 12600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12300 Surf 160x90 cm Right Panel G8663 [G8662]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12300 Surf 160x90 cm Left Panel G8659 GA547 [nan]', 'قطعة', 12600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12300 Surf 160x90 cm Left Panel G8659 GA547 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12100 Surf 150x80 cm Right Panel GA480 [nan]', 'قطعة', 12400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12100 Surf 150x80 cm Right Panel GA480 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12100 Surf 150x80 cm Left Panel GA685 ﺳﻢ ٠٩ X ٠٦١ ˾˽ ﺳ ﺟﺎﻧﺐ ﺳﻢ ٠٩ X ٠٦١ ﺷ ﺳ ﺟﺎﻧﺐ ˾˽ ﺳﻢ ٠٨  [nan]', 'قطعة', 12400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12100 Surf 150x80 cm Left Panel GA685 ﺳﻢ ٠٩ X ٠٦١ ˾˽ ﺳ ﺟﺎﻧﺐ ﺳﻢ ٠٩ X ٠٦١ ﺷ ﺳ ﺟﺎﻧﺐ ˾˽ ﺳﻢ ٠٨  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '202400 Turbo 36 system / chrome finish/ Light [G8586]', 'قطعة', 202900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '202400 Turbo 36 system / chrome finish/ Light [G8586]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '128500 Combi-20 system / chrome finish [G8587]', 'قطعة', 129000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '128500 Combi-20 system / chrome finish [G8587]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '108800 New Combi-18 system / chrome finish [G7375]', 'قطعة', 109300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '108800 New Combi-18 system / chrome finish [G7375]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '105100 Combi plus-24 system / chrome  finish GA640 PRICES                اﻷﺳﻌﺎرREUNION     [nan]', 'قطعة', 105600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '105100 Combi plus-24 system / chrome  finish GA640 PRICES                اﻷﺳﻌﺎرREUNION     [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14300 Reunion 200 x 130 cm [G8850]', 'قطعة', 14700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14300 Reunion 200 x 130 cm [G8850]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '23600 Reunion 200 cm side panel G8917 [G8916]', 'قطعة', 23900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '23600 Reunion 200 cm side panel G8917 [G8916]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3500 Reunion 130 cm right or left panel G8918 اﻟﻔﺎﻳﻆ و ﺑﺎﻟﻄﺎﺑﻖ ﺳﻢ ٠٣١ X ٠٠٢ ﻳﻮﻧﻴﻮن ري WHIT [G8918]', 'قطعة', 3800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3500 Reunion 130 cm right or left panel G8918 اﻟﻔﺎﻳﻆ و ﺑﺎﻟﻄﺎﺑﻖ ﺳﻢ ٠٣١ X ٠٠٢ ﻳﻮﻧﻴﻮن ري WHIT [G8918]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '191100 Turbo 36 system / chrome finish/ Light [G7940]', 'قطعة', 191600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '191100 Turbo 36 system / chrome finish/ Light [G7940]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '116800 Combi-20 system / chrome finish [G9089]', 'قطعة', 117300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '116800 Combi-20 system / chrome finish [G9089]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '97300 New Combi-18 system / chrome finish [G9091]', 'قطعة', 97800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '97300 New Combi-18 system / chrome finish [G9091]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '93800 Combi plus-24 system / chrome  finish GA660 PRICES                اﻷﺳﻌﺎرCOPACABANA   [nan]', 'قطعة', 94300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '93800 Combi plus-24 system / chrome  finish GA660 PRICES                اﻷﺳﻌﺎرCOPACABANA   [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9100 Copacabana 185 x 105cm with handgrips [G8473]', 'قطعة', 9500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9100 Copacabana 185 x 105cm with handgrips [G8473]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12350 Copacabana 185 cm side panel G8723 [G8722]', 'قطعة', 12650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12350 Copacabana 185 cm side panel G8723 [G8722]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3400 Copacabana Right or Left end panel 105cm G8726 ﻛﺮوم ɬ ﺳﻢ ٥٠١ X ٥٨١ ﻛﻮﺑﺎﻛﺎﺑﺎﻧﺎ [G8726]', 'قطعة', 3700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3400 Copacabana Right or Left end panel 105cm G8726 ﻛﺮوم ɬ ﺳﻢ ٥٠١ X ٥٨١ ﻛﻮﺑﺎﻛﺎﺑﺎﻧﺎ [G8726]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '110600 Combi-20 system / chrome finish [G8637]', 'قطعة', 111100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '110600 Combi-20 system / chrome finish [G8637]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 New Combi-18 system / chrome finish [G8638]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 New Combi-18 system / chrome finish [G8638]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '87600 Combi plus-24 system / chrome  finish GA664 [nan]', 'قطعة', 88100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '87600 Combi plus-24 system / chrome  finish GA664 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '57400 Standard-8 system / chrome finish/without panel PRICES                اﻷﺳﻌﺎرCONCERTO [G7388]', 'قطعة', 57900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '57400 Standard-8 system / chrome finish/without panel PRICES                اﻷﺳﻌﺎرCONCERTO [G7388]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7000 Concerto 180 x 80cm [G8636]', 'قطعة', 7250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7000 Concerto 180 x 80cm [G8636]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'cm side panel GA575 [G8645]', 'قطعة', 11600.0, 0, 0, true, 'ايديال', '180.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'cm side panel GA575 [G8645]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2500 Right or Left end panel 80 cm G8746 ﺳﻢ ٠٨ X ٠٨١ ﻛﻮﻧﺸ PRICES                اﻷﺳﻌﺎرNEW  [G8746]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2500 Right or Left end panel 80 cm G8746 ﺳﻢ ٠٨ X ٠٨١ ﻛﻮﻧﺸ PRICES                اﻷﺳﻌﺎرNEW  [G8746]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7300 New Esedra Bathtub 180 x 80 cm GA74101 [nan]', 'قطعة', 7550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7300 New Esedra Bathtub 180 x 80 cm GA74101 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7000 New Esedra Bathtub 170 x 80 cm GA74001 [nan]', 'قطعة', 7250.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7000 New Esedra Bathtub 170 x 80 cm GA74001 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6800 New Esedra Bathtub 170 x 75 cm GA72001 [nan]', 'قطعة', 7050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6800 New Esedra Bathtub 170 x 75 cm GA72001 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6400 New Esedra Bathtub 170 x 70 cm GA72201 [nan]', 'قطعة', 6650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6400 New Esedra Bathtub 170 x 70 cm GA72201 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'TONIC' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5900 New Esedra Bathtub 150 x 70 cm GA73201 أﺑﻴﺾ ﺳﻢ ٠٨ X ٠٨١ اﻳﺴﻴﺪرا ﻧﻴﻮ أﺑﻴﺾ ﺳﻢ ٠٨ X ٠٧١  [nan]', 'قطعة', 6150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5900 New Esedra Bathtub 150 x 70 cm GA73201 أﺑﻴﺾ ﺳﻢ ٠٨ X ٠٨١ اﻳﺴﻴﺪرا ﻧﻴﻮ أﺑﻴﺾ ﺳﻢ ٠٨ X ٠٧١  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109900 Combi-20 system / chrome finish [G9254]', 'قطعة', 110400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109900 Combi-20 system / chrome finish [G9254]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90400 New Combi-18 system / chrome finish [G9256]', 'قطعة', 90900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90400 New Combi-18 system / chrome finish [G9256]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '87100 Combi plus-24 system / chrome  finish GA644 [nan]', 'قطعة', 87600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '87100 Combi plus-24 system / chrome  finish GA644 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56600 Standard-8 system / chrome finish WHITE WHIRLPOOL 190 x 90cm SPACE                   [G9087]', 'قطعة', 57100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56600 Standard-8 system / chrome finish WHITE WHIRLPOOL 190 x 90cm SPACE                   [G9087]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '187500 Turbo 36 system /  gold finish/ Light GA521 [nan]', 'قطعة', 188000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '187500 Turbo 36 system /  gold finish/ Light GA521 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '113300 Combi-20 system /  chrome finish GA520 [nan]', 'قطعة', 113800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '113300 Combi-20 system /  chrome finish GA520 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '93800 New Combi-18 system /  chrome finish GA518 WHITE WHIRLPOOL 180 x 80cm SPACE          [nan]', 'قطعة', 94300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '93800 New Combi-18 system /  chrome finish GA518 WHITE WHIRLPOOL 180 x 80cm SPACE          [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '110600 Combi-20 system /  chrome finish GA516 [nan]', 'قطعة', 111100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '110600 Combi-20 system /  chrome finish GA516 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '91100 New Combi-18 system /  chrome finish GA515 [nan]', 'قطعة', 91600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '91100 New Combi-18 system /  chrome finish GA515 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '57400 Standard-8 system / chrome finish GA514 WHITE WHIRLPOOL 170 x 75 cm SPACE            [nan]', 'قطعة', 57900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '57400 Standard-8 system / chrome finish GA514 WHITE WHIRLPOOL 170 x 75 cm SPACE            [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109800 Combi-20 system / chrome finish [G9248]', 'قطعة', 110300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109800 Combi-20 system / chrome finish [G9248]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90200 New Combi-18 system / chrome finish [G9250]', 'قطعة', 90700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90200 New Combi-18 system / chrome finish [G9250]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '86800 Combi plus-24 system / chrome  finish GA643 [nan]', 'قطعة', 87300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '86800 Combi plus-24 system / chrome  finish GA643 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 150 x 80 cm SPACE                  [G9082]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish WHITE WHIRLPOOL 150 x 80 cm SPACE                  [G9082]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55800 Standard-8 system / chrome finish G9083ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]', 'قطعة', 56300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55800 Standard-8 system / chrome finish G9083ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7400 Space 190 x 90 cm with seat GA463 [nan]', 'قطعة', 7650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7400 Space 190 x 90 cm with seat GA463 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6500 Space 180 x 80 cm with seat GA470 [nan]', 'قطعة', 6750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6500 Space 180 x 80 cm with seat GA470 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6200 Space 170 x 80 cm with seat [G8900]', 'قطعة', 6450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6200 Space 170 x 80 cm with seat [G8900]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5800 Space 170 x 75 cm with seat [G8861]', 'قطعة', 6050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5800 Space 170 x 75 cm with seat [G8861]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5800 Space 150 x 80 cm with seat [G8896]', 'قطعة', 6050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5800 Space 150 x 80 cm with seat [G8896]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4500 Space 120 x 70 cm with seat GA001 [nan]', 'قطعة', 4750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4500 Space 120 x 70 cm with seat GA001 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11800 Panel 190 cm GA578 [G8941]', 'قطعة', 12100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11800 Panel 190 cm GA578 [G8941]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11300 Panel 180 cm GA575 [G8645]', 'قطعة', 11600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11300 Panel 180 cm GA575 [G8645]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm G8695 GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm G8695 GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm G8758 GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm G8758 GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8500 Panel 120 cm [G8643]', 'قطعة', 8800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8500 Panel 120 cm [G8643]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2600 Small panel 90 cm right or left G8417 [G8417]', 'قطعة', 2800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2600 Small panel 90 cm right or left G8417 [G8417]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2500 Small panel 80 cm right or left G8746 [G8746]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2500 Small panel 80 cm right or left G8746 [G8746]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2100 Small panel 75 cm right or left G8641 [G8641]', 'قطعة', 2300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2100 Small panel 75 cm right or left G8641 [G8641]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'SPACE' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left G8570 GA136 ﺑﻜﺮﳻ ﺳﻢ ٠٩ X ٠٩١ ﺳﺒﻴﺲ ﺑﻜﺮﳻ ﺳﻢ ٠٨ X ٠٨١ ﺳﺒ [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left G8570 GA136 ﺑﻜﺮﳻ ﺳﻢ ٠٩ X ٠٩١ ﺳﺒﻴﺲ ﺑﻜﺮﳻ ﺳﻢ ٠٨ X ٠٨١ ﺳﺒ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish GA302ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish GA302ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7100 CONNECT 180x80 GA719 [nan]', 'قطعة', 7350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7100 CONNECT 180x80 GA719 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6500 CONNECT 170x80 GA718 [nan]', 'قطعة', 6750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6500 CONNECT 170x80 GA718 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6300 CONNECT 170x75 GA717 [nan]', 'قطعة', 6550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6300 CONNECT 170x75 GA717 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6100 CONNECT 170 x 70 GA010 [nan]', 'قطعة', 6350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6100 CONNECT 170 x 70 GA010 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5700 CONNECT 150x70 GA716 [nan]', 'قطعة', 5950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5700 CONNECT 150x70 GA716 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5400 CONNECT 140x70 GA715 [nan]', 'قطعة', 5650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5400 CONNECT 140x70 GA715 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11300 Panel 180 cm [G8645]', 'قطعة', 11600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11300 Panel 180 cm [G8645]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm G8695 GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm G8695 GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8900 Panel 140 cm [G8555]', 'قطعة', 9200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8900 Panel 140 cm [G8555]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2500 Small panel 80 cm right or left [G8746]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2500 Small panel 80 cm right or left [G8746]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2100 Small panel 75 cm right or left [G8641]', 'قطعة', 2300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2100 Small panel 75 cm right or left [G8641]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'CONNECT' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left G8570 GA136 ﺳﻢ ٠٨ X ٠٨١ ﻛﻮﻧﻜﺖ ﺳﻢ ٠٨ X ٠٧١ ﻛﻮﻧﻜﺖ ﺳﻢ ٥٧ [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left G8570 GA136 ﺳﻢ ٠٨ X ٠٨١ ﻛﻮﻧﻜﺖ ﺳﻢ ٠٨ X ٠٧١ ﻛﻮﻧﻜﺖ ﺳﻢ ٥٧ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'ﺳﻢx  ﻛﻴﻤﻴﺮا ٠٧١ [nan]', 'قطعة', 8.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ﺳﻢx  ﻛﻴﻤﻴﺮا ٠٧١ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'ﺳﻢ  ﺑﺎﻟﻤﻘﺒﺾ واﻟﻤﺨﺪةxﻛﻴﻤﻴﺮا ٠٧١ [nan]', 'قطعة', 8.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ﺳﻢ  ﺑﺎﻟﻤﻘﺒﺾ واﻟﻤﺨﺪةxﻛﻴﻤﻴﺮا ٠٧١ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'ﺳﻢ  ﺑﺎﻟﺠﺎﻧﺐxﻛﻴﻤﻴﺮا ٠٧١ KIMERA WHITE WHIRLPOOL 180 x 90cm KIMERA                          ﻣ [nan]', 'قطعة', 8.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'ﺳﻢ  ﺑﺎﻟﺠﺎﻧﺐxﻛﻴﻤﻴﺮا ٠٧١ KIMERA WHITE WHIRLPOOL 180 x 90cm KIMERA                          ﻣ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '185800 Turbo 36 system / chrome finish/ Light [G9264]', 'قطعة', 186300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '185800 Turbo 36 system / chrome finish/ Light [G9264]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '111600 Combi-20 system / chrome finish [G9105]', 'قطعة', 112100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '111600 Combi-20 system / chrome finish [G9105]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '92000 New Combi-18 system / chrome finish [G9107]', 'قطعة', 92500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '92000 New Combi-18 system / chrome finish [G9107]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '88500 Combi plus-24 system / chrome  finish GA659 [nan]', 'قطعة', 89000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '88500 Combi plus-24 system / chrome  finish GA659 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '58200 Standard-8 system / chrome finish WHITE WHIRLPOOL 190 x 90cm KIMERA                  [G8924]', 'قطعة', 58700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '58200 Standard-8 system / chrome finish WHITE WHIRLPOOL 190 x 90cm KIMERA                  [G8924]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '187600 Turbo 36 system /  chrome finish/ Light GA117 [nan]', 'قطعة', 188100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '187600 Turbo 36 system /  chrome finish/ Light GA117 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '113300 Combi-20 system /  chrome finish GA118 [nan]', 'قطعة', 113800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '113300 Combi-20 system /  chrome finish GA118 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '93800 New Combi-18 system /  chrome finish GA119 [nan]', 'قطعة', 94300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '93800 New Combi-18 system /  chrome finish GA119 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90300 Combi plus-24 system / chrome  finish GA120 WHITE WHIRLPOOL 170 x 80cm KIMERA        [nan]', 'قطعة', 90800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90300 Combi plus-24 system / chrome  finish GA120 WHITE WHIRLPOOL 170 x 80cm KIMERA        [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '109900 Combi-20 system / chrome finish [G9154]', 'قطعة', 110400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '109900 Combi-20 system / chrome finish [G9154]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '90400 New Combi-18 system / chrome finish [G9156]', 'قطعة', 90900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '90400 New Combi-18 system / chrome finish [G9156]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '87100 Combi plus-24 system / chrome  finish GA658 [nan]', 'قطعة', 87600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '87100 Combi plus-24 system / chrome  finish GA658 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56600 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎرKIMERA       ﻛﻴﻤـــﻴﺮا [G8962]', 'قطعة', 57100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56600 Standard-8 system / chrome finish PRICES                اﻷﺳﻌﺎرKIMERA       ﻛﻴﻤـــﻴﺮا [G8962]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7400 Kimera 190 x 90cm GA964 [nan]', 'قطعة', 7650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7400 Kimera 190 x 90cm GA964 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '7100 Kimera 180 x 90cm [G8671]', 'قطعة', 7350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '7100 Kimera 180 x 90cm [G8671]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Kimera 180 x 80cm GA965 [nan]', 'قطعة', 6850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Kimera 180 x 80cm GA965 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6500 Kimera 170 x 80cm [G8712]', 'قطعة', 6750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6500 Kimera 170 x 80cm [G8712]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11800 Panel 190 cm GA578 [G8941]', 'قطعة', 12100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11800 Panel 190 cm GA578 [G8941]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11300 Panel 180 cm GA575 [G8645]', 'قطعة', 11600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11300 Panel 180 cm GA575 [G8645]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm G8695 GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm G8695 GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2600 Small panel 90 cm right or left G8417 [G8417]', 'قطعة', 2800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2600 Small panel 90 cm right or left G8417 [G8417]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2500 Small panel 80 cm right or left G8746 ﺳﻢ ٠٩ X ٠٩١ ﻛﻴﻤ ﺳﻢ ٠٩ X ٠٨١ ﻛﻴﻤ ﺳﻢ ٠٨ X ٠٨١ ﻛﻴﻤ [G8746]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2500 Small panel 80 cm right or left G8746 ﺳﻢ ٠٩ X ٠٩١ ﻛﻴﻤ ﺳﻢ ٠٩ X ٠٨١ ﻛﻴﻤ ﺳﻢ ٠٨ X ٠٨١ ﻛﻴﻤ [G8746]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6700 Tulip170 x 70cm with handgrips [G8672]', 'قطعة', 6950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6700 Tulip170 x 70cm with handgrips [G8672]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm G8695 GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm G8695 GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left G8570 GA136 ﻛﺮوم ɬ ﺳﻢ ٠٧ X ٠٧١ ﺗﻴﻮﻟﻴﺐ WHITE WHIRLPOOL [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left G8570 GA136 ﻛﺮوم ɬ ﺳﻢ ٠٧ X ٠٧١ ﺗﻴﻮﻟﻴﺐ WHITE WHIRLPOOL [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '56400 Standard-8 system / chrome finish GA468ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHIRLP [nan]', 'قطعة', 56900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '56400 Standard-8 system / chrome finish GA468ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHIRLP [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '57400 Standard-8 system / chrome finish G8927ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]', 'قطعة', 57900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '57400 Standard-8 system / chrome finish G8927ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6400 Junior 150x70 cm with hand grips [G8713]', 'قطعة', 6650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6400 Junior 150x70 cm with hand grips [G8713]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm G8758 GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm G8758 GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left G8570 GA136 ﻛﺮوم ɬ ﺳﻢ ٠٧ X ٠٥١ ﺟﻮﻧﻴﻮر [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left G8570 GA136 ﻛﺮوم ɬ ﺳﻢ ٠٧ X ٠٥١ ﺟﻮﻧﻴﻮر [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Sophia 180x80 cm GA712 [nan]', 'قطعة', 6850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Sophia 180x80 cm GA712 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6100 Sophia 170x80 cm GA711 [nan]', 'قطعة', 6350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6100 Sophia 170x80 cm GA711 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5700 Sophia 170x75 cm GA710 [nan]', 'قطعة', 5950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5700 Sophia 170x75 cm GA710 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5400 Sophia 170x70 cm [G8720]', 'قطعة', 5650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5400 Sophia 170x70 cm [G8720]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5300 Sophia 160x70 cm [G8730]', 'قطعة', 5550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5300 Sophia 160x70 cm [G8730]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5100 Sophia 150x70 cm [G7410]', 'قطعة', 5350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5100 Sophia 150x70 cm [G7410]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4900 Sophia 140x70 cm GA709 [nan]', 'قطعة', 5150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4900 Sophia 140x70 cm GA709 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4500 Sophia 120x70 cm GA708 [nan]', 'قطعة', 4750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4500 Sophia 120x70 cm GA708 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11300 Panel 180 cm GA575 [G8645]', 'قطعة', 11600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11300 Panel 180 cm GA575 [G8645]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm G8695 GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm G8695 GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9400 Panel 160 cm GA517 [G8556]', 'قطعة', 9700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9400 Panel 160 cm GA517 [G8556]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm G8758 GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm G8758 GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8900 Panel 140 cm [G8555]', 'قطعة', 9200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8900 Panel 140 cm [G8555]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8500 Panel 120 cm [G8643]', 'قطعة', 8800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8500 Panel 120 cm [G8643]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2500 Small panel 80 cm right or left G8746 [G8746]', 'قطعة', 2700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2500 Small panel 80 cm right or left G8746 [G8746]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2100 Small panel 75 cm right or left [G8641]', 'قطعة', 2300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2100 Small panel 75 cm right or left [G8641]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left G8570 GA136 ﺳﻢ ٠٨X ٠٨١  ﺻﻮﻓﻴﺎ ﺳﻢ ٠٨X٠٧١  ﺻﻮﻓﻴﺎ ﺳﻢ ٥٧  [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left G8570 GA136 ﺳﻢ ٠٨X ٠٨١  ﺻﻮﻓﻴﺎ ﺳﻢ ٠٨X٠٧١  ﺻﻮﻓﻴﺎ ﺳﻢ ٥٧  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55800 Standard-8 system / chrome finish G7307ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHITE  [nan]', 'قطعة', 56300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55800 Standard-8 system / chrome finish G7307ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHITE  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '54800 Standard-8 system / chrome finish G8995ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHITE  [nan]', 'قطعة', 55300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '54800 Standard-8 system / chrome finish G8995ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﺟﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم WHITE  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '55800 Standard-8 system / chrome finish G8977ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]', 'قطعة', 56300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '55800 Standard-8 system / chrome finish G8977ﺟﺎﻧﺐ ﺑﺪون ﻛﺮوم ﭼﻴﺖ وﻃﻘﻢ ٨ ﺳﺘﺎﻧﺪرد ﻧﻈﺎم PRICES [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5700 Step 170x70 w. seat GA859 [nan]', 'قطعة', 5950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5700 Step 170x70 w. seat GA859 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5300 Step 150x70 w. seat GA721 [nan]', 'قطعة', 5550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5300 Step 150x70 w. seat GA721 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left GA136 ﺑﻜﺮﳻ ﺳﻢ ٠٧X٠٧١ ﺳﺘﻴﺐ ﺑﻜﺮﳻ ﺳﻢ ٠٧X٠٥١ ﺳﺘﻴﺐ [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left GA136 ﺑﻜﺮﳻ ﺳﻢ ٠٧X٠٧١ ﺳﺘﻴﺐ ﺑﻜﺮﳻ ﺳﻢ ٠٧X٠٥١ ﺳﺘﻴﺐ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5700 Florida 170 x 70cm [G7408]', 'قطعة', 5900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5700 Florida 170 x 70cm [G7408]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5350 Florida 150 x 70cm [G8731]', 'قطعة', 5550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5350 Florida 150 x 70cm [G8731]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3700 New SEMIRAMIS 120x70 cm without seat GA926 ﺳﻢ ٠٧ X ٠٧١ ﻓﻠﻮرﻳﺪا ﺳﻢ ٠٧ X ٠٥١ ﻓﻠﻮرﻳﺪا ﺳﻢ [nan]', 'قطعة', 3900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3700 New SEMIRAMIS 120x70 cm without seat GA926 ﺳﻢ ٠٧ X ٠٧١ ﻓﻠﻮرﻳﺪا ﺳﻢ ٠٧ X ٠٥١ ﻓﻠﻮرﻳﺪا ﺳﻢ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5100 New FLORIDA 170x70 cm GA924 [nan]', 'قطعة', 5300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5100 New FLORIDA 170x70 cm GA924 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4600 New FLORIDA 150x70 cm GA925 [nan]', 'قطعة', 4800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4600 New FLORIDA 150x70 cm GA925 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4200 New FLORIDA 140x70 cm GA927 [nan]', 'قطعة', 4400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4200 New FLORIDA 140x70 cm GA927 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4000 New FLORIDA 120x70 cm GA947 [nan]', 'قطعة', 4200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4000 New FLORIDA 120x70 cm GA947 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3600 New FLORIDA 100x70 cm GA946 [nan]', 'قطعة', 3800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3600 New FLORIDA 100x70 cm GA946 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9800 Panel 170 cm GA135 [nan]', 'قطعة', 10100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9800 Panel 170 cm GA135 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '9000 Panel 150 cm GA133 [nan]', 'قطعة', 9300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '9000 Panel 150 cm GA133 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8900 Panel 140 cm [G8555]', 'قطعة', 9200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8900 Panel 140 cm [G8555]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8500 Panel 120 cm [G8643]', 'قطعة', 8800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8500 Panel 120 cm [G8643]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '8000 Panel 100 cm GA537 [nan]', 'قطعة', 8300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '8000 Panel 100 cm GA537 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2000 Small panel 70 cm right or left GA136 ﺳﻢ ٠٧ X ٠٧١  ﻓﻠﻮرﻳﺪا ﻧﻴﻮ ﺳﻢ ٠٧X٠٥١  ﻓﻠﻮرﻳﺪا ﻧﻴﻮ [nan]', 'قطعة', 2200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2000 Small panel 70 cm right or left GA136 ﺳﻢ ٠٧ X ٠٧١  ﻓﻠﻮرﻳﺪا ﻧﻴﻮ ﺳﻢ ٠٧X٠٥١  ﻓﻠﻮرﻳﺪا ﻧﻴﻮ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Chrome handgrips (Pair) [G9377AA]', 'قطعة', 1570.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Chrome handgrips (Pair) [G9377AA]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pillow - Per unit [G929167]', 'قطعة', 3050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pillow - Per unit [G929167]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Lighting unit (option) [G929067]', 'قطعة', 17260.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Lighting unit (option) [G929067]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Automatic touch Pop-up Drain for bathtub with panel GB016YB [nan]', 'قطعة', 1860.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Automatic touch Pop-up Drain for bathtub with panel GB016YB [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Rectangular Panel 170 cm With legs - White (Projects Only) GA139 [nan]', 'قطعة', 7900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Rectangular Panel 170 cm With legs - White (Projects Only) GA139 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Rectangular Panel 150 cm With legs - White (Projects Only) GA138 [G929167GB016YB]', 'قطعة', 6500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Rectangular Panel 150 cm With legs - White (Projects Only) GA138 [G929167GB016YB]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 70x70x2.5 GA966 [nan]', 'قطعة', 6700.0, 0, 0, true, 'ايديال', '5500.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 70x70x2.5 GA966 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 80x80x2.5 GA967 [nan]', 'قطعة', 7300.0, 0, 0, true, 'ايديال', '5900.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 80x80x2.5 GA967 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 90x90x2.5 GA968 [nan]', 'قطعة', 7900.0, 0, 0, true, 'ايديال', '6400.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 90x90x2.5 GA968 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 80x80x2.5 Corner GA980 [nan]', 'قطعة', 7300.0, 0, 0, true, 'ايديال', '5900.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 80x80x2.5 Corner GA980 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 90x90x2.5 Corner GA981 [nan]', 'قطعة', 7900.0, 0, 0, true, 'ايديال', '6400.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 90x90x2.5 Corner GA981 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 100x70x2.5 GA973 [nan]', 'قطعة', 7700.0, 0, 0, true, 'ايديال', '6300.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 100x70x2.5 GA973 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 100x80x2.5 GA969 [nan]', 'قطعة', 7900.0, 0, 0, true, 'ايديال', '6500.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 100x80x2.5 GA969 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 120x70x2.5 GA974 [nan]', 'قطعة', 8100.0, 0, 0, true, 'ايديال', '6600.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 120x70x2.5 GA974 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 120x80x2.5 GA970 [nan]', 'قطعة', 8500.0, 0, 0, true, 'ايديال', '7100.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 120x80x2.5 GA970 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 120x90x2.5 GA978 [nan]', 'قطعة', 8900.0, 0, 0, true, 'ايديال', '7500.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 120x90x2.5 GA978 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 140x70x2.5 GA975 [nan]', 'قطعة', 9000.0, 0, 0, true, 'ايديال', '7700.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 140x70x2.5 GA975 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 140x80x2.5 GA971 [nan]', 'قطعة', 9700.0, 0, 0, true, 'ايديال', '8200.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 140x80x2.5 GA971 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 150x70x2.5 GA976 [nan]', 'قطعة', 9500.0, 0, 0, true, 'ايديال', '7900.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 150x70x2.5 GA976 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 160x90x2.5 GA979 [nan]', 'قطعة', 10500.0, 0, 0, true, 'ايديال', '9100.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 160x90x2.5 GA979 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 170x70x2.5 GA977 [nan]', 'قطعة', 9900.0, 0, 0, true, 'ايديال', '8500.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 170x70x2.5 GA977 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Ultra Flat New 170x80x2.5 GA972 اﻟﴫف ﺷﺎﻣﻞ  ﻣﺮﺑﻊ ٥٫٢ X ٠٧ X ٠٧ ﻓﻼت أﻟﱰا ﻗﺪم اﻟﴫف ﺷﺎﻣﻞ  ﻣﺮﺑﻊ [nan]', 'قطعة', 10400.0, 0, 0, true, 'ايديال', '8900.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Ultra Flat New 170x80x2.5 GA972 اﻟﴫف ﺷﺎﻣﻞ  ﻣﺮﺑﻊ ٥٫٢ X ٠٧ X ٠٧ ﻓﻼت أﻟﱰا ﻗﺪم اﻟﴫف ﺷﺎﻣﻞ  ﻣﺮﺑﻊ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3100 Ultra Flat Tray 70x70x4.7 [G8630]', 'قطعة', 3300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3100 Ultra Flat Tray 70x70x4.7 [G8630]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3700 Ultra Flat Tray 80x80x4.7 [G8602]', 'قطعة', 3900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3700 Ultra Flat Tray 80x80x4.7 [G8602]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4300 Ultra Flat Tray 90x90x4.7 [G8597]', 'قطعة', 4500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4300 Ultra Flat Tray 90x90x4.7 [G8597]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3700 Ultra Flat Tray 80x80x4.7Corner [G8416]', 'قطعة', 3900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3700 Ultra Flat Tray 80x80x4.7Corner [G8416]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4200 Ultra Flat Tray 90x90x4.7Corner GA009 [nan]', 'قطعة', 4400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4200 Ultra Flat Tray 90x90x4.7Corner GA009 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3900 Ultra Flat Tray 100x70x4.7 [G8628]', 'قطعة', 4100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3900 Ultra Flat Tray 100x70x4.7 [G8628]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4200 Ultra Flat Tray 100x80x4.7 [G8598]', 'قطعة', 4400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4200 Ultra Flat Tray 100x80x4.7 [G8598]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4500 Ultra Flat Tray 120x70x4.7 [G8631]', 'قطعة', 4700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4500 Ultra Flat Tray 120x70x4.7 [G8631]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4800 Ultra Flat Tray 120x80x4.7 [G8599]', 'قطعة', 5000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4800 Ultra Flat Tray 120x80x4.7 [G8599]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4900 Ultra Flat Tray 120x90x4.7 [G8593]', 'قطعة', 5100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4900 Ultra Flat Tray 120x90x4.7 [G8593]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5400 Ultra Flat Tray 140x70x4.7 GA870 [nan]', 'قطعة', 5600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5400 Ultra Flat Tray 140x70x4.7 GA870 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5900 Ultra Flat Tray 140x80x4.7 [G8603]', 'قطعة', 6100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5900 Ultra Flat Tray 140x80x4.7 [G8603]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5200 Ultra Flat Tray 150x70x4.7 [G8420]', 'قطعة', 5400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5200 Ultra Flat Tray 150x70x4.7 [G8420]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6700 Ultra Flat Tray 160x90x4.7 [G8594]', 'قطعة', 6900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6700 Ultra Flat Tray 160x90x4.7 [G8594]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5800 Ultra Flat Tray 170x70x4.7 [G8629]', 'قطعة', 6000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5800 Ultra Flat Tray 170x70x4.7 [G8629]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Ultra Flat Tray 170x80x4.7 ﺳﻢ ٩ ﴏف - ﻣﺮﺑﻊ ٧٫٤ X ٠٧ X ٠٧ ﻓﻼت أﻟﱰا ﻗﺪم ﺳﻢ ٩ ﴏف - ﻣﺮﺑﻊ ٧ [G8606]', 'قطعة', 6800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Ultra Flat Tray 170x80x4.7 ﺳﻢ ٩ ﴏف - ﻣﺮﺑﻊ ٧٫٤ X ٠٧ X ٠٧ ﻓﻼت أﻟﱰا ﻗﺪم ﺳﻢ ٩ ﴏف - ﻣﺮﺑﻊ ٧ [G8606]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pop-up Drain for Ultra Flat Tray 9cm (3.5 Inches) J3417AA( ﺑﻮﺻﺔ ٥٫٣ ) ﺳﻢ ٩ ﻗﺪم ﻟﺤ ﻃﺎﺑﻖ ULT [nan]', 'قطعة', 1570.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pop-up Drain for Ultra Flat Tray 9cm (3.5 Inches) J3417AA( ﺑﻮﺻﺔ ٥٫٣ ) ﺳﻢ ٩ ﻗﺪم ﻟﺤ ﻃﺎﺑﻖ ULT [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '2900 Square Tray 70x70 cm [G8742]', 'قطعة', 3050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '2900 Square Tray 70x70 cm [G8742]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3300 Square Tray 80x80 cm [G8678]', 'قطعة', 3450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3300 Square Tray 80x80 cm [G8678]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3700 Square Tray 90x90 cm [G8684]', 'قطعة', 3850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3700 Square Tray 90x90 cm [G8684]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3300 Corner Round Tray 80x80 cm [G8685]', 'قطعة', 3450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3300 Corner Round Tray 80x80 cm [G8685]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3800 Corner Round Tray 90X90 cm [G8683]', 'قطعة', 3950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3800 Corner Round Tray 90X90 cm [G8683]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4560 Rectangular Tray 120x80 cm GA841 ﺳﻢ ٠٧ X ٠٧ ﻣﺮﺑﻊ ﻗﺪم ﺳﻢ ٠٨ X ٠٨ ﻣﺮﺑﻊ ﻗﺪم ﺳﻢ ٠٩ X ٠٩ ﻣ [nan]', 'قطعة', 4710.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4560 Rectangular Tray 120x80 cm GA841 ﺳﻢ ٠٧ X ٠٧ ﻣﺮﺑﻊ ﻗﺪم ﺳﻢ ٠٨ X ٠٨ ﻣﺮﺑﻊ ﻗﺪم ﺳﻢ ٠٩ X ٠٩ ﻣ [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '3900 Square Tray 70x70cm w.panel GA359 [nan]', 'قطعة', 4100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '3900 Square Tray 70x70cm w.panel GA359 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4400 Square Tray 80x80cm w.panel [G8415]', 'قطعة', 4600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4400 Square Tray 80x80cm w.panel [G8415]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5000 Square Tray 90x90 with panel [G8414]', 'قطعة', 5200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5000 Square Tray 90x90 with panel [G8414]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4500 Corner Tray 80x80cm w.panel [G8547]', 'قطعة', 4700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4500 Corner Tray 80x80cm w.panel [G8547]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5100 Corner Tray 90x90cm w.panel [G8539]', 'قطعة', 5300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5100 Corner Tray 90x90cm w.panel [G8539]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11800 ROUND TRAY 90X90X30 cm w.seat w.panel GA707 [nan]', 'قطعة', 12100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11800 ROUND TRAY 90X90X30 cm w.seat w.panel GA707 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '10900 Round Tray for super shower [nan]', 'قطعة', 11200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '10900 Round Tray for super shower [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'cm w.panel [G8766]', 'قطعة', 90.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'cm w.panel [G8766]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12500 Round Tray for super shower [nan]', 'قطعة', 12800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12500 Round Tray for super shower [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'cm w.panel GA473 [nan]', 'قطعة', 100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'cm w.panel GA473 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4700 Rectangular Tray 100x70x17 cm w.panel GA441 [nan]', 'قطعة', 4900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4700 Rectangular Tray 100x70x17 cm w.panel GA441 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5100 Rectangular Tray 100x80x17 cm w.panel GA466 [nan]', 'قطعة', 5300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5100 Rectangular Tray 100x80x17 cm w.panel GA466 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5200 Rectangular Tray 120x70x17 cm w.panel GA442 [nan]', 'قطعة', 5400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5200 Rectangular Tray 120x70x17 cm w.panel GA442 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5700 Rectangular Tray 120x80x17 cm w.panel [G8829]', 'قطعة', 5900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5700 Rectangular Tray 120x80x17 cm w.panel [G8829]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6200 Rectangular Tray 140x70x17 cm w.panel GA992 [nan]', 'قطعة', 6400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6200 Rectangular Tray 140x70x17 cm w.panel GA992 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '6600 Rectangular Tray 150x80x17 cm w.panel GA472 اﻟﺪاﺧﻞ ﻣﻦ ﻣﺮﺑﻊ ﺑﺎﻟﺠﺎﻧﺐ ﺳﻢ ٠٧X ٠٧ ﻣﺮﺑﻊ ﻗﺪم [nan]', 'قطعة', 6800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '6600 Rectangular Tray 150x80x17 cm w.panel GA472 اﻟﺪاﺧﻞ ﻣﻦ ﻣﺮﺑﻊ ﺑﺎﻟﺠﺎﻧﺐ ﺳﻢ ٠٧X ٠٧ ﻣﺮﺑﻊ ﻗﺪم [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X ٠٩ ﺷﺎور ﻟﺴﻮﺑﺮ ﻛﻮرﻧﺮﺑﺎﻟﺠﺎﻧﺐ ﻗﺪم [nan]', 'قطعة', 9.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X ٠٩ ﺷﺎور ﻟﺴﻮﺑﺮ ﻛﻮرﻧﺮﺑﺎﻟﺠﺎﻧﺐ ﻗﺪم [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X ٠٠١ ﺷﺎور ﻟﺴﻮﺑﺮ ﺑﺎﻟﺠﺎﻧﺐ ﻛﻮرﻧﺮ ﻗﺪم ﺑﺎﻟﺠﺎﻧﺐ  ﺳﻢ ٧١X٠٧X٠٠١ ﻣﺴﺘﻄﻴﻞ ﻗﺪم ﺑﺎﻟﺠﺎﻧﺐ  ﺳﻢ ٧١X٠٨X٠٠١  [nan]', 'قطعة', 1.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X ٠٠١ ﺷﺎور ﻟﺴﻮﺑﺮ ﺑﺎﻟﺠﺎﻧﺐ ﻛﻮرﻧﺮ ﻗﺪم ﺑﺎﻟﺠﺎﻧﺐ  ﺳﻢ ٧١X٠٧X٠٠١ ﻣﺴﺘﻄﻴﻞ ﻗﺪم ﺑﺎﻟﺠﺎﻧﺐ  ﺳﻢ ٧١X٠٨X٠٠١  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'x 80 cm G9764 [G9662]', 'قطعة', 18350.0, 0, 0, true, 'ايديال', '80.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'x 80 cm G9764 [G9662]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '17900 ( 90 x 90 - 100 x 100 cm ) G9765 PENTAGON SHOWER TRAY FOLDING ENCLOSURE              [G9663]', 'قطعة', 18700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '17900 ( 90 x 90 - 100 x 100 cm ) G9765 PENTAGON SHOWER TRAY FOLDING ENCLOSURE              [G9663]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '19500 From 90 to 100 cm GA885 GA884 SUPER SHOWER SLIDING ENCLOSURE                         [nan]', 'قطعة', 20300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '19500 From 90 to 100 cm GA885 GA884 SUPER SHOWER SLIDING ENCLOSURE                         [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '( 90 x 90 - 100 x 100 cm ) - SQUARE SHOWER TRAY ENCLOSURE (CORNER ENTRY)        ( إﻧﱰى ﻛﻮر [G9664]', 'قطعة', 18550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '( 90 x 90 - 100 x 100 cm ) - SQUARE SHOWER TRAY ENCLOSURE (CORNER ENTRY)        ( إﻧﱰى ﻛﻮر [G9664]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15300 From 60 to 80 cm G9767 [G9691]', 'قطعة', 16050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15300 From 60 to 80 cm G9767 [G9691]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15700 From 81 to 90 cm G7441 [G9692]', 'قطعة', 16500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15700 From 81 to 90 cm G7441 [G9692]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16250 From 91 to 100 cm G9769 [G9693]', 'قطعة', 17050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16250 From 91 to 100 cm G9769 [G9693]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16800 From 101 to 110 cm G9770 [G9694]', 'قطعة', 17450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16800 From 101 to 110 cm G9770 [G9694]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '17250 From 111 to 120 cm G9771 [G9695]', 'قطعة', 18100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '17250 From 111 to 120 cm G9771 [G9695]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '17800 From 121 to 130 cm G9772 - 18350 From 131 to 140 cm - - 19850 From 141 to 150 cm - G [G9697]', 'قطعة', 18550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '17800 From 121 to 130 cm G9772 - 18350 From 131 to 140 cm - - 19850 From 141 to 150 cm - G [G9697]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13700 From 60 to 80 cm GA861 GA862 [nan]', 'قطعة', 14500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13700 From 60 to 80 cm GA861 GA862 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14200 From 81 to 90 cm GA863 GA864 [nan]', 'قطعة', 15000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14200 From 81 to 90 cm GA863 GA864 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14500 From 91 to 100 cm GA865 GA866 [nan]', 'قطعة', 15350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14500 From 91 to 100 cm GA865 GA866 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15000 From 101 to 120 cm GA888 GA889 SHOWER TRAY DOOR UNIT (SLIDING)                       [nan]', 'قطعة', 15700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15000 From 101 to 120 cm GA888 GA889 SHOWER TRAY DOOR UNIT (SLIDING)                       [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14500 From 121 to 140 cm G7444 [G9728]', 'قطعة', 15500.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14500 From 121 to 140 cm G7444 [G9728]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15000 From 141 to 150 cm G9779 [G9730]', 'قطعة', 15800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15000 From 141 to 150 cm G9779 [G9730]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15500 From 151 to 160 cm G9780 [G9731]', 'قطعة', 16150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15500 From 151 to 160 cm G9780 [G9731]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15800 From 161 to 170 cm G9781 [G9732]', 'قطعة', 16600.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15800 From 161 to 170 cm G9781 [G9732]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16150 From 171 to 180 cm G9782 [G9733]', 'قطعة', 16900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16150 From 171 to 180 cm G9782 [G9733]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16600 From 181 to 190 cm G9783 [G9734]', 'قطعة', 17350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16600 From 181 to 190 cm G9783 [G9734]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16900 From 191 to 200 cm G9784 - 17350 From 201 to 220 cm - - 17750 From 221 to 250 cm - ﺳ [G9738]', 'قطعة', 17750.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16900 From 191 to 200 cm G9784 - 17350 From 201 to 220 cm - - 17750 From 221 to 250 cm - ﺳ [G9738]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12750 From 90 to 110 cm GA847 GA846 [nan]', 'قطعة', 13550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12750 From 90 to 110 cm GA847 GA846 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13150 From 111 to 120 cm GA807 GA812 [nan]', 'قطعة', 13900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13150 From 111 to 120 cm GA807 GA812 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13550 From 121 to 130 cm  GA808  GA813 - 13900 From 131 to 140 cm -  GA814 - 14300 From 14 [nan]', 'قطعة', 14300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13550 From 121 to 130 cm  GA808  GA813 - 13900 From 131 to 140 cm -  GA814 - 14300 From 14 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pivot Bathscreen 70 cm GB014 - [nan]', 'قطعة', 9200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pivot Bathscreen 70 cm GB014 - [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pivot Bathscreen 80 cm GB015 - SH TRAY SIDE SCREEN SLIDING                                 [nan]', 'قطعة', 9650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pivot Bathscreen 80 cm GB015 - SH TRAY SIDE SCREEN SLIDING                                 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5200 From 20 to 30 cm G9813 [G9804]', 'قطعة', 5550.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5200 From 20 to 30 cm G9813 [G9804]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5350 From 31 to 40 cm G9814 [G9805]', 'قطعة', 5800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5350 From 31 to 40 cm G9814 [G9805]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5500 From 41 to 50 cm G9815 [G9806]', 'قطعة', 5900.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5500 From 41 to 50 cm G9815 [G9806]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5550 From 51 to 60 cm G9816 [G9807]', 'قطعة', 5950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5550 From 51 to 60 cm G9816 [G9807]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5800 From 61 to 70 cm G9817 [G9808]', 'قطعة', 6100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5800 From 61 to 70 cm G9817 [G9808]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5900 From 71 to 80 cm G9818 [G9809]', 'قطعة', 6300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5900 From 71 to 80 cm G9818 [G9809]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5950 From 81 to 90 cm G9819 .YB ﻛﺮوم- BF ﺑﻴﭻ- AC أﺑﻴﺾ ﺗﺸﻤﻞ اﻵﻟﻮان [G9810]', 'قطعة', 6350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5950 From 81 to 90 cm G9819 .YB ﻛﺮوم- BF ﺑﻴﭻ- AC أﺑﻴﺾ ﺗﺸﻤﻞ اﻵﻟﻮان [G9810]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '17450 Contour Bath Enclosure Folding (110 - 125 - 135) GA907 GA906 - 23700 Bath Enclosure  [nan]', 'قطعة', 18350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '17450 Contour Bath Enclosure Folding (110 - 125 - 135) GA907 GA906 - 23700 Bath Enclosure  [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'From 100 to 110 cm - - 18700 From 115 to 120 cm - - 18850 From 125 to 130 cm - - 18900 Fro [G7422]', 'قطعة', 18400.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'From 100 to 110 cm - - 18700 From 115 to 120 cm - - 18850 From 125 to 130 cm - - 18900 Fro [G7422]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'X 70 Or 120 X 70 CM GA099 GA017 BATHTUBS DOOR UNIT (FOLDING)                               [nan]', 'قطعة', 15300.0, 0, 0, true, 'ايديال', '100.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'X 70 Or 120 X 70 CM GA099 GA017 BATHTUBS DOOR UNIT (FOLDING)                               [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14150 From 60 to 100 cm GA867 GA868 [nan]', 'قطعة', 15000.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14150 From 60 to 100 cm GA867 GA868 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14300 From 101 to 120 cm GA917 GA918 BATHTUBS DOOR UNIT (SLIDING)                          [nan]', 'قطعة', 15150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14300 From 101 to 120 cm GA917 GA918 BATHTUBS DOOR UNIT (SLIDING)                          [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '13700 From 121 to 140 cm G9622 [G9603]', 'قطعة', 14450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '13700 From 121 to 140 cm G9622 [G9603]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14050 From 141 to 150 cm G9624 [G9605]', 'قطعة', 14850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14050 From 141 to 150 cm G9624 [G9605]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14450 From 151 to 160 cm G 7924 [G9607]', 'قطعة', 15300.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14450 From 151 to 160 cm G 7924 [G9607]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '14850 From 161 to 170 cm G9626 [G9608]', 'قطعة', 15650.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '14850 From 161 to 170 cm G9626 [G9608]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15300 From 171 to 180 cm G 7427 G 7425 [nan]', 'قطعة', 16150.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15300 From 171 to 180 cm G 7427 G 7425 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '15650 From 181 to 190 cm G 7935 G 7426 [nan]', 'قطعة', 16450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '15650 From 181 to 190 cm G 7935 G 7426 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '16150 From 191 to 200 cm G 7937 - 16450 From 201 to 220 cm - - 16950 From 221 to 250 cm -  [G9614]', 'قطعة', 16950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '16150 From 191 to 200 cm G 7937 - 16450 From 201 to 220 cm - - 16950 From 221 to 250 cm -  [G9614]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '11600 From 90 to 110 cm GA816 GA822 [nan]', 'قطعة', 12450.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '11600 From 90 to 110 cm GA816 GA822 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '12350 From 111 to 130 cm GA818 GA824 - 12750 From 131 to 150 cm - GA826 BATHSCREEN PIVOT   [nan]', 'قطعة', 13100.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '12350 From 111 to 130 cm GA818 GA824 - 12750 From 131 to 150 cm - GA826 BATHSCREEN PIVOT   [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pivot Bathscreen 70 cm GA836 - [nan]', 'قطعة', 7700.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pivot Bathscreen 70 cm GA836 - [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'Pivot Bathscreen 80 cm GA837 - BATHTUBS SIDE-SCREEN                                        [nan]', 'قطعة', 8050.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Pivot Bathscreen 80 cm GA837 - BATHTUBS SIDE-SCREEN                                        [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4500 From 20 to 40 cm G9645 [G9637]', 'قطعة', 4850.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4500 From 20 to 40 cm G9645 [G9637]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '4800 From 41 to 60 cm G9647 [G9639]', 'قطعة', 5200.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '4800 From 41 to 60 cm G9647 [G9639]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5000 From 61 to 70 cm G9649 [G9641]', 'قطعة', 5350.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5000 From 61 to 70 cm G9649 [G9641]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5350 From 71 to 80 cm G9650 [G9642]', 'قطعة', 5800.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5350 From 71 to 80 cm G9650 [G9642]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '5600 From 81 to 90 cm G9651 .YB ﻛﺮوم- BF ﺑﻴﭻ- AC أﺑﻴﺾ ﺗﺸﻤﻞ اﻵﻟﻮان [G9643]', 'قطعة', 5950.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '5600 From 81 to 90 cm G9651 .YB ﻛﺮوم- BF ﺑﻴﭻ- AC أﺑﻴﺾ ﺗﺸﻤﻞ اﻵﻟﻮان [G9643]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton Tel.: 26969700         Fax.: 269 [nan]', 'قطعة', 88.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton Tel.: 26969700         Fax.: 269 [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '/ 17 Ismail Wahby St. From Moustafa El Nahas 9th Area Nasr City Tel.: 19696                [nan]', 'قطعة', 54.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '/ 17 Ismail Wahby St. From Moustafa El Nahas 9th Area Nasr City Tel.: 19696                [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'October : Al Fardous city In front of Dream Land. First Mall next to AlOthaim market. What [nan]', 'قطعة', 6.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'October : Al Fardous city In front of Dream Land. First Mall next to AlOthaim market. What [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton Tel.: 26969730 - 26969731 MANSOU [nan]', 'قطعة', 88.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'AL Moltaqua Al Araby Al Mosheer Ahmed Ismail St. Sheraton Tel.: 26969730 - 26969731 MANSOU [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  '23rd July St. El Manakh district Portsaid 01203399052 - (066) 3211608 ASIUT [nan]', 'قطعة', 31.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = '23rd July St. El Manakh district Portsaid 01203399052 - (066) 3211608 ASIUT [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'El-Gomhorya St. El-Horreya Tower. Tel./Fax.: 088 2063574 HURGHADA [nan]', 'قطعة', 4.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'El-Gomhorya St. El-Horreya Tower. Tel./Fax.: 088 2063574 HURGHADA [nan]' AND company = 'ايديال');


INSERT INTO products (id, subcategory_id, name, unit, retail_price, wholesale_price, cost_price, is_active, company, size, stock_status)
SELECT gen_random_uuid(), (SELECT id FROM subcategories WHERE name = 'KIMERA' AND category_id = (SELECT id FROM categories WHERE name = 'ايديال')),
  'El Nasr Road. Stadium St. Tel./Fax.: (065) 3548032 ZAKAZIK Awlad Gabr Center - Al Zhoor Ar [nan]', 'قطعة', 22.0, 0, 0, true, 'ايديال', '0.0', 'untracked'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'El Nasr Road. Stadium St. Tel./Fax.: (065) 3548032 ZAKAZIK Awlad Gabr Center - Al Zhoor Ar [nan]' AND company = 'ايديال');
