-- fk1014 - duplicate FK attributes in source relation

CREATE TABLE public.fk1014_1
(
    id    integer NOT NULL,
    i1    integer NOT NULL,
    i2    integer NOT NULL,
    CONSTRAINT fk1014_1_pk PRIMARY KEY (id),
    CONSTRAINT fk1014_1_unique_i1_i2 UNIQUE (i1, i2)
);

-- fk1014 - yes - fk1014_1_fk_fk1014_1_i1_i2_bad
CREATE TABLE public.fk1014_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1014_1_i1 integer NOT NULL,
    fk1014_1_i2 integer NOT NULL,
    CONSTRAINT fk1014_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1014_1_fk_fk1014_1_i1_i2_good FOREIGN KEY (fk1014_1_i1, fk1014_1_i2) REFERENCES public.fk1014_1(i1, i2),
    CONSTRAINT fk1014_1_fk_fk1014_1_i1_i2_bad FOREIGN KEY (fk1014_1_i1, fk1014_1_i1) REFERENCES public.fk1014_1(i1, i2)
);
