-- s1001 unlogged sequence
-- r1001 unlogged table

-- r1001 - yes - public.r1001_1
-- s1001 - ok - public.s1001_1
DROP TABLE IF EXISTS public.r1001_1 CASCADE;
CREATE SEQUENCE public.s1001_1 AS integer;
CREATE UNLOGGED TABLE public.r1001_1 (
	id integer NOT NULL DEFAULT nextval('public.s1001_1')
);
ALTER SEQUENCE public.s1001_1 OWNED BY public.r1001_1.id;

-- r1001 - yes - public.r1001_2
-- s1001 - yes - public.r1001_2_id_seq
DROP TABLE IF EXISTS public.r1001_2 CASCADE;
CREATE UNLOGGED TABLE public.r1001_2 (
	id serial NOT NULL
);

-- s1001 - yes - public.s1001_3
DROP SEQUENCE IF EXISTS public.s1001_3;
CREATE UNLOGGED SEQUENCE public.s1001_3 AS integer;
