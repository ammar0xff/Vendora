UPDATE products SET name = replace(name, 'DEA', 'ديا')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%DEA';
