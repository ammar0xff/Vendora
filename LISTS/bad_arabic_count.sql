-- Count products with ALL their Arabic chars being from the "suspicious" set
-- (have at least one Arabic char, but none of the most common ones)
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND (
  position(chr(0x0637) in name) > 0 OR
  position(chr(0x0638) in name) > 0
)
AND position(chr(0x0627) in name) = 0
AND position(chr(0x0644) in name) = 0
AND position(chr(0x0645) in name) = 0
AND position(chr(0x0646) in name) = 0
AND position(chr(0x0649) in name) = 0
AND position(chr(0x0628) in name) = 0;
