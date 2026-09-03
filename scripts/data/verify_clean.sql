SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND position(chr(0x0637) in name) > 0
AND position(chr(0x0627) in name) = 0;
