-- n1038 - attribute name reserved keyword
SELECT
    a.attnum AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname), '.',  format('%I', a.attname)) AS object_name,
    'attribute' AS object_type,
    'n1038' AS check_code,
    'warning' AS check_level,
    'attribute name reserved keyword' AS check_name,
    json_build_object(
        'object_id', a.attnum,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname), '.',  format('%I', a.attname)),
        'object_type', 'attribute',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'check', json_build_object(
            'check_code', 'n1038',
            'parent_check_code', null,
            'check_name', 'attribute name reserved keyword',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'attribute',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_attribute AS a
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = a.attrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    a.attname IN (SELECT word FROM pg_get_keywords() WHERE catcode NOT IN ('U'))
    AND a.attnum >= 1
