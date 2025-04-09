-- n1040 - schema name reserved keyword
SELECT
    n.oid AS object_id,
    format('%I', n.nspname) AS object_name,
    'schema' AS object_type,
    'n1040' AS check_code,
    'warning' AS check_level,
    'schema name reserved keyword' AS check_name,
    json_build_object(
        'object_id', n.oid,
        'object_name', format('%I', n.nspname),
        'object_type', 'schema',
        'check', json_build_object(
            'check_code', 'n1040',
            'parent_check_code', null,
            'check_name', 'schema name reserved keyword',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'schema',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_namespace AS n
WHERE
    n.nspname IN (SELECT word FROM pg_get_keywords() WHERE catcode NOT IN ('U'))
