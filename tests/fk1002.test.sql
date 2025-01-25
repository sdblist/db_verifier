-- fk1002 - check fk uses nullable columns
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- fk1002_1_fk_fk1002_1
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1002' AND object_name = 'fk1002_1_fk_fk1002_1')::integer
    -- fk1002_2_fk_fk1002_2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1002' AND object_name = 'fk1002_2_fk_fk1002_2')::integer
;
