-- fk1001 - fk uses mismatched types

-- PRIMARY KEY + same data types + not null both sides
-- fk1001 - ok
DROP TABLE IF EXISTS public.fk1001_1 CASCADE;
DROP TABLE IF EXISTS public.fk1001_1_fk;

-- PRIMARY KEY + mismatched types + not null both sides
-- fk1001 - no
DROP TABLE IF EXISTS public.fk1001_2 CASCADE;
DROP TABLE IF EXISTS public.fk1001_2_fk;

-- PRIMARY KEY + mismatched types + not null both sides
-- fk1001 - no
DROP TABLE IF EXISTS public.fk1001_3 CASCADE;
DROP TABLE IF EXISTS public.fk1001_3_fk;
