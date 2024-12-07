-- r1002 relation without columns

-- r1002 - yes - public.r1002_1
CREATE TABLE public.r1002_1 (
);

-- r1002 - yes - public.r1002_2
CREATE VIEW public.r1002_2 AS SELECT * FROM public.r1002_1;
