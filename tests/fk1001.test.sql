-- fk1001 - fk uses mismatched types
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- fk1001_2_fk_fk1001_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1001' AND object_name = 'fk1001_2_fk_fk1001_2')::integer
    -- fk1001_3_fk_fk1001_3
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1001' AND object_name = 'fk1001_3_fk_fk1001_3')::integer
;
