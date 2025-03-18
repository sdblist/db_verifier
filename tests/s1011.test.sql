-- s1011 - less 10% unused sequence values
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.s1011_1_id_seq
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1011' AND object_name = 'public.s1011_1_id_seq')::integer
    -- public.s1011_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1011' AND object_name = 'public.s1011_2')::integer
;