DROP TABLE IF EXISTS public.i1003_1 CASCADE;
CREATE TABLE public.i1003_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value integer NOT NULL,
    CONSTRAINT i1003_1_pk PRIMARY KEY (id),
    CONSTRAINT i1003_1_unique UNIQUE (value)
);

CREATE INDEX i_id ON public.i1003_1 USING btree (id);
CREATE INDEX i_value_desc ON public.i1003_1 USING btree (value DESC);