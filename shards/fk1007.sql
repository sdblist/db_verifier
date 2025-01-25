-- fk1007 - not involved in foreign keys
SELECT
    t.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname)) AS object_name,
    'relation' AS object_type,
    'fk1007' AS check_code,
    'notice' AS check_level,
    'not involved in foreign keys' AS check_name,
    json_build_object(
        'object_id', t.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'object_type', 'relation',
        'check', json_build_object(
            'check_code', 'fk1007',
            'parent_check_code', null,
            'check_name', 'not involved in foreign keys',
            'check_level', 'notice',
            'check_version', 1,
            'object_type', 'relation',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_class AS t
INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    t.relkind IN ('r', 'p')
    AND n.nspname NOT IN ('information_schema', 'pg_catalog')
    AND t.oid NOT IN (SELECT conrelid FROM pg_catalog.pg_constraint WHERE contype IN ('f'))
    AND t.oid NOT IN (SELECT confrelid FROM pg_catalog.pg_constraint WHERE contype IN ('f'))
