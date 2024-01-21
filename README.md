# db_verifier
PostgreSQL database verifier.

The current version is applicable to PostgreSQL 15 and older.

## Project structure

* [`db_verifier.sql`](db_verifier.sql) - script, checks and displays a list of errors/warnings/recommendations with comments
* `tests` - directory with DDL/DML scripts that are used to debug [`db_verifier.sql`](db_verifier.sql) and demonstrate errors

## Check list

check_code| parent_check_code | check_name                | check_level | description
:---------|:------------------|:--------------------------|:------------|:-------------
no1001    |                   | no unique key             | error       | Relation has no unique key.
no1002    | no1001            | no primary key constraint | error       | Relation has no primary key constraint.
fk1001    |                   | fk use mismatched types   | error       | Foreign key uses columns with mismatched types.

## Alternative description

* \[RU] [`README.ru.md`](README.ru.md)
