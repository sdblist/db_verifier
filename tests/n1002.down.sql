-- n1002 - unwanted characters in schema name

-- "n1002 " - yes
DROP SCHEMA IF EXISTS "n1002 " CASCADE;

-- "	n1002" - yes
DROP SCHEMA IF EXISTS "	n1002" CASCADE;

-- "n.1002" - yes
DROP SCHEMA IF EXISTS "n.1002" CASCADE;

-- "n+1002" - yes
DROP SCHEMA IF EXISTS "n+1002" CASCADE;

-- "n\n1002" - yes
DROP SCHEMA IF EXISTS "n\n1002" CASCADE;

-- "n
-- 1002" - yes
DROP SCHEMA IF EXISTS "n
1002" CASCADE;
