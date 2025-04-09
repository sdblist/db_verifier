-- n1025 - confusion in name of constraint
SELECT
    c1.oid AS object_id,
    format('%I', c1.conname) AS object_name,
    'constraint' AS object_type,
    'n1025' AS check_code,
    'warning' AS check_level,
    'confusion in name of constraint' AS check_name,
    json_build_object(
        'object_id', c1.oid,
        'object_name', format('%I', c1.conname),
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'constraint_type', c1.contype,
        'similar_constraint_name', ('%I', c2.conname),
        'check', json_build_object(
            'check_code', 'n1025',
            'parent_check_code', null,
            'check_name', 'confusion in name of constraint',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'constraint',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_constraint AS c1
    INNER JOIN pg_catalog.pg_constraint AS c2 ON c1.oid < c2.oid AND c1.conrelid = c2.conrelid
        AND lower(regexp_replace(c1.conname, '[\s+.\\]', '', 'g')) =
            lower(regexp_replace(c2.conname, '[\s+.\\]', '', 'g'))
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = c1.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
