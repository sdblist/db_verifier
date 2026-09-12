-- i1012 - duplicate columns in index

CREATE TABLE public.i1012_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    i1    integer NOT NULL,
    i2    integer NOT NULL,
    CONSTRAINT i1012_1_pk PRIMARY KEY (id)
);

-- i1012 - no - i_i1012_btree_good
CREATE INDEX i_i1012_btree_good ON public.i1012_1 USING btree (i1, i2, id);
-- i1012 - yes - i_i1012_btree_bad
CREATE INDEX i_i1012_btree_bad ON public.i1012_1 USING btree (i1, i2, i1);
-- i1012 - yes - i_i1012_unique_btree_bad
CREATE INDEX i_i1012_unique_btree_bad ON public.i1012_1 USING btree (i1, i1);
