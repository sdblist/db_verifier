-- n1038 - attribute name reserved keyword

-- n1038 - yes - "all"
-- n1038 - yes - "authorization"
CREATE TABLE public.n1038_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    "all" integer NOT NULL,
    "authorization" integer NOT NULL,
    CONSTRAINT n1038_1_pk PRIMARY KEY (id)
);
