-- sm0002 - column with varchar/bpchar type and no length specified
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.sm0002_1.bpchar_wo_length
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0002' AND object_name = 'public.sm0002_1.bpchar_wo_length')::integer
    -- public.sm0002_1.varchar_wo_length
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0002' AND object_name = 'public.sm0002_1.varchar_wo_length')::integer
;