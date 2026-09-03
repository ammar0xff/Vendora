-- Fix garbled short names (<=5 chars, no codes) by subcategory
-- These are products from PDF that had unreadable text but are in a known subcategory

-- PROSYS (shower systems)
UPDATE products p SET name = 'نظام بروسيس'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'PROSYS'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- D-CODE (D-Code series)
UPDATE products p SET name = 'قطعة دي كود'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'D-CODE'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- TONIC
UPDATE products p SET name = 'قطعة تونيك'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'TONIC'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- KIMERA
UPDATE products p SET name = 'قطعة كيميرا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'KIMERA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- HAPPY D.
UPDATE products p SET name = 'قطعة هابي دي'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'HAPPY D.'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- OTHERS
UPDATE products p SET name = 'قطعة'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'OTHERS'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- IOM ACCESSORIES
UPDATE products p SET name = 'إكسسوار أيوم'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'IOM ACCESSORIES'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- DURASTYLE
UPDATE products p SET name = 'قطعة ديوراستايل'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'DURASTYLE'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- STARCK 3
UPDATE products p SET name = 'قطعة شتارك 3'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'STARCK 3'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- SEPARATES
UPDATE products p SET name = 'قطعة'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'SEPARATES'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- DARLING
UPDATE products p SET name = 'قطعة دارلينج'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'DARLING'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- D-NEO
UPDATE products p SET name = 'قطعة دي نيو'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'D-NEO'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- DURAPLUS
UPDATE products p SET name = 'قطعة ديورا بلس'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'DURAPLUS'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- VERO
UPDATE products p SET name = 'قطعة فيرو'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'VERO'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- TESI
UPDATE products p SET name = 'قطعة تيسي'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'TESI'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- P3 COMFORTS
UPDATE products p SET name = 'قطعة بي 3 كومفورت'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'P3 COMFORTS'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- INDEPENDENT
UPDATE products p SET name = 'قطعة إندبندنت'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'INDEPENDENT'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- PURAVIDA
UPDATE products p SET name = 'قطعة بيورا فيدا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'PURAVIDA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- STARCK 1
UPDATE products p SET name = 'قطعة شتارك 1'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'STARCK 1'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- MANTA
UPDATE products p SET name = 'قطعة مانتا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'MANTA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- SAN REMO
UPDATE products p SET name = 'قطعة سان ريمو'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'SAN REMO'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- NEW ESEDRA
UPDATE products p SET name = 'قطعة نيو إيسيدرا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'NEW ESEDRA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- NEW CAPRI
UPDATE products p SET name = 'قطعة نيو كابري'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'NEW CAPRI'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- ECHO
UPDATE products p SET name = 'قطعة إيكو'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'ECHO'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- STUDIO ACCESSORIES
UPDATE products p SET name = 'إكسسوار ستوديو'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'STUDIO ACCESSORIES'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- SOPHIA
UPDATE products p SET name = 'قطعة صوفيا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'SOPHIA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- EMILIA
UPDATE products p SET name = 'قطعة إميليا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'EMILIA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- SPACE
UPDATE products p SET name = 'قطعة سبيس'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'SPACE'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- VITRIUM
UPDATE products p SET name = 'قطعة فيتريوم'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'VITRIUM'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- GOLF
UPDATE products p SET name = 'قطعة جولف'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'GOLF'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- I.LIFE
UPDATE products p SET name = 'قطعة آي لايف'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'I.LIFE'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- PLAYA
UPDATE products p SET name = 'قطعة بلايا'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'PLAYA'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- CONNECT
UPDATE products p SET name = 'قطعة كونكت'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'CONNECT'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';

-- PLAN
UPDATE products p SET name = 'قطعة بلان'
FROM subcategories sc WHERE p.subcategory_id = sc.id AND sc.name = 'PLAN'
AND p.company IN ('ايديال', 'دروفيت') AND length(p.name) <= 5 AND NOT p.name ~ '\[';
