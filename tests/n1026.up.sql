-- n1026 - unwanted characters in constraint name

-- n1026 - yes - "n1026_1_pk "
CREATE TABLE public.n1026_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    parent_id integer NOT NULL,
    CONSTRAINT "n1026_1_pk " PRIMARY KEY (id)
);

-- n1026 - no - n1026_1_fk
ALTER TABLE public.n1026_1 ADD CONSTRAINT "n1026_1_fk" FOREIGN KEY (parent_id) REFERENCES public.n1026_1(id);
-- n1026 - yes - "n1026_1_FK "
ALTER TABLE public.n1026_1 ADD CONSTRAINT "n1026_1_FK " FOREIGN KEY (parent_id) REFERENCES public.n1026_1(id);
