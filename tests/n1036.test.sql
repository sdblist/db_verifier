-- n1036 - sequence name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public."all"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1036' AND object_name = 'public."all"')::integer
    -- public."user"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1036' AND object_name = 'public."user"')::integer
;
