# db_verifier
PostgreSQL database verifier.

The current version is applicable to PostgreSQL 15 and later. Tested in version PostgreSQL 15.5.

(used `pg_catalog.pg_index.indnullsnotdistinct`, see `UNIQUE NULLS NOT DISTINCT` https://www.postgresql.org/docs/15/release-15.html)

## Project structure

* [`db_verifier.sql`](db_verifier.sql) - script, checks and displays a list of errors/warnings/recommendations with comments
* `tests` - directory with DDL/DML scripts that are used to debug [`db_verifier.sql`](db_verifier.sql) and demonstrate errors

## Check list

 code     | parent_code    | name                      | level     | default state | description
:---------|:---------------|:--------------------------|:----------|:--------------|:-------------
no1001    |                | no unique key             | error     | enable        | Relation has no unique key.
no1002    | no1001         | no primary key constraint | error     | enable        | Relation has no primary key constraint.                    
fk1001    |                | fk uses mismatched types  | error     | enable        | Foreign key uses columns with mismatched types.    
fk1002    |                | fk uses nullable columns  | warning   | disable       | Foreign key uses nullable columns. 

## Пример использования

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


## Alternative description

* \[RU] [`README.ru.md`](README.ru.md)
