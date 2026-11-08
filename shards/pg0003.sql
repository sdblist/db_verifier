-- pg0003 - function with SECURITY DEFINER and without fixed search_path
SELECT
    p.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', p.proname)) AS object_name,
    'function' AS object_type,
    'pg0003' AS check_code,
    'warning' AS check_level,
    'function with SECURITY DEFINER and without fixed search_path' AS check_name,
    json_build_object(
        'object_id', p.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', p.proname)),
        'object_type', 'function',
        'check', json_build_object(
            'check_code', 'pg0003',
            'parent_check_code', null,
            'check_name', 'function with SECURITY DEFINER and without fixed search_path',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'function',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM pg_catalog.pg_proc AS p
    INNER JOIN pg_catalog.pg_namespace AS n ON p.pronamespace = n.oid
WHERE
    n.nspname NOT IN ('information_schema', 'pg_catalog')
    AND NOT EXISTS (SELECT * FROM unnest(COALESCE(p.proconfig, '{}'::text[])) AS pcfg
        WHERE pcfg LIKE 'search_path=%')
    AND NOT EXISTS (SELECT * FROM pg_catalog.pg_depend WHERE objid = p.oid AND deptype = 'e')
