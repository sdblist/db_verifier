-- n1025 - confusion in name of constraint
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- n1025_1_pk
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1025' AND object_name = 'n1025_1_pk')::integer
    -- n1025_1_fk
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1025' AND object_name = 'n1025_1_fk')::integer
;
