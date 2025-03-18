-- n1034 - relation name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public."table"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1034' AND object_name = 'public."table"')::integer
    -- public."between"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1034' AND object_name = 'public."between"')::integer
;
