-- n1025 - confusion in name of constraint

-- n1025 - yes - n1025_1_pk
CREATE TABLE public.n1025_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    parent_id integer NOT NULL,
    CONSTRAINT n1025_1_pk PRIMARY KEY (id)
);

-- n1025 - yes - n1025_1_fk
ALTER TABLE public.n1025_1 ADD CONSTRAINT "n1025_1_fk" FOREIGN KEY (parent_id) REFERENCES public.n1025_1(id);
-- n1025 - no - "n1025_1_FK " (oid n1025_1_fk < oid n1025_1_FK)
ALTER TABLE public.n1025_1 ADD CONSTRAINT "n1025_1_FK " FOREIGN KEY (parent_id) REFERENCES public.n1025_1(id);
-- n1025 - no - " n1025_1_PK" (oid n1025_1_pk < oid " n1025_1_PK")
ALTER TABLE public.n1025_1 ADD CONSTRAINT " n1025_1_PK" FOREIGN KEY (parent_id) REFERENCES public.n1025_1(id);
