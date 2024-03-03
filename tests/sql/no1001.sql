-- PRIMARY KEY
-- no1001 - ok
-- no1002 - ok
DROP TABLE IF EXISTS public.no1001_1;
CREATE TABLE public.no1001_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text,
    CONSTRAINT no1001_1_pk PRIMARY KEY (id)
);

-- CONSTRAINT UNIQUE + column NOT NULL
-- no1001 - ok
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_2;
CREATE TABLE public.no1001_2
(
    id    integer NOT NULL,
    value text,
    CONSTRAINT no1001_2_unique_not_null UNIQUE (id)
);

-- CONSTRAINT UNIQUE + nullable column + NULLS DISTINCT
-- can create fk, but no unique key
-- no1001 - no
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_3 CASCADE;
CREATE TABLE public.no1001_3
(
    id    integer NULL,
    value text,
    CONSTRAINT no1001_3_unique_nullable UNIQUE /*NULLS DISTINCT*/ (id)
);

INSERT INTO public.no1001_3 (id, value) VALUES(NULL, '10');
INSERT INTO public.no1001_3 (id, value) VALUES(NULL, '11');
INSERT INTO public.no1001_3 (id, value) VALUES(20, '20');
INSERT INTO public.no1001_3 (id, value) VALUES(30, '30');

DROP TABLE IF EXISTS public.no1001_3_fk;
CREATE TABLE public.no1001_3_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    no1001_3_id integer,
    value text,
    CONSTRAINT no1001_3_pk PRIMARY KEY (id),
    CONSTRAINT no1001_3_fk_no1001_3 FOREIGN KEY (no1001_3_id) REFERENCES public.no1001_3(id)
);
INSERT INTO public.no1001_3_fk (no1001_3_id, value) VALUES(NULL, '10');
INSERT INTO public.no1001_3_fk (no1001_3_id, value) VALUES(20, '20');

-- UNIQUE INDEX + column NOT NULL
-- no1001 - ok
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_4;
CREATE TABLE public.no1001_4
(
    id    integer NOT NULL,
    value text
);
CREATE UNIQUE INDEX no1001_4_ind_unique ON public.no1001_4 (id);

-- UNIQUE INDEX + nullable column + NULLS DISTINCT
-- no1001 - no
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_5;
CREATE TABLE public.no1001_5
(
    id    integer NULL,
    value text
);
CREATE UNIQUE INDEX no1001_5_ind_unique ON public.no1001_5 (id);

-- PARTIAL UNIQUE INDEX
-- no1001 - no
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_6;
CREATE TABLE public.no1001_6
(
    id    integer NOT NULL,
    value text
);
CREATE UNIQUE INDEX no1001_6_ind_unique_partial ON public.no1001_6 (id) WHERE (value = 'value');


-- UNIQUE NULLS NOT DISTINCT + nullable column
-- no1001 - ok
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_7;
CREATE TABLE public.no1001_7
(
    id    integer NULL,
    value text,
    CONSTRAINT no1001_7_unique_nullable_nulls_distinct UNIQUE NULLS NOT DISTINCT (id)
);
INSERT INTO public.no1001_7 (id, value) VALUES(NULL, '10');

-- UNIQUE INDEX + nullable column + NULLS NOT DISTINCT
-- no1001 - ok
-- no1002 - no
DROP TABLE IF EXISTS public.no1001_8;
CREATE TABLE public.no1001_8
(
    id    integer NULL,
    value text
);
CREATE UNIQUE INDEX no1001_8_ind_unique ON public.no1001_8 (id) NULLS NOT DISTINCT;
