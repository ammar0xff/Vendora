DELETE FROM products WHERE company = 'كومر'; DELETE FROM subcategories WHERE category_id = (SELECT id FROM categories WHERE name = 'كومر');
