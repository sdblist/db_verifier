# db_verifier
PostgreSQL database verifier.

The current version is applicable to PostgreSQL 15 and later. Tested in version PostgreSQL 15.5.

(used `pg_catalog.pg_index.indnullsnotdistinct`, see `UNIQUE NULLS NOT DISTINCT` https://www.postgresql.org/docs/15/release-15.html)

## Project structure

* [`db_verifier.sql`](db_verifier.sql) - script, checks and displays a list of errors/warnings/recommendations with comments
* `tests` - directory with DDL/DML scripts that are used to debug [`db_verifier.sql`](db_verifier.sql) and demonstrate errors

## Check list

 code  | parent_code | name                         | level   | default state | description
:------|:------------|:-----------------------------|:--------|:--------------|:-------------
no1001 |             | no unique key                | error   | enable        | Relation has no unique key.
no1002 | no1001      | no primary key constraint    | error   | enable        | Relation has no primary key constraint.                    
fk1001 |             | fk uses mismatched types     | error   | enable        | Foreign key uses columns with mismatched types.    
fk1002 |             | fk uses nullable columns     | warning | disable       | Foreign key uses nullable columns.
fk1007 |             | not involved in foreign keys | notice  | disable       | Relation is not involved in foreign keys. 
c1001  |             | constraint not validated     | warning | enable        | Constraint was not validated for all data.
i1001  |             | similar indexes              | warning | enable        | Indexes are very similar.

## Usage example

An example of using a script to check database metadata using a docker container with PostgreSQL 15.

Let's dump the database schema in sql format using `pg_dump`, specifying the necessary parameters for the connection.

```bash
pg_dump \
  --host=database_host \
  --port=database_port \
  --username=user_name \
  --dbname=database_name \
  --schema-only \
  --format=plain \
  --file=database_schema.sql
```

Let's launch a container with PostgreSQL 15, port `5444` of the local interface will be forwarded to the container.

```shell
docker container run \
  -p 127.0.0.1:5444:5432 \
  --name db_verifier \
  --env POSTGRES_USER=user_name \
  --env POSTGRES_PASSWORD=user_password \
  --env POSTGRES_DB=db_verifier \
  --detach postgres:15-alpine
```

Let's connect to the container on port `5444` of the local interface using the `psql` console client.

```shell
psql \
  --host=localhost \
  --port=5444 \
  --username=user_name \
  --dbname=db_verifier
```

Let's set up data output in the `psql` and execute the [`db_verifier.sql`](db_verifier.sql).

```shell
db_verifier=# \pset format wrapped
Output format is wrapped.
db_verifier=# \pset columns 0
Target width is unset.
db_verifier=# \i db_verifier.sql
 object_id |     object_name      | object_type | check_code | check_level |        check_name        |            check_result_json
-----------+----------------------+-------------+------------+-------------+--------------------------+------------------------------------------
     16456 | fk1001_2_fk_fk1001_2 | constraint  | fk1001     | error       | fk uses mismatched types | {"object_id" : "16456", "object_name" : .
           |                      |             |            |             |                          |."fk1001_2_fk_fk1001_2", "object_type" : .
           |                      |             |            |             |                          |."constraint", "relation_name" : "public..
           |                      |             |            |             |                          |.fk1001_2_fk", "relation_att_names" : ["f.
           |                      |             |            |             |                          |.k1001_2_id"], "foreign_relation_name" : .
           |                      |             |            |             |                          |."public.fk1001_2", "foreign_relation_att.
           |                      |             |            |             |                          |._names" : ["id"], "check" : {"check_code.
           |                      |             |            |             |                          |.":"fk1001","parent_check_code":null,"che.
           |                      |             |            |             |                          |.ck_name":"fk uses mismatched types","che.
           |                      |             |            |             |                          |.ck_level":"error","check_source_name":"s.
           |                      |             |            |             |                          |.ystem catalog","description_language_cod.
           |                      |             |            |             |                          |.e":null,"description_value":"Foreign key.
           |                      |             |            |             |                          |. uses columns with mismatched types."}}
```

Stop and remove the container.

```shell
docker stop db_verifier
docker container remove db_verifier
```

## Examples of adaptation and integration into CI

### Switching localization of messages using bash command

Changing the message localization setting to `en`, attribute `conf_language_code`.

```shell
sed -i "/AS conf_language_code,/c\'en' AS conf_language_code," db_verifier.sql
```

### Explicitly enable/disable checks using bash command

Explicitly disabling the `i1001` check (similar indexes), the `enable_check_i1001` attribute.

```shell
sed -i "s/AS enable_check_i1001/AND false AS enable_check_i1001/" db_verifier.sql
```

```sql
-- before
    true AS enable_check_i1001      -- [warning] similar indexes
-- after
    true  AND false AS enable_check_i1001      -- [warning] similar indexes
```

Explicitly enabling the `fk1007` check (not involved in foreign keys), attribute `enable_check_fk1007`.

```shell
sed -i "s/AS enable_check_fk1007/OR true AS enable_check_fk1007/" db_verifier.sql
```

```sql
-- before
    false AS enable_check_fk1007,    -- [notice] not involved in foreign keys
-- after
    false OR true AS enable_check_fk1007,    -- [notice] not involved in foreign keys
```

### Filtering scan results

Filtering scan results is necessary to exclude false positives or to implement exclusion functionality
known errors (baseline, error suppression).
To do this, you can add a `WHERE` condition to the script at the stage of filtering the test results, the point for setting such
conditions are specified in the comment line `>>> WHERE`.

Example of conditions for filtering results (suppressing some errors).

```shell
cat examples/where.sql 
WHERE
NOT (check_code = 'fk1007' AND object_name = 'public.schema_migrations')
```

```shell
sed -i -e "/>>> WHERE/ r where.sql" db_verifier.sql
```

## Alternative description

* \[RU] [`README.ru.md`](README.ru.md)
