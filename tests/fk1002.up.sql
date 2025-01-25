-- fk1002 - check fk uses nullable columns

-- PRIMARY KEY + same data types + nullable
-- fk1002 - yes - fk1002_1_fk_fk1002_1
CREATE TABLE public.fk1002_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text,
    CONSTRAINT fk1002_1_pk PRIMARY KEY (id)
);

INSERT INTO public.fk1002_1 (value) VALUES('10');
INSERT INTO public.fk1002_1 (id, value) OVERRIDING SYSTEM VALUE VALUES (2000000000, '2000000000');

CREATE TABLE public.fk1002_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1002_1_id integer,
    value text,
    CONSTRAINT fk1002_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1002_1_fk_fk1002_1 FOREIGN KEY (fk1002_1_id) REFERENCES public.fk1002_1(id)
);
INSERT INTO public.fk1002_1_fk (fk1002_1_id, value) VALUES(NULL, 'NULL');
INSERT INTO public.fk1002_1_fk (fk1002_1_id, value) VALUES(1, '1');
INSERT INTO public.fk1002_1_fk (fk1002_1_id, value) VALUES(2000000000, '2000000000');

-- PRIMARY KEY + same data types + nullable + multi column FK
-- fk1002 - yes - fk1002_2_fk_fk1002_2
CREATE TABLE public.fk1002_2
(
    id    integer NOT NULL,
    value varchar(10),
    CONSTRAINT fk1002_2_unique UNIQUE (id, value)
);

INSERT INTO public.fk1002_2 (id, value) VALUES (10, NULL);
INSERT INTO public.fk1002_2 (id, value) VALUES (20, '20');

CREATE TABLE public.fk1002_2_fk
(
    fk1002_2_id integer NOT NULL,
    fk1002_2_value varchar(10),
    CONSTRAINT fk1002_2_fk_fk1002_2 FOREIGN KEY (fk1002_2_id, fk1002_2_value) REFERENCES public.fk1002_2(id, value)
);
INSERT INTO public.fk1002_2_fk (fk1002_2_id, fk1002_2_value) VALUES(20, '20');
INSERT INTO public.fk1002_2_fk (fk1002_2_id, fk1002_2_value) VALUES(30, NULL);

-- PRIMARY KEY + same data types + nullable + multi column FK + MATCH FULL
-- fk1002 - ok (MATCH FULL)
CREATE TABLE public.fk1002_3
(
    id    integer NOT NULL,
    value varchar(10) NOT NULL,
    CONSTRAINT fk1002_3_pk PRIMARY KEY (id, value)
);

INSERT INTO public.fk1002_3 (id, value) VALUES (10, '10');

CREATE TABLE public.fk1002_3_fk
(
    fk1002_3_id integer NOT NULL,
    fk1002_3_value varchar(10),
    CONSTRAINT fk1002_3_fk_fk1002_3 FOREIGN KEY (fk1002_3_id, fk1002_3_value)
        REFERENCES public.fk1002_3 (id, value) MATCH FULL
);

INSERT INTO public.fk1002_3_fk (fk1002_3_id, fk1002_3_value) VALUES (10, '10');
-- MATCH FULL will not allow one column of a multicolumn foreign key to be null unless all foreign key columns are null;
-- if they are all null, the row is not required to have a match in the referenced table.
--INSERT INTO public.fk1002_3_fk (fk1002_3_id, fk1002_3_value) VALUES (20, NULL);
