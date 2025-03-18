-- n1032 - index name reserved keyword
SELECT
    ic.oid AS object_id,
    concat(format('%I', icn.nspname), '.',  format('%I', ic.relname)) AS object_name,
    'index' AS object_type,
    'n1032' AS check_code,
    'warning' AS check_level,
    'index name reserved keyword' AS check_name,
    json_build_object(
        'object_id', ic.oid,
        'object_name', concat(format('%I', icn.nspname), '.',  format('%I', ic.relname)),
        'object_type', 'index',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'check', json_build_object(
            'check_code', 'n1032',
            'parent_check_code', null,
            'check_name', 'index name reserved keyword',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'index',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_index AS i
    INNER JOIN pg_catalog.pg_class AS ic ON i.indexrelid = ic.oid
    INNER JOIN pg_catalog.pg_namespace AS icn ON ic.relnamespace = icn.oid
    INNER JOIN pg_catalog.pg_class AS t ON i.indrelid = t.oid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    ic.relname IN (SELECT word FROM pg_get_keywords() WHERE catcode NOT IN ('U'))

