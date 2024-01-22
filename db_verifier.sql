-- minimal PG 15
-- PG 15 - pg_catalog.pg_index.indnullsnotdistinct

WITH
    -- configure
    conf AS (
        SELECT
            'ru' AS conf_language_code,     -- null or value like 'en', 'ru' (see check_description)
            true AS enable_check_no1001,    -- check no unique key
            true AS enable_check_no1002,    -- check no primary key constraint
            true AS enable_check_fk1001,    -- check fk uses mismatched types
            true AS enable_check_fk1002     -- check fk uses nullable columns
    ),
    -- checks based on system catalog info
    check_based_on_system_catalog AS (
        SELECT
            check_code,
            parent_check_code,
            check_name,
            check_level,
            'system catalog' AS check_source_name
        FROM (VALUES
            ('no1001', null, 'no unique key', 'error'),
            ('no1002', 'no1001', 'no primary key constraint', 'error'),
            ('fk1001', null, 'fk uses mismatched types', 'error'),
            ('fk1002', null, 'fk uses nullable columns', 'warning')
        ) AS t(check_code, parent_check_code, check_name, check_level)
    ),
    -- description for checks
    check_description AS (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY description_check_code ORDER BY description_language_code ASC NULLS LAST)
                AS description_check_code_row_num,
            *
        FROM (VALUES
            ('no1001', null, 'Relation has no unique key.'),
            ('no1001', 'ru', 'У отношения нет уникального ключа (набора полей). Это может создавать проблемы при удалении записей, при логической репликации и др.'),
            ('no1002', null, 'Relation has no primary key constraint.'),
            ('no1002', 'ru', 'У отношения нет ограничения primary key.'),
            ('fk1001', null, 'Foreign key uses columns with mismatched types.'),
            ('fk1001', 'ru', 'Внешний ключ использует колонки с несовпадающими типами.'),
            ('fk1002', null, 'Foreign key uses nullable columns.'),
            ('fk1002', 'ru', 'Внешний ключ использует колонки, допускающие значение NULL.')
        ) AS t(description_check_code, description_language_code, description_value)
        WHERE
            description_language_code IS NULL
            OR description_language_code IN (SELECT conf_language_code FROM conf)
    ),
    -- all checks with descriptions
    check_list AS (
        SELECT
            check_based_on_system_catalog.*,
            description_language_code,
            description_value
        FROM check_based_on_system_catalog
            LEFT JOIN check_description ON check_code = description_check_code AND description_check_code_row_num = 1
    ),
    excluded_schema_list AS (
        SELECT
            oid AS excluded_schema_oid,
            nspname AS excluded_schema_nspname
        FROM pg_catalog.pg_namespace
        WHERE
            (
                -- exclude system schemas
                nspname IN ('information_schema')
                -- postgresql specific
                OR nspname IN ('pg_catalog')
                OR nspname LIKE 'pg_toast%'
            )
    ),
    filtered_class_list AS (
        SELECT
            c.*,
            concat(n.nspname, '.',  c.relname) AS class_name
        FROM pg_catalog.pg_class AS c
            LEFT JOIN pg_catalog.pg_namespace AS n ON c.relnamespace = n.oid
        WHERE
            c.relnamespace NOT IN (SELECT excluded_schema_oid FROM excluded_schema_list)
    ),
    -- no1001 - no unique key
    check_no1001 AS (
        SELECT
            t.oid AS object_id,
            t.class_name AS object_name,
            'relation' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', t.oid,
                'object_name', t.class_name,
                'object_type', 'relation',
                'check', ch.*
            ) AS check_result_json
        FROM filtered_class_list AS t
            LEFT JOIN check_list ch ON ch.check_code = 'no1001'
        WHERE
            (SELECT enable_check_no1001 FROM conf)
            AND t.relkind IN ('r')
            -- no constraint PK [test - public.no1001_1]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('p')
                )
            -- no constraint UNIQUE with all not nullable columns [test - public.no1001_2]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('u')
                    AND NOT EXISTS (SELECT * FROM pg_catalog.pg_attribute AS a
                        WHERE a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey) AND NOT a.attnotnull)
                )
            -- no constraint UNIQUE with NULLS NOT DISTINCT [test - public.no1001_7]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('u')
                    AND EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                        WHERE i.indexrelid = c.conindid AND i.indnullsnotdistinct)
                )
            -- unique index with all not nullable columns and not partial [test - public.no1001_4]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                WHERE t.oid = i.indrelid AND i.indisunique AND (i.indpred IS NULL)
                    AND NOT EXISTS (SELECT * FROM pg_catalog.pg_attribute AS a
                        WHERE a.attrelid = i.indrelid AND NOT a.attnotnull
                            AND a.attnum = ANY ((string_to_array(indkey::text, ' ')::int2[])[1:indnkeyatts]))
                )
            -- unique index with NULLS NOT DISTINCT and not partial [test - public.no1001_8]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                WHERE t.oid = i.indrelid AND i.indisunique AND i.indnullsnotdistinct AND (i.indpred IS NULL)
                )
    ),
    -- no1002 - no primary key constraint
    check_no1002 AS (
        SELECT
            t.oid AS object_id,
            t.class_name AS object_name,
            'relation' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', t.oid,
                'object_name', t.class_name,
                'object_type', 'relation',
                'check', ch.*
            ) AS check_result_json
        FROM filtered_class_list AS t
            LEFT JOIN check_list ch ON ch.check_code = 'no1002'
        WHERE
            (SELECT enable_check_no1002 FROM conf)
            -- not in parent check
            AND NOT ((SELECT enable_check_no1001 FROM conf) AND (t.oid IN (SELECT object_id FROM check_no1001)))
            AND t.relkind IN ('r')
            -- no constraint PK
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('p')
                )
    ),
    -- filtered FK list (minimal)
    filtered_fk_list AS (
        SELECT
            c.oid,
            c.conname,
            c.conrelid,
            c.confrelid,
            c.conkey,
            c.confkey
        FROM pg_catalog.pg_constraint AS c
        WHERE
            c.contype IN ('f')
            AND c.conrelid IN (SELECT oid FROM filtered_class_list WHERE relkind IN ('r'))
            AND c.confrelid IN (SELECT oid FROM filtered_class_list WHERE relkind IN ('r'))
    ),
    -- filtered FK list with attribute
    filtered_fk_list_attribute AS (
        SELECT
            cfk.oid,
            cfk.conname,
            cfk.conrelid,
            cfk.confrelid,
            cfk_conkey.conkey_order AS att_order,
            cfk_conkey.conkey_number,
            cfk_confkey.confkey_number,
            rel_att.attname AS rel_att_name,
            rel_att.atttypid AS rel_att_type_id,
            rel_att.atttypmod AS rel_att_type_mod,
            rel_att.attnotnull AS rel_att_notnull,
            frel_att.attname AS frel_att_name,
            frel_att.atttypid AS frel_att_type_id,
            frel_att.atttypmod AS frel_att_type_mod,
            frel_att.attnotnull AS frel_att_notnull
        FROM filtered_fk_list AS cfk
            CROSS JOIN LATERAL UNNEST(cfk.conkey) WITH ORDINALITY AS cfk_conkey(conkey_number, conkey_order)
            LEFT JOIN LATERAL UNNEST(cfk.confkey) WITH ORDINALITY AS cfk_confkey(confkey_number, confkey_order)
                ON cfk_conkey.conkey_order = cfk_confkey.confkey_order
            LEFT JOIN pg_catalog.pg_attribute AS rel_att
                ON rel_att.attrelid = cfk.conrelid AND rel_att.attnum = cfk_conkey.conkey_number
            LEFT JOIN pg_catalog.pg_attribute AS frel_att
                ON frel_att.attrelid = cfk.confrelid AND frel_att.attnum = cfk_confkey.confkey_number
    ),
    -- fk1001 - fk uses mismatched types
    check_fk1001 AS (
        SELECT
            c.oid AS object_id,
            c.conname AS object_name,
            'constraint' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', c.oid,
                'object_name', c.conname,
                'object_type', 'constraint',
                'relation_name', t.class_name,
                'relation_att_names', c.rel_att_names,
                'foreign_relation_name', tf.class_name,
                'foreign_relation_att_names', c.frel_att_names,
                'check', ch.*
            ) AS check_result_json
        FROM (
            SELECT
                oid,
                conname,
                conrelid,
                confrelid,
                array_agg (rel_att_name order by att_order ) as rel_att_names,
                array_agg (frel_att_name order by att_order ) as frel_att_names
            FROM filtered_fk_list_attribute
            WHERE
                ((rel_att_type_id <> frel_att_type_id) OR (rel_att_type_mod <> frel_att_type_mod))
            GROUP BY 1, 2, 3, 4
        ) AS c
            INNER JOIN filtered_class_list AS t
                ON t.oid = c.conrelid
            INNER JOIN filtered_class_list AS tf
                ON tf.oid = c.confrelid
            LEFT JOIN check_list ch ON ch.check_code = 'fk1001'
        WHERE
            (SELECT enable_check_fk1001 FROM conf)
    ),
    -- fk1002 - fk uses nullable columns
    check_fk1002 AS (
        SELECT
            c.oid AS object_id,
            c.conname AS object_name,
            'constraint' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', c.oid,
                'object_name', c.conname,
                'object_type', 'constraint',
                'relation_name', t.class_name,
                'relation_att_names', c.rel_att_names,
                'check', ch.*
            ) AS check_result_json
        FROM (
            SELECT
                oid,
                conname,
                conrelid,
                confrelid,
                array_agg (rel_att_name order by att_order ) as rel_att_names
            FROM filtered_fk_list_attribute
            WHERE
                (NOT rel_att_notnull)
            GROUP BY 1, 2, 3, 4
        ) AS c
            INNER JOIN filtered_class_list AS t
                ON t.oid = c.conrelid
            INNER JOIN filtered_class_list AS tf
                ON tf.oid = c.confrelid
            LEFT JOIN check_list ch ON ch.check_code = 'fk1002'
        WHERE
            (SELECT enable_check_fk1002 FROM conf)
    )
SELECT object_id, object_name, object_type, check_code, check_level, check_name, check_result_json FROM (
    SELECT * FROM check_no1001
    UNION ALL
    SELECT * FROM check_no1002
    UNION ALL
    SELECT * FROM check_fk1001
    UNION ALL
    SELECT * FROM check_fk1002
) AS t
ORDER BY check_level, check_code, object_name;
