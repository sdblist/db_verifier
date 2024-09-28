-- n1021 - unwanted characters in sequence name

-- "n1021 "  - yes
DROP TABLE IF EXISTS public."n1021 " CASCADE;

-- "	n1021"  - yes
DROP TABLE IF EXISTS public."	n1021" CASCADE;

-- "n.1021"  - yes
DROP TABLE IF EXISTS public."n.1021" CASCADE;

-- "n+1021"  - yes
DROP TABLE IF EXISTS public."n+1021" CASCADE;

-- "n\n1021" - yes
DROP TABLE IF EXISTS public."n\n1021" CASCADE;

-- "n
-- 1021"     - yes
DROP TABLE IF EXISTS public."n
1021" CASCADE;
