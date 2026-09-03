-- Fix price-range entries (bath panels with size ranges)
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9779' WHERE company = 'ايديال' AND name LIKE '15000%141%سم%G9779';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9767' WHERE company = 'ايديال' AND name LIKE '15300%60%80%سم%G9767';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9780' WHERE company = 'ايديال' AND name LIKE '15500%151%160%G9780';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G7441' WHERE company = 'ايديال' AND name LIKE '15700%81%90%سم%G7441';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9781' WHERE company = 'ايديال' AND name LIKE '15800%161%170%G9781';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9769' WHERE company = 'ايديال' AND name LIKE '16250%91%100%G9769';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9783' WHERE company = 'ايديال' AND name LIKE '16600%181%190%G9783';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9772' WHERE company = 'ايديال' AND name LIKE '17800%121%130%G9772%';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9770' WHERE company = 'ايديال' AND name LIKE '16800%101%110%G9770';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9771' WHERE company = 'ايديال' AND name LIKE '17250%111%120%G9771';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G7444' WHERE company = 'ايديال' AND name LIKE '14500%121%140%G7444';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9622' WHERE company = 'ايديال' AND name LIKE '13700%121%140%G9622';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9813' WHERE company = 'ايديال' AND name LIKE '5200%20%30%G9813';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9814' WHERE company = 'ايديال' AND name LIKE '5350%31%40%G9814';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9815' WHERE company = 'ايديال' AND name LIKE '5500%41%50%G9815';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9816' WHERE company = 'ايديال' AND name LIKE '5550%51%60%G9816';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9817' WHERE company = 'ايديال' AND name LIKE '5800%61%70%G9817';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9818' WHERE company = 'ايديال' AND name LIKE '5900%71%80%G9818';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9782' WHERE company = 'ايديال' AND name LIKE '16150%171%180%G9782';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9624' WHERE company = 'ايديال' AND name LIKE '14050%141%150%G9624';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G7924' WHERE company = 'ايديال' AND name LIKE '14450%151%160%G7924';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9626' WHERE company = 'ايديال' AND name LIKE '14850%161%170%G9626';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9645' WHERE company = 'ايديال' AND name LIKE '4500%20%40%G9645';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9647' WHERE company = 'ايديال' AND name LIKE '4800%41%60%G9647';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9649' WHERE company = 'ايديال' AND name LIKE '5000%61%70%G9649';
UPDATE products SET name = 'بانيلي حسب المقاس - موديل G9650' WHERE company = 'ايديال' AND name LIKE '5350%71%80%G9650';

-- Multi-size entries
UPDATE products SET name = 'بانيلي حسب المقاس - موديلات متعددة (G9772, G9773, G9774...)'
WHERE company = 'ايديال' AND name LIKE '17800%121%130%سم%' AND name ~ '18350';

-- Another multi
UPDATE products SET name = 'بانيلي حسب المقاس - موديلات متعددة (G7937, G7938...)'
WHERE company = 'ايديال' AND name LIKE '16150%191%200%G 7937%';

-- The one that starts with "From 100 to 110 سم"
UPDATE products SET name = 'بانيلي حسب المقاس - موديلات متعددة'
WHERE company = 'ايديال' AND name LIKE 'From 100 to 110%';

-- Fix DEA (should be DEA brand but I already ran the update)
UPDATE products SET name = 'DEA' WHERE company = 'ايديال' AND subcategory_id IN (SELECT id FROM subcategories WHERE name = 'SEPARATES') AND name !~ '\[';
