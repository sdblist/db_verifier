-- fk1011 - FK have common attributes
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i2_copy
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i2_copy')::integer
    -- fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i1
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i1')::integer
    -- fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i2')::integer
    -- fk1011_1_fk_fk1011_1_id_i1 + fk1011_1_fk_fk1011_1_id_i2_copy
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id_i1'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i2_copy')::integer
    -- fk1011_1_fk_fk1011_1_id_i1 + fk1011_1_fk_fk1011_1_id_i2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id_i1'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i2')::integer
    -- fk1011_1_fk_fk1011_1_id_i2 + fk1011_1_fk_fk1011_1_id_i2_copy
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id_i2'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_id_i2_copy')::integer
    -- fk1011_1_fk_fk1011_1_id_i2 + fk1011_1_fk_fk1011_1_i2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id_i2'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_i2')::integer
    -- fk1011_1_fk_fk1011_1_id_i2_copy + fk1011_1_fk_fk1011_1_i2
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'fk1011' AND object_name = 'fk1011_1_fk_fk1011_1_id_i2_copy'
       AND check_result_json::jsonb->>'similar_constraint_name' = 'fk1011_1_fk_fk1011_1_i2')::integer
;
