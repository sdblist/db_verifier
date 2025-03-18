-- n1034 - relation name reserved keyword
SELECT
    t.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname)) AS object_name,
    'relation' AS object_type,
    'n1034' AS check_code,
    'warning' AS check_level,
    'relation name reserved keyword' AS check_name,
    json_build_object(
        'object_id', t.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'object_type', 'relation',
        'check', json_build_object(
            'check_code', 'n1034',
            'parent_check_code', null,
            'check_name', 'relation name reserved keyword',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'relation',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_class AS t
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    t.relkind IN ('r', 'v', 'm', 'p')
    AND t.relname IN (SELECT word FROM pg_get_keywords() WHERE catcode NOT IN ('U'))

