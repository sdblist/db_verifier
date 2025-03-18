-- n1034 - relation name reserved keyword

-- n1034 - yes - public."table"
CREATE TABLE public."table" ();

-- n1034 - ok - public."view"
CREATE VIEW public."view" AS SELECT * FROM public."table";

-- n1034 - yes - public."between"
CREATE VIEW public."between" AS SELECT * FROM public."table";
