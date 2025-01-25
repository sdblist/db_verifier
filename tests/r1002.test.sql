-- r1002 - relation without columns
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.r1002_1
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'r1002' AND object_name = 'public.r1002_1')::integer
    -- public.r1002_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'r1002' AND object_name = 'public.r1002_2')::integer
;
