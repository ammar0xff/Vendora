SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[' || chr(0x0679) || '-' || chr(0x067E) || ']';

-- Also check by just the most common bad char
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND position(chr(0x0679) in name) > 0;
