-- n1036 - sequence name reserved keyword
SELECT
    t.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname)) AS object_name,
    'sequence' AS object_type,
    'n1036' AS check_code,
    'warning' AS check_level,
    'sequence name reserved keyword' AS check_name,
    json_build_object(
        'object_id', t.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'object_type', 'sequence',
        'check', json_build_object(
            'check_code', 'n1036',
            'parent_check_code', null,
            'check_name', 'sequence name reserved keyword',
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
    AND t.relname IN (SELECT word FROM pg_get_keywords() WHERE catcode NOT IN ('U'))

