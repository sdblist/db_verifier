DROP TABLE IF EXISTS public.i1010_1 CASCADE;
CREATE TABLE public.i1010_1
(
    id    integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    value integer[] NOT NULL,
    CONSTRAINT i1010_1_pk PRIMARY KEY (id)
);

INSERT INTO public.i1010_1 (value) VALUES('{1, 3, 5}');
INSERT INTO public.i1010_1 (value) VALUES(ARRAY[2, 4, 6]);

-- i1010 - no
CREATE INDEX i_btree_value ON public.i1010_1 USING btree (value);
-- i1010 - ok
CREATE INDEX i_gin_value ON public.i1010_1 USING gin (value);

SET enable_seqscan TO off;

-- Bitmap Index Scan on i_gin_value
EXPLAIN ANALYZE
SELECT id FROM public.i1010_1 WHERE value @> ARRAY[1];

-- Index Scan using i_btree_value
EXPLAIN ANALYZE
SELECT id FROM public.i1010_1 WHERE value = ARRAY[2, 4, 6];

-- SET enable_seqscan TO on;