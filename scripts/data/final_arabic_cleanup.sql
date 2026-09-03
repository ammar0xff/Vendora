-- Final cleanup: translate remaining English identifiers to Arabic

-- D-CODE -> دي كود
UPDATE products SET name = replace(name, 'D-CODE', 'دي كود')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%D-CODE%';

-- STARCK 3 -> شتارك 3
UPDATE products SET name = replace(name, 'STARCK 3', 'شتارك 3')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%STARCK 3%';

-- L-CUBE -> إل كيوب
UPDATE products SET name = replace(name, 'L-CUBE', 'إل كيوب')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%L-CUBE%';

-- HAPPY D. -> هابي دي
UPDATE products SET name = replace(name, 'HAPPY D.', 'هابي دي')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%HAPPY D.%';

-- PROSYS -> بروسيس
UPDATE products SET name = replace(name, 'PROSYS', 'بروسيس')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%PROSYS%';

-- TONIC -> تونيك
UPDATE products SET name = replace(name, 'TONIC', 'تونيك')
WHERE company IN ('ايديال', 'دروفيت') AND name LIKE '%TONIC%';

-- "From " -> "من " and " to " -> " إلى "
UPDATE products SET name = regexp_replace(name, '\mFrom\M', 'من', 'g')
WHERE company IN ('ايديال', 'دروفيت') AND name ~ 'From';

UPDATE products SET name = regexp_replace(name, '\mto\M', 'إلى', 'g')
WHERE company IN ('ايديال', 'دروفيت') AND name ~ ' to ';

-- "موديل " is already Arabic - keep it
