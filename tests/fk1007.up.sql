-- fk1007 - not involved in foreign keys

-- fk1007 - ok
CREATE TABLE public.fk1007_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text,
    CONSTRAINT fk1007_1_pk PRIMARY KEY (id)
);

-- fk1007 - ok
CREATE TABLE public.fk1007_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1007_1_id integer NOT NULL,
    value text,
    CONSTRAINT fk1007_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1007_1_fk_fk1007_1 FOREIGN KEY (fk1007_1_id) REFERENCES public.fk1007_1(id)
);


-- no FK
-- fk1007 - yes - public.fk1007_2
CREATE TABLE public.fk1007_2
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value text NOT NULL,
    CONSTRAINT fk1007_2_pk PRIMARY KEY (id, value)
);
