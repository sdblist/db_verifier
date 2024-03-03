-- PRIMARY KEY + same data types + not null both sides
-- fk1001 - ok
DROP TABLE IF EXISTS public.fk1001_1 CASCADE;
CREATE TABLE public.fk1001_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text,
    CONSTRAINT fk1001_1_pk PRIMARY KEY (id)
);

INSERT INTO public.fk1001_1 (value) VALUES('10');
INSERT INTO public.fk1001_1 (id, value) OVERRIDING SYSTEM VALUE VALUES (2000000000, '2000000000');

DROP TABLE IF EXISTS public.fk1001_1_fk;
CREATE TABLE public.fk1001_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1001_1_id integer NOT NULL,
    value text,
    CONSTRAINT fk1001_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1001_1_fk_fk1001_1 FOREIGN KEY (fk1001_1_id) REFERENCES public.fk1001_1(id)
);
INSERT INTO public.fk1001_1_fk (fk1001_1_id, value) VALUES(1, '1');
INSERT INTO public.fk1001_1_fk (fk1001_1_id, value) VALUES(2000000000, '2000000000');

-- PRIMARY KEY + mismatched types + not null both sides
-- fk1001 - no
DROP TABLE IF EXISTS public.fk1001_2 CASCADE;
CREATE TABLE public.fk1001_2
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text NOT NULL,
    CONSTRAINT fk1001_2_pk PRIMARY KEY (id, value)
);

DROP TABLE IF EXISTS public.fk1001_2_fk;
CREATE TABLE public.fk1001_2_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1001_2_id bigint NOT NULL,
    value text NOT NULL,
    CONSTRAINT fk1001_2_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1001_2_fk_fk1001_2 FOREIGN KEY (fk1001_2_id, value) REFERENCES public.fk1001_2(id, value)
);

-- PRIMARY KEY + mismatched types + not null both sides
-- fk1001 - no
DROP TABLE IF EXISTS public.fk1001_3 CASCADE;
CREATE TABLE public.fk1001_3
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value varchar(10) NOT NULL,
    CONSTRAINT fk1001_3_pk PRIMARY KEY (id, value)
);

DROP TABLE IF EXISTS public.fk1001_3_fk;
CREATE TABLE public.fk1001_3_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1001_3_id integer NOT NULL,
    value varchar NOT NULL,
    CONSTRAINT fk1001_3_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1001_3_fk_fk1001_3 FOREIGN KEY (fk1001_3_id, value) REFERENCES public.fk1001_3(id, value)
);

