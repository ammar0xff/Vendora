-- Fix corrupted names (افيز -> قفيز) and move to قفزان subcategory
UPDATE products
SET name = 'قفيز بولي لاتش 3/4"',
    subcategory_id = 'b12ed220-d73c-519f-9a7d-ecb58dd62515',
    size = '3/4"'
WHERE id = '6ec910b4-8783-403d-a1b3-3010fa7db258';

UPDATE products
SET name = 'قفيز بولي لاتش 1"',
    subcategory_id = 'b12ed220-d73c-519f-9a7d-ecb58dd62515',
    size = '1"'
WHERE id = '1743d3fb-848e-476a-8cab-5e48149abdc3';

-- Insert missing قفيز بولي products
INSERT INTO products (id, subcategory_id, name, size, unit, retail_price, wholesale_price, cost_price, company, is_active, created_at, updated_at, stock_status)
VALUES
('111240d0-c336-4cf3-9cd2-6779a85cb709', 'b12ed220-d73c-519f-9a7d-ecb58dd62515', 'قفيز بولي مجوز 1/2"', '1/2"', 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('41c01f1c-ff76-4391-85d4-f5079c3787ce', 'b12ed220-d73c-519f-9a7d-ecb58dd62515', 'قفيز بولي فردي 1/2"', '1/2"', 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('db4063c5-f89d-40d9-abd9-968984ad74f8', 'b12ed220-d73c-519f-9a7d-ecb58dd62515', 'قفيز بولي فردي 3/4"', '3/4"', 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('66e9c7ca-229c-4dbb-9f3a-345225214c9f', 'b12ed220-d73c-519f-9a7d-ecb58dd62515', 'قفيز بولي مجوز 3/4"', '3/4"', 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked');

-- Insert opening stock movements
INSERT INTO stock_movements (id, product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_type, note, created_at)
VALUES
('2f6ed1e7-f66f-4925-b9b7-1f7b1f448648', '111240d0-c336-4cf3-9cd2-6779a85cb709', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 82, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي مجوز 1/2"', '2026-06-21 00:00:00+00'),
('85cf4914-7ff3-48f7-b4b2-9536803c0647', '6ec910b4-8783-403d-a1b3-3010fa7db258', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 315, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي لاتش 3/4"', '2026-06-21 00:00:00+00'),
('f0166cf7-10b5-4e8f-a1b5-5cabfcad1562', '1743d3fb-848e-476a-8cab-5e48149abdc3', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 95, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي لاتش 1"', '2026-06-21 00:00:00+00'),
('9aeb2e3c-7b56-4228-ab11-ebfab3c21b27', '41c01f1c-ff76-4391-85d4-f5079c3787ce', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 100, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي فردي 1/2"', '2026-06-21 00:00:00+00'),
('978dea93-ca22-44d7-a986-c0e0fa5251ae', 'db4063c5-f89d-40d9-abd9-968984ad74f8', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 174, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي فردي 3/4"', '2026-06-21 00:00:00+00'),
('9f719144-1a02-439c-ab8a-7821f6fb9d30', '66e9c7ca-229c-4dbb-9f3a-345225214c9f', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 234, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | قفيز بولي مجوز 3/4"', '2026-06-21 00:00:00+00');
