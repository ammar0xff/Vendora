-- Move existing مانيجه products to correct subcategory and activate
UPDATE products SET subcategory_id = 'df634c7a-d345-505a-82a4-2bdc2e899a7b', is_active = 't'
WHERE id = '538af4af-6d6c-4210-be3c-0ffaecc7a7ed';

UPDATE products SET subcategory_id = 'df634c7a-d345-505a-82a4-2bdc2e899a7b', is_active = 't'
WHERE id = '58991d0b-13f2-4dff-80e7-41c64abe1120';

UPDATE products SET subcategory_id = 'df634c7a-d345-505a-82a4-2bdc2e899a7b', is_active = 't'
WHERE id = 'fd1d4d05-a75f-4b1e-bab1-26b542487294';

UPDATE products SET subcategory_id = 'df634c7a-d345-505a-82a4-2bdc2e899a7b', is_active = 't'
WHERE id = '6d01a666-06e8-4462-9315-00ba9f599a34';

-- Insert missing مانيجه products
INSERT INTO products (id, subcategory_id, name, size, unit, retail_price, wholesale_price, cost_price, company, is_active, created_at, updated_at, stock_status)
VALUES
('49f4d737-1d66-4bbf-8011-44949b013133', 'df634c7a-d345-505a-82a4-2bdc2e899a7b', 'مانيجه سوسته ايطالى (يوسف)', NULL, 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('e3ef3606-53ce-4847-a9ae-7357efdea79a', 'df634c7a-d345-505a-82a4-2bdc2e899a7b', 'مانيجه سوسته تركى', NULL, 'قطعة', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('bf9ce757-b348-4b75-bbb4-0c6bf8efc605', 'df634c7a-d345-505a-82a4-2bdc2e899a7b', 'مانيجه كوع', NULL, 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('c3c27efc-96b1-4a23-bdab-93e04c7e9940', 'df634c7a-d345-505a-82a4-2bdc2e899a7b', 'مانيجه فار', NULL, 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked'),
('1db05d34-4a6f-4897-9a7c-619aa7351406', 'df634c7a-d345-505a-82a4-2bdc2e899a7b', 'مانيجه عادية', NULL, 'عدد', 0, 0, 0, NULL, 't', '2026-06-21 00:00:00+00', '2026-06-21 00:00:00+00', 'untracked');

-- Insert opening stock movements
INSERT INTO stock_movements (id, product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_type, note, created_at)
VALUES
('2b6c055a-9450-4dae-8a8b-a56e8edc71b0', '49f4d737-1d66-4bbf-8011-44949b013133', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 30, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه سوسته ايطالى (يوسف)', '2026-06-21 00:00:00+00'),
('d6bce955-a8c3-4687-a943-e38bd27244cd', 'bf9ce757-b348-4b75-bbb4-0c6bf8efc605', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 36, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه كوع', '2026-06-21 00:00:00+00'),
('2c02dae4-da9c-42ec-8a41-8dd0fde638e8', 'fd1d4d05-a75f-4b1e-bab1-26b542487294', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 6, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه استانلس', '2026-06-21 00:00:00+00'),
('52014469-6a56-4346-b8dc-b1a60345184e', 'c3c27efc-96b1-4a23-bdab-93e04c7e9940', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 12, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه فار', '2026-06-21 00:00:00+00'),
('86463d4f-c87a-4feb-bbb1-f69ec7689f49', '1db05d34-4a6f-4897-9a7c-619aa7351406', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 21, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه عادية', '2026-06-21 00:00:00+00'),
('b288f2d0-933e-44a3-a844-7daca37e9f63', '538af4af-6d6c-4210-be3c-0ffaecc7a7ed', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 27, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه قصيره', '2026-06-21 00:00:00+00'),
('2537a357-cce0-46ae-9366-17d213a79d5f', '58991d0b-13f2-4dff-80e7-41c64abe1120', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 15, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه عدلة', '2026-06-21 00:00:00+00'),
('9a8bac04-ed1d-40de-82eb-4c96c5ec956d', '6d01a666-06e8-4462-9315-00ba9f599a34', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 24, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه موجة', '2026-06-21 00:00:00+00'),
('caf4be5e-f516-4ce8-9030-777feff6f3bb', 'e3ef3606-53ce-4847-a9ae-7357efdea79a', '122f5b3b-9519-5b1e-a3fd-0ddacba7e157', 'opening_stock', 31, 0, 0, 'opening_stock', 'رصيد افتتاحي — migration | مانيجه سوسته تركى', '2026-06-21 00:00:00+00');
