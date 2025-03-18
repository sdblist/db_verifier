-- n1030 - constraint name reserved keyword
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- "boolean"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1030' AND object_name = '"boolean"')::integer
    -- "case"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1030' AND object_name = '"case"')::integer
    -- "notnull"
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1030' AND object_name = '"notnull"')::integer
;
