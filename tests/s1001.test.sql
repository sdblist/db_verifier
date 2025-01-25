-- s1001 - unlogged sequence
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.r1002_1
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1001' AND object_name = 'public.s1001_2_id_seq')::integer
    -- public.r1002_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1001' AND object_name = 'public.s1001_3')::integer
;
