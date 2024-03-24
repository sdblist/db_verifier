-- fk1010 similar FK
-- fk1011 FK have common attributes
DROP TABLE IF EXISTS public.fk1009_1 CASCADE;
CREATE TABLE public.fk1009_1
(
    id    integer NOT NULL,
    i1    integer NOT NULL,
    i2    integer NOT NULL,
    CONSTRAINT fk1009_1_pk PRIMARY KEY (id),
    CONSTRAINT fk1009_1_unique_id_i1 UNIQUE (id, i1),
    CONSTRAINT fk1009_1_unique_id_i2 UNIQUE (id, i2),
    CONSTRAINT fk1009_1_unique_i2 UNIQUE (id, i1)
);

-- fk1010 - no  fk1009_1_fk_fk1009_1_id_i2 + fk1009_1_fk_fk1009_1_id_i2_copy
-- fk1011 - no  fk1009_1_fk_fk1009_1_id + fk1009_1_fk_fk1009_1_id_i1
-- fk1011 - no  fk1009_1_fk_fk1009_1_id + fk1009_1_fk_fk1009_1_id_i2
-- fk1011 - no  fk1009_1_fk_fk1009_1_id + fk1009_1_fk_fk1009_1_id_i2_copy
-- fk1011 - no  fk1009_1_fk_fk1009_1_id_i1 + fk1009_1_fk_fk1009_1_id_i2
-- fk1011 - no  fk1009_1_fk_fk1009_1_id_i1 + fk1009_1_fk_fk1009_1_id_i2_copy
-- fk1011 - no fk1009_1_fk_fk1009_1_id_i2_copy + fk1009_1_fk_fk1009_1_i2
DROP TABLE IF EXISTS public.fk1009_1_fk;
CREATE TABLE public.fk1009_1_fk
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    fk1009_1_id integer NOT NULL,
    fk1009_1_i1 integer NOT NULL,
    fk1009_1_i2 integer NOT NULL,
    CONSTRAINT fk1009_1_fk_pk PRIMARY KEY (id),
    CONSTRAINT fk1009_1_fk_fk1009_1_id FOREIGN KEY (fk1009_1_id) REFERENCES public.fk1009_1(id),
    CONSTRAINT fk1009_1_fk_fk1009_1_id_i1 FOREIGN KEY (fk1009_1_id, fk1009_1_i1) REFERENCES public.fk1009_1(id, i1),
    CONSTRAINT fk1009_1_fk_fk1009_1_id_i2 FOREIGN KEY (fk1009_1_id, fk1009_1_i2) REFERENCES public.fk1009_1(id, i2),
    CONSTRAINT fk1009_1_fk_fk1009_1_id_i2_copy FOREIGN KEY (fk1009_1_id, fk1009_1_i2) REFERENCES public.fk1009_1(id, i2),
    CONSTRAINT fk1009_1_fk_fk1009_1_i2 FOREIGN KEY (fk1009_1_i2) REFERENCES public.fk1009_1(i2)
);
