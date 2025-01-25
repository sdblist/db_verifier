-- r1001 - unlogged table

-- r1001 - yes - public.r1001_1
CREATE SEQUENCE public.rs1001_1 AS integer;
CREATE UNLOGGED TABLE public.r1001_1 (
	id integer NOT NULL DEFAULT nextval('public.rs1001_1')
);
ALTER SEQUENCE public.rs1001_1 OWNED BY public.r1001_1.id;

-- r1001 - yes - public.r1001_2
CREATE UNLOGGED TABLE public.r1001_2 (
	id serial NOT NULL
);
