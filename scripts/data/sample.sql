-- Sample results
SELECT name FROM products WHERE company = 'ايديال' AND length(name) < 70 ORDER BY random() LIMIT 20;
