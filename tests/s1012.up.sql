-- s1012 - less 20% unused sequence values

-- s1012 20% - yes - s1012_1_id_seq
CREATE TABLE public.s1012_1
(
    id    integer GENERATED ALWAYS AS IDENTITY (START WITH 500 MAXVALUE 510) NOT NULL,
    CONSTRAINT s1012_1_pk PRIMARY KEY (id)
);

-- s1012 20% - yes - s1012_2
CREATE SEQUENCE public.s1012_2 AS smallint INCREMENT BY 1 MAXVALUE 100 START WITH 92;

-- s1012 20% - yes - ".s1012_3 "
CREATE SEQUENCE public.".s1012_3 " AS smallint INCREMENT BY -1 MINVALUE -100 START WITH -85;

-- s1012 20% - ok
CREATE SEQUENCE public.s1012_4 AS smallint INCREMENT BY -1 MINVALUE -100 START WITH -10;

-- CYCLE
-- s1012 20% - ok
CREATE SEQUENCE public.s1012_5 AS smallint INCREMENT BY 1 MAXVALUE 100 START WITH 99 CYCLE;
