-- minimal PG 15
-- PG 15 - pg_catalog.pg_index.indnullsnotdistinct)

WITH
    -- configure
    conf AS (
        SELECT
            'ru' AS conf_language_code,     -- null or value like 'en', 'ru'
            true AS enable_check_no1001,    -- check no unique key
            false AS enable_check_no1002    -- check no primary key constraint
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
    		('no1002', 'no1001', 'no primary key constraint', 'error')
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
    		('no1002', 'ru', 'У отношения нет ограничения primary key.')
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
    	    -- exclude system schemas
			(
			    nspname IN ('information_schema')
			-- postgresql specific
                OR nspname IN ('pg_catalog')
                OR nspname LIKE 'pg_toast%'
			)
    ),
    filtered_class_list AS (
    	SELECT
    		c.*,
    		concat(n.nspname,'.', c.relname) AS class_name
    	FROM pg_catalog.pg_class c
            LEFT JOIN pg_catalog.pg_namespace AS n ON c.relnamespace = n.oid
    	WHERE
			relnamespace NOT IN (SELECT excluded_schema_oid FROM excluded_schema_list)
    ),
    -- no1001 - no unique key
    check_no1001 AS (
        SELECT
            t.oid AS object_id,
            t.class_name AS object_name,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', t.oid,
                'object_name', t.class_name,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_class_list AS t
            LEFT JOIN check_list ch ON ch.check_code = 'no1001'
        WHERE
        	(SELECT enable_check_no1001 FROM conf)
        	AND t.relkind IN ('r')
            -- no constraint PK [test - public.no1001_1]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace AND c.contype IN ('p'))
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
    -- no1002 -
    check_no1002 AS (
        SELECT
            t.oid AS object_id,
            t.class_name AS object_name,
            ch.check_code,
            ch.check_level,
            ch.check_name,
            json_build_object(
                'object_id', t.oid,
                'object_name', t.class_name,
                'check', ch.*
            ) AS check_result_json
        FROM filtered_class_list AS t
            LEFT JOIN check_list ch ON ch.check_code = 'no1002'
        WHERE
        	(SELECT enable_check_no1002 FROM conf)
            -- not in parent check
            AND NOT ((SELECT enable_check_no1001 FROM conf) AND (t.oid IN (SELECT object_id FROM check_no1001)))
        	AND t.relkind IN ('r')
            -- constraint PK [test - public.no1001_1]
            AND NOT EXISTS (SELECT * FROM pg_catalog.pg_constraint AS c
                WHERE t.oid = c.conrelid AND t.relnamespace = c.connamespace
                    AND c.contype IN ('p'))
    )
SELECT * FROM (
    SELECT * FROM check_no1001
    UNION ALL
    SELECT * FROM check_no1002
) AS t
ORDER BY check_code, object_name;

