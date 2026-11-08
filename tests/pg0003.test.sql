-- pg0003 - function with SECURITY DEFINER and without fixed search_path
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.pg0003_1
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'pg0003' AND object_name = 'public.pg0003_1')::integer
;