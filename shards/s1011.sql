-- s1011 - less 10% unused sequence values
SELECT
    t.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', t.relname)) AS object_name,
    'sequence' AS object_type,
    's1011' AS check_code,
    'error' AS check_level,
    'less 10% unused sequence values' AS check_name,
    json_build_object(
        'object_id', t.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'object_type', 'sequence',
        'check', json_build_object(
            'check_code', 's1011',
            'parent_check_code', 's1010',
            'check_name', 'less 10% unused sequence values',
            'check_level', 'error',
            'check_version', 1,
            'object_type', 'sequence',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_sequence AS s
    INNER JOIN pg_catalog.pg_class AS t ON s.seqrelid = t.oid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
    LEFT JOIN pg_catalog.pg_sequences sv ON concat(format('%I', sv.schemaname), '.', format('%I', sv.sequencename)) =
                                            concat(format('%I', n.nspname), '.',  format('%I', t.relname))
WHERE
    10.0 >=
    (CASE
        WHEN s.seqincrement > 0 THEN 100.0*(s.seqmax - COALESCE(sv.last_value, s.seqstart))/(s.seqmax - s.seqmin)
        ELSE 100.0*(COALESCE(sv.last_value, s.seqstart) - s.seqmin)/(s.seqmax - s.seqmin)
    END::numeric(5, 2))
    AND NOT s.seqcycle
