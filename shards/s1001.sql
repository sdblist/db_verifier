-- s1001 - unlogged sequence
SELECT
    t.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname)) AS object_name,
    'sequence' AS object_type,
    's1001' AS check_code,
    'warning' AS check_level,
    'unlogged sequence' AS check_name,
    json_build_object(
        'object_id', t.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'object_type', 'sequence',
        'check', json_build_object(
            'check_code', 's1001',
            'parent_check_code', null,
            'check_name', 'unlogged sequence',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'sequence',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_class AS t
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    t.relkind IN ('S')
    AND t.relpersistence = 'u'
