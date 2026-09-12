-- fk1014 - duplicate FK attributes in source relation
SELECT
    c.oid AS object_id,
    c.formatted_constraint_name AS object_name,
    'constraint' AS object_type,
    'fk1014' AS check_code,
    'error' AS check_level,
    'duplicate FK attributes in source relation' AS check_name,
    json_build_object(
        'object_id', c.oid,
        'object_name', c.formatted_constraint_name,
        'object_type', 'constraint',
        'relation_name', concat(format('%I', n.nspname), '.',  format('%I', t.relname)),
        'relation_att_name', c.rel_att_formatted_name,
        'foreign_relation_name', concat(format('%I', nf.nspname), '.',  format('%I', tf.relname)),
        'check', json_build_object(
            'check_code', 'fk1014',
            'check_name', 'duplicate FK attributes in source relation',
            'check_level', 'error',
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
            rel_att.attname AS rel_att_name,
            format('%I', rel_att.attname) AS rel_att_formatted_name
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
        GROUP BY 1, 2, 3, 4, 5, 6
        HAVING count(*) > 1
        ) AS c
    INNER JOIN pg_catalog.pg_class AS t
        ON t.oid = c.conrelid
    INNER JOIN pg_catalog.pg_namespace AS n
        ON t.relnamespace = n.oid
    INNER JOIN pg_catalog.pg_class AS tf
        ON tf.oid = c.confrelid
    INNER JOIN pg_catalog.pg_namespace AS nf
        ON tf.relnamespace = nf.oid
