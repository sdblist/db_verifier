-- n1016 - unwanted characters in index name

-- "n1016 "  - yes
DROP TABLE IF EXISTS public."n1016 " CASCADE;

-- "	n1016"  - yes
DROP TABLE IF EXISTS public."	n1016" CASCADE;

-- "n.1016"  - yes
DROP TABLE IF EXISTS public."n.1016" CASCADE;

-- "n+1016"  - yes
DROP TABLE IF EXISTS public."n+1016" CASCADE;

-- "n\n1016" - yes
DROP TABLE IF EXISTS public."n\n1016" CASCADE;

-- "n
-- 1016"     - yes
DROP TABLE IF EXISTS public."n
1016" CASCADE;
