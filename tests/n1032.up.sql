-- n1032 - index name reserved keyword

-- n1032 - yes
CREATE TABLE public.n1032_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    parent_id integer NOT NULL,
    value integer NOT NULL,
    CONSTRAINT n1032_1_pk PRIMARY KEY (id)
);

-- n1032 - yes - boolean
CREATE INDEX "boolean" ON public.n1032_1 USING btree (value);
-- n1032 - yes - case
CREATE INDEX "case" ON public.n1032_1 USING btree (parent_id);
-- n1032 - yes - notnull
CREATE INDEX "notnull" ON public.n1032_1 USING btree (parent_id desc);
