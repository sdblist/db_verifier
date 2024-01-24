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



## Alternative description

* \[RU] [`README.ru.md`](README.ru.md)
