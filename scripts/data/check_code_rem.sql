SELECT count(*) AS with_code, (
  SELECT count(*) FROM products WHERE company IN ('ايديال', 'دروفيت')
  AND name ~ '[A-Za-z]{3,}' AND name !~ '\[[A-Z0-9]+\]' AND name !~ '\['
) AS without_code;
