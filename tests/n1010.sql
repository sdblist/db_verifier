-- n1010 - yes (confusion in name of relations)
-- relation n1010_1 => "N1010_1", "n1010_1 "
-- relation "N1010_1" => "n1010_1 "
DROP TABLE IF EXISTS public.n1010_1 CASCADE;
CREATE TABLE public.n1010_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    CONSTRAINT n1010_1_pk PRIMARY KEY (id)
);

DROP TABLE IF EXISTS public."N1010_1" CASCADE;
CREATE TABLE public."N1010_1"
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    CONSTRAINT "N1010_1_pk" PRIMARY KEY (id)
);

DROP TABLE IF EXISTS public."n1010_1 " CASCADE;
CREATE TABLE public."n1010_1 "
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    CONSTRAINT "n1010_1 pk" PRIMARY KEY (id)
);

-- n1010 - yes (confusion in name of relations)
-- relation n1010_2 => "N1010_2 ", " n 1010_2 "
-- relation "N1010_2 " => " n 1010_2 "
DROP TABLE IF EXISTS public."n1010_2" CASCADE;
CREATE TABLE public."n1010_2"
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL
) PARTITION BY HASH (id);

DROP TABLE IF EXISTS public."N1010_2 " CASCADE;
CREATE TABLE public."N1010_2 "
PARTITION OF public."n1010_2"
FOR VALUES WITH (MODULUS 2, REMAINDER 0);

DROP TABLE IF EXISTS public." n 1010_2 " CASCADE;
CREATE TABLE public." n 1010_2 "
PARTITION OF public."n1010_2"
FOR VALUES WITH (MODULUS 2, REMAINDER 1);


