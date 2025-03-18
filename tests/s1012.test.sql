-- s1012 - less 20% unused sequence values
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.s1012_1_id_seq
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1012' AND object_name = 'public.s1012_1_id_seq')::integer
    -- public.s1012_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1012' AND object_name = 'public.s1012_2')::integer
    -- public.".s1012_3 "
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 's1012' AND object_name = 'public.".s1012_3 "')::integer
;