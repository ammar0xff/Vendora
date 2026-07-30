SELECT name FROM products 
WHERE company = 'الشريف' 
  AND subcategory_id = (SELECT id FROM subcategories WHERE name = 'وصلات') 
  AND retail_price = 16.15 
  AND size = '1"';
