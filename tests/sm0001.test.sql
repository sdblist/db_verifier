-- sm0001 - invalid attribute type for uuid
-- result in public.db_verifier_result

SELECT
    -- count all rows
    (SELECT COUNT(*) FROM public.db_verifier_result)::integer
    -- public.sm0001_2.id
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0001' AND object_name = 'public.sm0001_2.id')::integer
    -- public.sm0001_2.data_uid
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0001' AND object_name = 'public.sm0001_2.data_uid')::integer
    -- public.sm0001_2.data_guid
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0001' AND object_name = 'public.sm0001_2.data_guid')::integer
    -- public.sm0001_2.data_id
    - (SELECT COUNT(*) FROM public.db_verifier_result WHERE check_code = 'sm0001' AND object_name = 'public.sm0001_2.data_id')::integer
;