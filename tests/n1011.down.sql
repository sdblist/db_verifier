-- n1011 - unwanted characters in relation name

-- "n1011 "  - yes
DROP TABLE IF EXISTS public."n1011 " CASCADE;

-- "	n1011"  - yes
DROP TABLE IF EXISTS public."	n1011" CASCADE;

-- "n.1011"  - yes
DROP TABLE IF EXISTS public."n.1011" CASCADE;

-- "n+1011"  - yes
DROP TABLE IF EXISTS public."n+1011" CASCADE;

-- "n\n1011" - yes
DROP TABLE IF EXISTS public."n\n1011" CASCADE;

-- "n
-- 1011"     - yes
DROP TABLE IF EXISTS public."n
1011" CASCADE;
