-- s1001 - unlogged sequence

-- s1001 - yes - public.s1001_2_id_seq
CREATE UNLOGGED TABLE public.s1001_2 (
	id serial NOT NULL
);

-- s1001 - yes - public.s1001_3
CREATE UNLOGGED SEQUENCE public.s1001_3 AS integer;
