-- fk1014 - duplicate FK attributes in source relation
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- fk1014_1_fk_fk1014_1_i1_i2_bad
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1014' AND object_name = 'fk1014_1_fk_fk1014_1_i1_i2_bad')::integer
;
