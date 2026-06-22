UPDATE products SET name = regexp_replace(name, ' \\[[^]]+\\]$', '', 'g') WHERE company = 'كومر';
