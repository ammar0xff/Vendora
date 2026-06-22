SELECT encode(name::bytea, 'hex') FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND position(chr(0x0679) in name) > 0
LIMIT 5;
