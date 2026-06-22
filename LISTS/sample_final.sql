-- Random samples
SELECT name FROM products WHERE company = 'ايديال' TABLESAMPLE BERNOULLI(3) LIMIT 15;
