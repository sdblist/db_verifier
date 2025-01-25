-- fk1007 - not involved in foreign keys
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.fk1007_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1007' AND object_name = 'public.fk1007_2')::integer
;
