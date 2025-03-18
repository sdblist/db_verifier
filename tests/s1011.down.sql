-- s1011 - less 10% unused sequence values

-- s1011 - yes - s1011_1_id_seq
DROP TABLE IF EXISTS public.s1011_1 CASCADE;

-- s1011 - yes - s1011_2
DROP SEQUENCE IF EXISTS public.s1011_2;

-- s1011 - ok
DROP SEQUENCE IF EXISTS public.".s1011_3 ";

-- s1011 - ok
DROP SEQUENCE IF EXISTS public.s1011_4;

-- CYCLE
-- s1011 - ok
DROP SEQUENCE IF EXISTS public.s1011_5;
