WITH
    -- configure
    conf AS (
        SELECT
            'ru'  AS conf_language_code,     -- null or value like 'en', 'ru' (see check_description)
            true  AS enable_check_no1001,    -- [error] check no unique key
            true  AS enable_check_no1002,    -- [error] check no primary key constraint
            true  AS enable_check_fk1001,    -- [error] check fk uses mismatched types
            false AS enable_check_fk1002,    -- [warning] check fk uses nullable columns
            false AS enable_check_fk1007,    -- [notice] not involved in foreign keys
            true  AS enable_check_c1001,     -- [warning] constraint not validated
            true  AS enable_check_i1001,     -- [warning] similar indexes
            true  AS enable_check_i1002,     -- [error] index has bad signs
            true  AS enable_check_i1003,     -- [warning] similar indexes unique and not unique
            false AS enable_check_i1005      -- [notice] similar indexes (roughly)
    ),
    --
    check_level_list AS (
        SELECT
            check_level
        FROM
            (VALUES
                ('critical'),
                ('error'),
                ('warning'),
                ('notice')
            ) AS t(check_level)
    ),
    -- checks based on system catalog info
    check_based_on_system_catalog AS (
        SELECT
            t.check_code,
            t.parent_check_code,
            t.check_name,
            t.check_level,
            'system catalog' AS check_source_name
        FROM
            (VALUES
                ('no1001', null, 'no unique key', 'error'),
                ('no1002', 'no1001', 'no primary key constraint', 'error'),
                ('fk1001', null, 'fk uses mismatched types', 'error'),
                ('fk1002', null, 'fk uses nullable columns', 'warning'),
                ('fk1007', null, 'not involved in foreign keys', 'notice'),
                ('c1001',  null, 'constraint not validated', 'warning'),
                ('i1001',  null, 'similar indexes', 'warning'),
                ('i1002',  null, 'index has bad signs', 'error'),
                ('i1003',  null, 'similar indexes unique and not unique', 'warning'),
                ('i1005',  null, 'similar indexes (roughly)', 'notice')
            ) AS t(check_code, parent_check_code, check_name, check_level)
            INNER JOIN check_level_list AS cll ON cll.check_level = t.check_level
    ),
    -- description for checks
    check_description AS (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY description_check_code ORDER BY description_language_code ASC NULLS LAST)
                AS description_check_code_row_num,
            *
        FROM
            (VALUES
                ('no1001', null, 'Relation has no unique key.'),
                ('no1001', 'ru', 'У отношения нет уникального ключа (набора полей). Это может создавать проблемы при удалении записей, при логической репликации и др.'),
                ('no1002', null, 'Relation has no primary key constraint.'),
                ('no1002', 'ru', 'У отношения нет ограничения primary key.'),
                ('fk1001', null, 'Foreign key uses columns with mismatched types.'),
                ('fk1001', 'ru', 'Внешний ключ использует колонки с несовпадающими типами.'),
                ('fk1002', null, 'Foreign key uses nullable columns.'),
                ('fk1002', 'ru', 'Внешний ключ использует колонки, допускающие значение NULL.'),
                ('fk1007', null, 'Relation is not involved in foreign keys.'),
                ('fk1007', 'ru', 'Отношение не используется во внешних ключах (возможно оно больше не нужно).'),
                ('c1001',  null, 'Constraint was not validated for all data.'),
                ('c1001',  'ru', 'Ограничение не проверено для всех данных (возможно присутствуют записи, нарушающие ограничение).'),
                ('i1001',  null, 'Indexes are very similar.'),
                ('i1001',  'ru', 'Индексы очень похожи (возможно совпадают).'),
                ('i1002',  null, 'Index has bad signs.'),
                ('i1002',  'ru', 'Индекс имеет признаки проблем.'),
                ('i1003',  null, 'Unique and not unique indexes are very similar.'),
                ('i1003',  'ru', 'Уникальный и не уникальный индексы очень похожи (возможно не уникальный лишний).'),
                ('i1005',  null, 'Indexes are roughly similar.'),
                ('i1005',  'ru', 'Индексы похожи по набору полей (грубое сравнение).')
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
            -- unique index with all not nullable columns and not partial [test - public.no1001_4]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                WHERE t.oid = i.indrelid AND i.indisunique AND (i.indpred IS NULL)
                    AND NOT EXISTS (SELECT * FROM pg_catalog.pg_attribute AS a
                        WHERE a.attrelid = i.indrelid AND NOT a.attnotnull
                            AND a.attnum = ANY ((string_to_array(indkey::text, ' ')::int2[])[1:indnkeyatts]))
                )
            -- UNIQUE NULLS NOT DISTINCT
            -- (used `pg_catalog.pg_index.indnullsnotdistinct`, see https://www.postgresql.org/docs/15/release-15.html)
            AND CASE
                WHEN (SELECT current_setting('server_version_num')::integer < 150000) THEN true
                ELSE
                    -- unique index with NULLS NOT DISTINCT and not partial [test - public.no1001_8]
                    NOT EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                        WHERE t.oid = i.indrelid AND i.indisunique AND (i.indpred IS NULL)
                            -- for support PostgreSQL 12..14
                            AND COALESCE((to_jsonb(i.*) -> 'indnullsnotdistinct')::boolean, false))
                    -- no constraint UNIQUE with NULLS NOT DISTINCT [test - public.no1001_7]
                    AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                        WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('u')
                            AND EXISTS (SELECT * FROM pg_catalog.pg_index AS i
                                WHERE i.indexrelid = c.conindid
                                    -- for support PostgreSQL 12..14
                                    AND COALESCE((to_jsonb(i.*) -> 'indnullsnotdistinct')::boolean, false))
                        )
                END
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
    ),
    -- fk1007 - not involved in foreign keys
    check_fk1007 AS (
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
            LEFT JOIN check_list ch ON ch.check_code = 'fk1007'
        WHERE
            (SELECT enable_check_fk1007 FROM conf)
            AND relkind IN ('r')
            AND t.oid NOT IN (SELECT conrelid FROM filtered_fk_list)
            AND t.oid NOT IN (SELECT confrelid FROM filtered_fk_list)
    ),
    -- filtered constraint list (minimal)
    filtered_c_list AS (
        SELECT
            c.oid,
            c.contype,
            c.conname,
            c.conrelid,
            c.confrelid,
            c.conkey,
            c.confkey,
            c.convalidated
        FROM pg_catalog.pg_constraint AS c
        WHERE
            c.conrelid IN (SELECT oid FROM filtered_class_list WHERE relkind IN ('r'))
    ),
    -- c1001 - constraint not validated
    check_c1001 AS (
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
                'constraint_type', c.contype,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_c_list AS c
            INNER JOIN filtered_class_list AS t
                ON t.oid = c.conrelid AND c.contype IN ('c', 'f') AND (NOT c.convalidated)
            LEFT JOIN check_list ch ON ch.check_code = 'c1001'
        WHERE
            (SELECT enable_check_c1001 FROM conf)
    ),
    -- filtered and extended index list
    filtered_index_list AS (
        SELECT
            ic.oid,
            ic.class_name,
            ic.relam,
            ic.relnatts,
            i.*,
            pg_get_indexdef(ic.oid) AS object_definition,
            -- simplification of definition
            regexp_replace( -- ' DESC,'
            regexp_replace( -- ' DESC\)'
            regexp_replace( -- ' NULLS LAST,'
            regexp_replace( -- ' NULLS LAST\)'
            regexp_replace( -- ' NULLS FIRST,'
            regexp_replace( -- ' NULLS FIRST\)'
            regexp_replace( -- ' INDEX .* ON '
            		pg_get_indexdef(ic.oid), ' INDEX .* ON ', ' INDEX ON '),
            		' NULLS FIRST\)', ')'),
            		' NULLS FIRST,', ','),
            		' NULLS LAST\)', ')'),
            		' NULLS LAST,', ','),
            		' DESC\)', ')'),
            		' DESC,', ',')
            	 AS simplified_object_definition,
            (SELECT array_agg(c.conname) FROM pg_catalog.pg_constraint AS c WHERE c.conindid = ic.oid)
                AS used_in_constraint
        FROM pg_catalog.pg_index AS i
            INNER JOIN filtered_class_list ic ON i.indexrelid = ic.oid
    ),
    -- i1001 - similar indexes
    check_i1001 AS (
        SELECT
            i.oid AS object_id,
            i.class_name AS object_name,
            'index' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', i.oid,
                'object_name', i.class_name,
                'object_type', 'index',
                'relation_name', t.class_name,
                'similar_index_name', si.class_name,
                'object_definition', i.object_definition,
                'simplified_object_definition', i.simplified_object_definition,
                'similar_index_definition', si.object_definition,
                'index_used_in_constraint', i.used_in_constraint,
                'similar_index_used_in_constraint', si.used_in_constraint,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_index_list AS i
            INNER JOIN filtered_class_list AS t ON i.indrelid = t.oid
            INNER JOIN filtered_index_list AS si ON i.oid < si.oid AND i.indrelid = si.indrelid AND i.relam = si.relam
                AND i.relnatts = si.relnatts AND i.indnkeyatts = si.indnkeyatts
                AND i.simplified_object_definition = si.simplified_object_definition
            LEFT JOIN check_list ch ON ch.check_code = 'i1001'
        WHERE
            (SELECT enable_check_i1001 FROM conf)
    ),
    --
    index_bad_signs AS (
        SELECT oid, array_agg(value) AS bad_signs FROM (
            SELECT oid, 'not valid' AS value FROM filtered_index_list WHERE indisvalid IS NOT TRUE
            UNION ALL
            SELECT oid, 'not ready' AS value FROM filtered_index_list WHERE indisready IS NOT TRUE
        ) AS t
        GROUP BY oid
    ),
    -- i1002 - index has bad signs
    check_i1002 AS (
        SELECT
            i.oid AS object_id,
            i.class_name AS object_name,
            'index' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', i.oid,
                'object_name', i.class_name,
                'object_type', 'index',
                'relation_name', t.class_name,
                'bad_signs', ibs.bad_signs,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_index_list AS i
            INNER JOIN filtered_class_list AS t ON i.indrelid = t.oid
            INNER JOIN index_bad_signs AS ibs ON i.oid = ibs.oid
            LEFT JOIN check_list ch ON ch.check_code = 'i1002'
        WHERE
            (SELECT enable_check_i1002 FROM conf)
    ),
    -- i1003 - similar indexes unique and not unique
    check_i1003 AS (
        SELECT
            ui.oid AS object_id,
            ui.class_name AS object_name,
            'index' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', ui.oid,
                'object_name', ui.class_name,
                'object_type', 'index',
                'relation_name', t.class_name,
                'similar_index_name', nui.class_name,
                'object_definition', ui.object_definition,
                'simplified_object_definition', ui.simplified_object_definition,
                'similar_index_definition', nui.object_definition,
                'index_used_in_constraint', ui.used_in_constraint,
                'similar_index_used_in_constraint', nui.used_in_constraint,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_index_list AS ui
            INNER JOIN filtered_class_list AS t ON ui.indrelid = t.oid
            INNER JOIN filtered_index_list AS nui ON ui.indrelid = nui.indrelid AND ui.relam = nui.relam
                AND ui.indisunique AND NOT nui.indisunique
                AND ui.relnatts = nui.relnatts AND ui.indnkeyatts = nui.indnkeyatts
                AND replace(ui.simplified_object_definition, ' UNIQUE ', ' ') = nui.simplified_object_definition
            LEFT JOIN check_list ch ON ch.check_code = 'i1003'
        WHERE
            (SELECT enable_check_i1003 FROM conf)
    ),
    -- filtered and extended index list - roughly
    index_definition_roughly_list AS (
        SELECT
            filtered_index_list.*,
            -- simplification of definition
            replace(        -- ' UNIQUE '
            regexp_replace( -- ' INCLUDE'
            regexp_replace( -- ' WHERE'
            		simplified_object_definition, ' WHERE .*', ''),
            		' INCLUDE .*', ''),
                    ' UNIQUE ', ' ')
            	 AS simplified_object_definition_roughly
        FROM filtered_index_list
    ),
    -- i1005 - similar indexes (roughly)
    check_i1005 AS (
        SELECT
            i.oid AS object_id,
            i.class_name AS object_name,
            'index' AS object_type,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', i.oid,
                'object_name', i.class_name,
                'object_type', 'index',
                'relation_name', t.class_name,
                'similar_index_name', si.class_name,
                'object_definition', i.object_definition,
                'simplified_object_definition_roughly', i.simplified_object_definition_roughly,
                'similar_index_definition', si.object_definition,
                'index_used_in_constraint', i.used_in_constraint,
                'similar_index_used_in_constraint', si.used_in_constraint,
                'check', ch.*
            ) AS check_result_json
        FROM index_definition_roughly_list AS i
            INNER JOIN filtered_class_list AS t ON i.indrelid = t.oid
            INNER JOIN index_definition_roughly_list AS si ON i.oid < si.oid AND i.indrelid = si.indrelid
                AND i.relam = si.relam
                AND i.simplified_object_definition_roughly = si.simplified_object_definition_roughly
            LEFT JOIN check_list ch ON ch.check_code = 'i1005'
        WHERE
            (SELECT enable_check_i1005 FROM conf)
    )
SELECT object_id, object_name, object_type, check_code, check_level, check_name, check_result_json FROM (
    SELECT * FROM check_no1001 -- no1001 - no unique key
    UNION ALL
    SELECT * FROM check_no1002 -- no1002 - no primary key constraint
    UNION ALL
    SELECT * FROM check_fk1001 -- fk1001 - fk uses mismatched types
    UNION ALL
    SELECT * FROM check_fk1002 -- fk1002 - fk uses nullable columns
    UNION ALL
    SELECT * FROM check_fk1007 -- fk1007 - not involved in foreign keys
    UNION ALL
    SELECT * FROM check_c1001  -- c1001 - constraint not validated
    UNION ALL
    SELECT * FROM check_i1001  -- i1001 - similar indexes
    UNION ALL
    SELECT * FROM check_i1002  -- i1002 - index has bad signs
    UNION ALL
    SELECT * FROM check_i1003  -- i1003 - similar indexes unique and not unique
    UNION ALL
    SELECT * FROM check_i1005  -- i1005 - similar indexes (roughly)
) AS t
-- result filter (for error suppression)
-- >>> WHERE
ORDER BY check_level, check_code, object_name
;
