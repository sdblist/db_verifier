DROP TABLE IF EXISTS public.i1001_1 CASCADE;
CREATE TABLE public.i1001_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value integer NOT NULL,
    CONSTRAINT i1001_1_pk PRIMARY KEY (id),
    CONSTRAINT i1001_1_unique UNIQUE (value)
);

CREATE UNIQUE INDEX i_id_unique ON public.i1001_1 USING btree (id);
CREATE UNIQUE INDEX i_id_unique_desc ON public.i1001_1 USING btree (id DESC);
CREATE INDEX i_id ON public.i1001_1 USING btree (id);
CREATE INDEX i_id_partial ON public.i1001_1 USING btree (id) WHERE (id > 0);
CREATE UNIQUE INDEX i_id_unique_to_lower_text ON public.i1001_1 USING btree (lower(id::text));

CREATE UNIQUE INDEX i_value_unique ON public.i1001_1 USING btree (value);
CREATE UNIQUE INDEX i_value_unique_desc ON public.i1001_1 USING btree (value DESC);
CREATE INDEX i_value ON public.i1001_1 USING btree (value);


-- unique and regular index with identical columns
CREATE UNIQUE INDEX i_id_value_unique ON public.i1001_1 USING btree (id, value);
CREATE INDEX i_id_value ON public.i1001_1 USING btree (id, value);

-- with include
CREATE UNIQUE INDEX i_id_unique_include_value ON public.i1001_1 USING btree (id) INCLUDE (value);
CREATE INDEX i_id_include_value ON public.i1001_1 USING btree (id) INCLUDE (value);
