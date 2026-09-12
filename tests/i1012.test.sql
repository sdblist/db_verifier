-- i1012 - duplicate columns in index
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- i_i1012_btree_bad
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'i1012' AND object_name = 'public.i_i1012_btree_bad')::integer
    -- i_i1012_unique_btree_bad
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'i1012' AND object_name = 'public.i_i1012_unique_btree_bad')::integer
;
