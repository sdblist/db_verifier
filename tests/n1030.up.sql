-- n1030 - constraint name reserved keyword

-- n1030 - yes
CREATE TABLE public.n1030_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    parent_id integer NOT NULL,
    value integer NOT NULL,
    CONSTRAINT n1030_1_pk PRIMARY KEY (id)
);

-- n1030 - yes - boolean
ALTER TABLE public.n1030_1 ADD CONSTRAINT "boolean" FOREIGN KEY (parent_id) REFERENCES public.n1030_1(id);
-- n1030 - yes - case
ALTER TABLE public.n1030_1 ADD CONSTRAINT "case" CHECK (value > 0);
-- n1030 - yes - notnull
ALTER TABLE public.n1030_1 ADD CONSTRAINT "notnull" UNIQUE (value);
