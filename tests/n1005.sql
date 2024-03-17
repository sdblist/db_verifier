-- n1005 - yes (confusion in name of relation attributes)
-- attribute id => " id ", "Id"
-- attribute " id " => "Id"
DROP TABLE IF EXISTS public.n1005_1 CASCADE;
CREATE TABLE public.n1005_1
(
    id     integer,
    " id " integer,
    "Id"   integer,
    CONSTRAINT n1005_1_pk PRIMARY KEY (id)
);




