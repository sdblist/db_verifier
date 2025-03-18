-- s1012 - less 20% unused sequence values

-- s1012 20% - yes - s1012_1_id_seq
DROP TABLE IF EXISTS public.s1012_1 CASCADE;

-- s1012 20% - yes - s1012_2
DROP SEQUENCE IF EXISTS public.s1012_2;

-- s1012 20% - yes - ".s1012_3 "
DROP SEQUENCE IF EXISTS public.".s1012_3 ";

-- s1012 20% - ok
DROP SEQUENCE IF EXISTS public.s1012_4;

-- CYCLE
-- s1012 20% - ok
DROP SEQUENCE IF EXISTS public.s1012_5;
