-- fk1001 - fk uses mismatched types
SELECT
    c.oid AS object_id,
    format('%I', c.conname) AS object_name,
    'constraint' AS object_type,
    'fk1001' AS check_code,
    'error' AS check_level,
    'fk uses mismatched types' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', format('%I', c.conname),
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'relation_att_names', rel_att_names,
        'foreign_relation_name', concat(format('%I', nf.nspname), '.',  format('%I', tf.relname)),
        'foreign_relation_att_names', frel_att_names,
        'check', json_build_object(
            'check_code', 'fk1001',
            'parent_check_code', null,
            'check_name', 'fk uses mismatched types',
            'check_level', 'error',
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
        array_agg (rel_att_name order by att_order) as rel_att_names,
        array_agg (frel_att_name order by att_order) as frel_att_names
    FROM (
        SELECT
            cfk.oid,
            cfk.conname,
            cfk.conrelid,
            cfk.confrelid,
            cfk_conkey.conkey_order AS att_order,
            rel_att.attname AS rel_att_name,
            rel_att.atttypid AS rel_att_type_id,
            rel_att.atttypmod AS rel_att_type_mod,
            frel_att.attname AS frel_att_name,
            frel_att.atttypid AS frel_att_type_id,
            frel_att.atttypmod AS frel_att_type_mod
        FROM pg_catalog.pg_constraint AS cfk
            CROSS JOIN LATERAL UNNEST(cfk.conkey) WITH ORDINALITY AS cfk_conkey(conkey_number, conkey_order)
            LEFT JOIN LATERAL UNNEST(cfk.confkey) WITH ORDINALITY AS cfk_confkey(confkey_number, confkey_order)
                ON cfk_conkey.conkey_order = cfk_confkey.confkey_order
            LEFT JOIN pg_catalog.pg_attribute AS rel_att
                ON rel_att.attrelid = cfk.conrelid AND rel_att.attnum = cfk_conkey.conkey_number
            LEFT JOIN pg_catalog.pg_attribute AS frel_att
                ON frel_att.attrelid = cfk.confrelid AND frel_att.attnum = cfk_confkey.confkey_number
        WHERE cfk.contype IN ('f')
    ) AS ca
    WHERE
        ((rel_att_type_id <> frel_att_type_id) OR (rel_att_type_mod <> frel_att_type_mod))
    GROUP BY 1, 2, 3, 4
) AS c
    INNER JOIN pg_catalog.pg_class AS t ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n ON t.relnamespace = n.oid
    INNER JOIN pg_catalog.pg_class AS tf ON tf.oid = c.confrelid
    INNER JOIN pg_catalog.pg_namespace AS nf ON tf.relnamespace = nf.oid