-- i1012 - duplicate columns in index
SELECT
    ir.oid AS object_id,
    concat(format('%I', n.nspname), '.',  format('%I', ir.relname)) AS object_name,
    'index' AS object_type,
    'i1012' AS check_code,
    'error' AS check_level,
    'duplicate columns in index' AS check_name,
    json_build_object(
        'object_id', ir.oid,
        'object_name', concat(format('%I', n.nspname), '.',  format('%I', ir.relname)),
        'object_type', 'index',
        'relation_name', concat(format('%I', nt.nspname), '.',  format('%I', t.relname)),
        'att_name', format('%I', ia.att_name),
        'check', json_build_object(
            'check_code', 'i1012',
            'check_name', 'duplicate columns in index',
            'check_level', 'error',
            'check_version', 1,
            'object_type', 'index',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM (
        SELECT
            i.indexrelid,
            i.indrelid,
            a.attname AS att_name
        FROM pg_catalog.pg_index AS i
            CROSS JOIN LATERAL generate_subscripts(i.indkey, 1) AS k
            LEFT JOIN pg_catalog.pg_attribute AS a
                ON a.attrelid = i.indrelid AND a.attnum = i.indkey[k]
        WHERE
            a.attnum >= 1
        GROUP BY 1, 2, 3
        HAVING count(*) > 1
        ) AS ia
    INNER JOIN pg_catalog.pg_class AS ir
        ON ir.oid = ia.indexrelid
    INNER JOIN pg_catalog.pg_namespace AS n
        ON ir.relnamespace = n.oid
    INNER JOIN pg_catalog.pg_class AS t
        ON t.oid = ia.indrelid
    INNER JOIN pg_catalog.pg_namespace AS nt
        ON t.relnamespace = nt.oid
