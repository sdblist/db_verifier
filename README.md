# db_verifier
PostgreSQL database verifier.

The script to check the database structure for errors or non-recommended practices.

The script consists of a set of checks that access the system catalog tables and do not require access to data in
user tables.

The current version is applicable to PostgreSQL 12 and later. Tested in versions PostgreSQL 15.5.

## Project structure

* [`db_verifier.sql`](db_verifier.sql) - script, checks and displays a list of errors/warnings/recommendations with comments
* `tests` - directory with DDL/DML scripts that are used to debug [`db_verifier.sql`](db_verifier.sql) and demonstrate errors

## Check list

| code   | parent_code | name                                  | level    | default state | description                                        |
|:-------|:------------|:--------------------------------------|:---------|:--------------|:---------------------------------------------------|
| no1001 |             | no unique key                         | error    | enable        | Relation has no unique key.                        |
| no1002 | no1001      | no primary key constraint             | error    | enable        | Relation has no primary key constraint.            |                   
| fk1001 |             | fk uses mismatched types              | error    | enable        | Foreign key uses columns with mismatched types.    |   
| fk1002 |             | fk uses nullable columns              | warning  | disable       | Foreign key uses nullable columns.                 |
| fk1007 |             | not involved in foreign keys          | notice   | disable       | Relation is not involved in foreign keys.          |
| c1001  |             | constraint not validated              | warning  | enable        | Constraint was not validated for all data.         |
| i1001  |             | similar indexes                       | warning  | enable        | Indexes are very similar.                          |
| i1002  |             | index has bad signs                   | error    | enable        | Index has bad signs.                               |
| i1003  |             | similar indexes unique and not unique | warning  | enable        | Unique and not unique indexes are very similar.    |
| i1005  |             | similar indexes (roughly)             | notice   | disable       | Indexes are roughly similar.                       |
| s1010  |             | less 5% unused sequence values        | critical | enable        | The sequence has less than 5% unused values left.  |
| s1011  | s1010       | less 10% unused sequence values       | error    | enable        | The sequence has less than 10% unused values left. |
| s1012  | s1011       | less 20% unused sequence values       | warning  | enable        | The sequence has less than 20% unused values left. |

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
sed -i "/>>> WHERE/ r examples/where.sql" db_verifier.sql
```

### Cumulative score (single value)

An implementation option for obtaining an aggregated score.
Let's associate each result line with a numeric value based on `check_level`, example in the file
`examples/cumulative_score.sql`.

```shell
cat examples/cumulative_score.sql
SELECT
    COALESCE(SUM(cumulative_score_value), 0) AS cumulative_score
FROM (
    VALUES
        ('critical', 55),
        ('error',    25),
        ('warning',  12),
        ('notice',    3)
    ) AS t(check_level, cumulative_score_value)
    INNER JOIN (
-- >>> db_verifier
) AS r ON t.check_level = r.check_level
;
```

Let's combine the scripts, the result in `examples/cumulative_score.sql`.

```shell
sed -i "/^;$/d" db_verifier.sql
sed -i "/>>> db_verifier/ r db_verifier.sql" ./examples/cumulative_score.sql
```

## Description of the test results table

| column name       | description                                                          |
|:------------------|:---------------------------------------------------------------------|
| object_id         | id (oid) of the object in the corresponding system table             |
| object_name       | name of the object, in some cases with a schema                      |    
| object_type       | type of object being checked (relation, constraint, index, sequence) |  
| check_code        | check code (see table above)                                         |  
| check_level       | level (see table above)                                              |  
| check_name        | check name (see table above)                                         |  
| check_result_json | detailed test results in json format                                 |  
 

## Alternative description

* \[RU] [`README.ru.md`](README.ru.md)

## Python Wrapper
There is a Python wrapper implemented for the SQL checks in this project.
It allows running the DB verifier as a standalone command or as a part of the automated testing process.

Until it is not published to PyPi, please build from sources and install as a wheel package.
The following instructions will be replaced with simply: `pip install db_verifier` after publishing.

### Building Python wrapper with Poetry

The following instructions are tested on Ubuntu 20.04.

Please adapt to your development environment accordingly. 

The project is built with Poetry (https://python-poetry.org/docs/pyproject/).
To install Poetry use the instructions on its site:
https://python-poetry.org/docs/#installing-with-the-official-installer

This is a possible one-line installation using their official installation script:
```shell
curl -sSL https://install.python-poetry.org | python3 -
```

Initializing and building the project:
```shell
cd db_verifier
poetry init
poetry build
```

As a result it will create a distribution package in db_verifier/dist dir.

## Install DB Verifier Command

You can install DB Verifier python wrapper into your Python virtual environment or any other way you prefer.

Installing from PyPi (not published yet):
```shell
pip install db_verifier
```

Installing from pre-built wheel package:
```shell
pip install db_verifier/dist/db_verifier-0.1.0-py3-none-any.whl
```

After the package is installed you can use db_verifier command.

## Using as a standalone command

```shell
PGUSER=user PGPASSWORD=pass db_verifier --connection=postgresql://my_host:5432/my_db
```
By default, it prints the report in human-readable text format to stdout and exits with the following OS error codes:
- 0: no errors detected (can be configured to fail on warnings also);
- 1: errors detected;
- 2: connection problem or any other error unrelated to the problems in the DB structure.

Verify DB and print report in CSV to stdout:
```shell
PGUSER=user PGPASSWORD=pass db_verifier --connection=postgresql://my_host:5432/my_db --format=csv
```

Verify DB and print report in JSON-lines stdout (each line is a JSON object):
```shell
PGUSER=user PGPASSWORD=pass db_verifier --connection=postgresql://my_host:5432/my_db --format=json
```

## Using in Python unit tests

Here is an example of how DB Verifier can be integrated into a Django automated testing pipeline.

Django has a built-in ability to generate a test database based on the configured models and migrations and 
use it for the tests.

DB Verifier can be included as one of the tests.

For example in a Django project with pytest tests the following works good:
```python
import pytest
from db_verifier import verify_and_print_txt
from django.db import connection


@pytest.mark.django_db(transaction=True)
def test_db_structure():
    verify_and_print_txt(connection, fail_on_warnings=True)
```

The test is marked with "django_db". \
This means an empty test DB will be initialized based on the 
Django ORM configuration. \
Next "verify_and_print_txt" is used on the Django's connection (psycopg Connection object). \
This function runs the SQL checks and prints error to stdout in human-readable form similar to how linters and
other common utilities do. \
In the end it raises an exception if there were errors/warnings found, and it will be a failed test in the logs.

This way it can be included into a CI process of a typical Django project.

It can be used the similar way to integrate with other types of Python projects.

# Setting-up dev environment for Python wrapper

See above - building the project with Poetry.

The project was developed with the following scheme:
- dependencies are to be started in docker;
- python code is started on the host machine in a virtualenv managed by Poetry.

To initialize the project:
```shell
git clone ...
cd db_verifier
poetry init
```

Copy `.env.default` to `.env` and change the dev config if needed.\


To activate virtualenv:
```shell
poetry shell
```

To run the tests:

Start dependencies in docker in one terminal session:
```shell
poetry shell
make start_deps
```

Run the tests in IDE or in the 2nd terminal session:
```shell
poetry shell
make run_tests
```

Auto-format code:
```
poetry shell
make black
```

Check code-style:
```
poetry shell
make check_lint
```