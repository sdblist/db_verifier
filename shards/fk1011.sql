-- fk1011 - FK have common attributes
SELECT
    c.oid AS object_id,
    c.formatted_constraint_name AS object_name,
    'constraint' AS object_type,
    'fk1011' AS check_code,
    'warning' AS check_level,
    'FK have common attributes' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', c.formatted_constraint_name,
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'relation_att_names', c.rel_att_names,
        'foreign_relation_name', concat(format('%I', nf.nspname), '.',  format('%I', tf.relname)),
        'foreign_relation_att_names', c.frel_att_names,
        'similar_constraint_name', cf.formatted_constraint_name,
        'check', json_build_object(
            'check_code', 'fk1011',
            'parent_check_code', 'fk1010',
            'check_name', 'FK have common attributes',
            'check_level', 'warning',
            'check_version', 1,
            'object_type', 'constraint',
            'check_source_name', 'system catalog'
            )
    ) AS check_result_json
FROM (
        SELECT
            cfk.oid,
            format('%I', cfk.conname) AS formatted_constraint_name,
            cfk.conrelid,
            cfk.confrelid,
            array_agg (rel_att.attname order by cfk_conkey.conkey_order) AS rel_att_names,
            array_agg (frel_att.attname order by cfk_conkey.conkey_order) AS frel_att_names
        FROM pg_catalog.pg_constraint AS cfk
            CROSS JOIN LATERAL UNNEST(cfk.conkey) WITH ORDINALITY AS cfk_conkey(conkey_number, conkey_order)
            LEFT JOIN LATERAL UNNEST(cfk.confkey) WITH ORDINALITY AS cfk_confkey(confkey_number, confkey_order)
                ON cfk_conkey.conkey_order = cfk_confkey.confkey_order
            LEFT JOIN pg_catalog.pg_attribute AS rel_att
                ON rel_att.attrelid = cfk.conrelid AND rel_att.attnum = cfk_conkey.conkey_number
            LEFT JOIN pg_catalog.pg_attribute AS frel_att
                ON frel_att.attrelid = cfk.confrelid AND frel_att.attnum = cfk_confkey.confkey_number
        WHERE
            cfk.contype IN ('f')
            AND rel_att.attnum >= 1
            AND frel_att.attnum >= 1
        GROUP BY 1, 2, 3, 4
        ) AS c
    INNER JOIN (
        SELECT
            cfk.oid,
            format('%I', cfk.conname) AS formatted_constraint_name,
            cfk.conrelid,
            cfk.confrelid,
            array_agg (rel_att.attname order by cfk_conkey.conkey_order) AS rel_att_names,
            array_agg (frel_att.attname order by cfk_conkey.conkey_order) AS frel_att_names
        FROM pg_catalog.pg_constraint AS cfk
            CROSS JOIN LATERAL UNNEST(cfk.conkey) WITH ORDINALITY AS cfk_conkey(conkey_number, conkey_order)
            LEFT JOIN LATERAL UNNEST(cfk.confkey) WITH ORDINALITY AS cfk_confkey(confkey_number, confkey_order)
                ON cfk_conkey.conkey_order = cfk_confkey.confkey_order
            LEFT JOIN pg_catalog.pg_attribute AS rel_att
                ON rel_att.attrelid = cfk.conrelid AND rel_att.attnum = cfk_conkey.conkey_number
            LEFT JOIN pg_catalog.pg_attribute AS frel_att
                ON frel_att.attrelid = cfk.confrelid AND frel_att.attnum = cfk_confkey.confkey_number
        WHERE
            cfk.contype IN ('f')
            AND rel_att.attnum >= 1
            AND frel_att.attnum >= 1
        GROUP BY 1, 2, 3, 4
        ) AS cf
        ON c.oid < cf.oid AND c.conrelid = cf.conrelid
            AND c.confrelid = cf.confrelid AND (c.rel_att_names && cf.rel_att_names)
    INNER JOIN pg_catalog.pg_class AS t
        ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n
        ON t.relnamespace = n.oid
    INNER JOIN pg_catalog.pg_class AS tf
        ON tf.oid = c.confrelid
    INNER JOIN pg_catalog.pg_namespace AS nf
        ON tf.relnamespace = nf.oid
