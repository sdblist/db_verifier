-- n1026 - unwanted characters in constraint name
SELECT
    c.oid AS object_id,
    format('%I', c.conname) AS object_name,
    'constraint' AS object_type,
    'n1026' AS check_code,
    'notice' AS check_level,
    'unwanted characters in constraint name' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', format('%I', c.conname),
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'constraint_type', c.contype,
        'check', json_build_object(
            'check_code', 'n1026',
            'parent_check_code', null,
            'check_name', 'unwanted characters in constraint name',
            'check_level', 'notice',
            'check_version', 1,
            'object_type', 'constraint',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_constraint AS c
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
WHERE
    c.conname <> regexp_replace(c.conname, '[\s+.\\]', '', 'g')
