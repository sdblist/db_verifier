-- fk1010 - similar FK
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- fk1010_1_fk_fk1010_1_id_i2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1010' AND object_name = 'fk1010_1_fk_fk1010_1_id_i2')::integer
;
