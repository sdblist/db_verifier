-- pg0002 - PUBLIC has CREATE on public schema (PG>=15)
SELECT
    0 AS object_id,
    'PUBLIC' AS object_name,
    'privilege' AS object_type,
    'pg0002' AS check_code,
    'error' AS check_level,
    'PUBLIC has CREATE on public schema (PG>=15)' AS check_name,
    json_build_object(
        'object_id', 0,
        'object_name', 'PUBLIC',
        'object_type', 'privilege',
        'check', json_build_object(
            'check_code', 'pg0002',
            'parent_check_code', null,
            'check_name', 'PUBLIC has CREATE on public schema (PG>=15)',
            'check_level', 'error',
            'check_version', 1,
            'object_type', 'privilege',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
WHERE
    pg_catalog.has_schema_privilege('public', 'public', 'CREATE')
            AND current_setting('server_version_num')::integer >= 150000