-- sm0001 - invalid attribute type for uuid
SELECT
    a.attnum AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', c.relname), '.',  format('%I', a.attname)) AS object_name,
    'attribute' AS object_type,
    'sm0001' AS check_code,
    'notice' AS check_level,
    'invalid attribute type for uuid' AS check_name,
    json_build_object(
        'object_id', a.attnum,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', c.relname), '.',  format('%I', a.attname)),
        'object_type', 'attribute',
        'relation_id', a.attrelid,
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', c.relname)),
        'check', json_build_object(
            'check_code', 'sm0001',
            'parent_check_code', null,
            'check_name', 'invalid attribute type for uuid',
            'check_level', 'notice',
            'check_version', 1,
            'object_type', 'attribute',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_attribute AS a
    INNER JOIN pg_catalog.pg_class AS c ON a.attrelid = c.oid
    INNER JOIN pg_catalog.pg_namespace AS n ON c.relnamespace = n.oid
WHERE
    a.attnum >= 1 AND (a.atttypid IN (1042, 1043) AND ((a.atttypmod - 4) IN (32, 36))
        AND (a.attname ILIKE '%uid%' OR a.attname ILIKE '%\_id%' OR a.attname ILIKE 'id'))