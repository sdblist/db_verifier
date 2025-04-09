-- n1026 - unwanted characters in constraint name
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- "n1026_1_pk "
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1026' AND object_name = '"n1026_1_pk "')::integer
    -- "n1026_1_FK "
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'n1026' AND object_name = '"n1026_1_FK "')::integer
;
