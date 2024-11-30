-- c1001 - constraint not validated
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- c1001_1_fk
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'c1001' AND object_name = 'c1001_1_fk')::integer
    -- c1001_1_chk
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'c1001' AND object_name = 'c1001_1_chk')::integer
;
