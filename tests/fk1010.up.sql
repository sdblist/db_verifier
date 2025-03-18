-- fk1010 - similar FK

CREATE TABLE public.fk1010_1
(
    id    integer NOT NULL,
    i1    integer NOT NULL,
    i2    integer NOT NULL,
    CONSTRAINT fk1010_1_pk PRIMARY KEY (id),
    CONSTRAINT fk1010_1_unique_id_i1 UNIQUE (id, i1),
    CONSTRAINT fk1010_1_unique_id_i2 UNIQUE (id, i2),
    CONSTRAINT fk1010_1_unique_i2 UNIQUE (i2)
);

-- fk1010 - yes  fk1010_1_fk_fk1010_1_id_i2 + fk1010_1_fk_fk1010_1_id_i2_copy
CREATE TABLE public.fk1010_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1010_1_id integer NOT NULL,
    fk1010_1_i1 integer NOT NULL,
    fk1010_1_i2 integer NOT NULL,
    CONSTRAINT fk1010_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1010_1_fk_fk1010_1_id FOREIGN KEY (fk1010_1_id) REFERENCES public.fk1010_1(id),
    CONSTRAINT fk1010_1_fk_fk1010_1_id_i1 FOREIGN KEY (fk1010_1_id, fk1010_1_i1) REFERENCES public.fk1010_1(id, i1),
    CONSTRAINT fk1010_1_fk_fk1010_1_id_i2 FOREIGN KEY (fk1010_1_id, fk1010_1_i2) REFERENCES public.fk1010_1(id, i2),
    CONSTRAINT fk1010_1_fk_fk1010_1_id_i2_copy FOREIGN KEY (fk1010_1_id, fk1010_1_i2) REFERENCES public.fk1010_1(id, i2),
    CONSTRAINT fk1010_1_fk_fk1010_1_i2 FOREIGN KEY (fk1010_1_i2) REFERENCES public.fk1010_1(i2)
);
