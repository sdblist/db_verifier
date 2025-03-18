-- s1010 - less 5% unused sequence values

-- s1010 - yes - s1010_1_id_seq
DROP TABLE IF EXISTS public.s1010_1 CASCADE;

-- s1010 - ok
DROP SEQUENCE IF EXISTS public.s1010_2;

-- s1010 - ok
DROP SEQUENCE IF EXISTS public.".s1010_3 ";

-- s1010 - ok
DROP SEQUENCE IF EXISTS public.s1010_4;

-- CYCLE
-- s1010 - ok
DROP SEQUENCE IF EXISTS public.s1010_5;
