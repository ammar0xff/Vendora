-- Count products where name has ONLY chars from the garbled set
-- (طظ only, no standard Arabic letters like ا ب ت ث etc.)
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND position(chr(0x0637) in name) > 0
AND position(chr(0x0627) in name) = 0
AND position(chr(0x0628) in name) = 0;
