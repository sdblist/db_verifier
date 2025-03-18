-- n1032 - index name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- "boolean"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1032' AND object_name = 'public."boolean"')::integer
    -- "case"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1032' AND object_name = 'public."case"')::integer
    -- "notnull"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1032' AND object_name = 'public."notnull"')::integer
;
