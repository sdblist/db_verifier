-- pg0001 - wrong volatility marking for json_strip_nulls and jsonb_strip_nulls
SELECT
    p.oid AS object_id,
    p.proname AS object_name,
    'function' AS object_type,
    'pg0001' AS check_code,
    'error' AS check_level,
    'wrong volatility marking for json_strip_nulls and jsonb_strip_nulls' AS check_name,
    json_build_object(
        'object_id', p.oid,
        'object_name', p.proname,
        'object_type', 'function',
        'check', json_build_object(
            'check_code', 'pg0001',
            'parent_check_code', null,
            'check_name', 'wrong volatility marking for json_strip_nulls and jsonb_strip_nulls',
            'check_level', 'error',
            'check_version', 1,
            'object_type', 'function',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_proc AS p
WHERE
    p.oid IN ('3261', '3262') AND p.provolatile <> 'i'