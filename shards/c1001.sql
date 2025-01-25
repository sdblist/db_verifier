-- c1001 - constraint not validated
SELECT
    c.oid AS object_id,
    format('%I', c.conname) AS object_name,
    'constraint' AS object_type,
    'c1001' AS check_code,
    'warning' AS check_level,
    'constraint not validated' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', format('%I', c.conname),
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'constraint_type', c.contype,
        'check', json_build_object(
            'check_code', 'c1001',
            'parent_check_code', null,
            'check_name', 'constraint not validated',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'constraint',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_constraint AS c
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    c.contype IN ('c', 'f')
    AND (NOT c.convalidated)
