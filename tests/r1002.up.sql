-- r1002 relation without columns

-- r1002 - yes - public.r1002_1
DROP TABLE IF EXISTS public.r1002_1 CASCADE;
CREATE TABLE public.r1002_1 (
);

-- r1002 - yes - public.r1002_2
DROP VIEW IF EXISTS public.r1002_2 CASCADE;
CREATE VIEW public.r1002_2 AS SELECT * FROM public.r1002_1;
