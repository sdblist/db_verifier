-- insert invalid data and create not valid constraint
-- c1001 - no
DROP TABLE IF EXISTS public.c1001_1 CASCADE;
CREATE TABLE public.c1001_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    parent_id integer NOT NULL,
    value integer NOT NULL,
    CONSTRAINT c1001_1_pk PRIMARY KEY (id)
);

INSERT INTO public.c1001_1 (parent_id, value) VALUES(1, 1);
INSERT INTO public.c1001_1 (parent_id, value) VALUES(-1, -1);

ALTER TABLE public.c1001_1 ADD CONSTRAINT c1001_1_fk FOREIGN KEY (parent_id) REFERENCES public.c1001_1(id) NOT VALID;
ALTER TABLE public.c1001_1 ADD CONSTRAINT c1001_1_chk CHECK ( value > 0 ) NOT VALID;

INSERT INTO public.c1001_1 (parent_id, value) VALUES(2, 2);

-- ALTER TABLE public.c1001_1 VALIDATE CONSTRAINT c1001_1_fk;
-- ALTER TABLE public.c1001_1 VALIDATE CONSTRAINT c1001_1_chk;