-- fk1002 - fk uses nullable columns
SELECT
    c.oid AS object_id,
    format('%I', c.conname) AS object_name,
    'constraint' AS object_type,
    'fk1002' AS check_code,
    'warning' AS check_level,
    'fk uses nullable columns' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', format('%I', c.conname),
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'relation_att_names', rel_att_names,
        'check', json_build_object(
            'check_code', 'fk1002',
            'parent_check_code', null,
            'check_name', 'fk uses nullable columns',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'constraint',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM (
    SELECT
        oid,
        conname,
        conrelid,
        confrelid,
        array_agg (rel_att_name order by att_order) as rel_att_names
    FROM (
        SELECT
            cfk.oid,
            cfk.conname,
            cfk.conrelid,
            cfk.confrelid,
            cfk_conkey.conkey_order AS att_order,
            rel_att.attname AS rel_att_name
        FROM pg_catalog.pg_constraint AS cfk
            CROSS JOIN LATERAL UNNEST(cfk.conkey) WITH ORDINALITY AS cfk_conkey(conkey_number, conkey_order)
            LEFT JOIN pg_catalog.pg_attribute AS rel_att
                ON rel_att.attrelid = cfk.conrelid AND rel_att.attnum = cfk_conkey.conkey_number
        WHERE cfk.contype IN ('f') AND cfk.confmatchtype NOT IN ('f') AND NOT rel_att.attnotnull
    ) AS ca
    GROUP BY 1, 2, 3, 4
) AS c
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
