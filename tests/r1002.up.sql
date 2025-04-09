-- r1002 - relation without columns

-- r1002 - yes - public.r1002_1
CREATE TABLE public.r1002_1 (
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE public.r1002_1 DROP COLUMN id;

-- r1002 - yes - public.r1002_2
CREATE VIEW public.r1002_2 AS SELECT * FROM public.r1002_1;
