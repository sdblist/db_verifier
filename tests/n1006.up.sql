-- n1006 - unwanted characters in attribute name

-- "n1006 "     - yes
-- "	n1006"  - yes
-- "n.1006"     - yes
-- "n+1006"     - yes
-- "n\n1006"    - yes
-- "n
-- 1006"        - yes
DROP TABLE IF EXISTS public.n1006 CASCADE;
CREATE TABLE public.n1006
(
    id          integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    "n1006 "    integer,
    "	n1006"  integer,
    "n.1006"    integer,
    "n+1006"    integer,
    "n\n1006"   integer,
    "n
    1006"       integer,
    CONSTRAINT n1006_pk PRIMARY KEY (id)
);
