-- s1010 - less 5% unused sequence values
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.s1010_1_id_seq
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1010' AND object_name = 'public.s1010_1_id_seq')::integer
;