SELECT encode(name::bytea, 'escape') as name_esc
FROM products WHERE company = 'ايديال' LIMIT 20;
