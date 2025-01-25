-- fk1002 - check fk uses nullable columns

-- PRIMARY KEY + same data types + nullable
-- fk1002 - yes
DROP TABLE IF EXISTS public.fk1002_1 CASCADE;
DROP TABLE IF EXISTS public.fk1002_1_fk;

-- PRIMARY KEY + same data types + nullable + multi column FK
-- fk1002 - yes
DROP TABLE IF EXISTS public.fk1002_2 CASCADE;
DROP TABLE IF EXISTS public.fk1002_2_fk;

-- PRIMARY KEY + same data types + nullable + multi column FK + MATCH FULL
-- fk1002 - ok (MATCH FULL)
DROP TABLE IF EXISTS public.fk1002_3 CASCADE;
DROP TABLE IF EXISTS public.fk1002_3_fk;
