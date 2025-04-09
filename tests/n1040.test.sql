-- n1040 - schema name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- "all"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1040' AND object_name = '"all"')::integer
    -- "user"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1040' AND object_name = '"user"')::integer
;
