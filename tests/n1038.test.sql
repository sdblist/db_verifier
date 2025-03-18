-- n1038 - attribute name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.n1038_1."all"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1038' AND object_name = 'public.n1038_1."all"')::integer
    -- public.n1038_1."authorization"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1038' AND object_name = 'public.n1038_1."authorization"')::integer
;
