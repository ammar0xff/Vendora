-- Check for any remaining corrupted names
-- Count names with corrupted Unicode (chars in the "wrong" Arabic range that are actually garbled)
SELECT count(*) FROM products
WHERE company IN ('ايديال', 'دروفيت')
AND name ~ '[' || chr(1569) || '-' || chr(1610) || ']'
AND name !~ '[' || chr(1575) || '-' || chr(1604) || ']';
