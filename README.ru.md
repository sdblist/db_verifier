# db_verifier

Скрипт для проверки структуры БД на наличие ошибок или нерекомендуемых практик.

Скрипт состоит из набора проверок, которые обращаются к таблицам системного каталога и не требуют обращения к данным в 
пользовательских таблицах.

Актуальная версия применима к PostgreSQL 15 и новее. Протестировано в версии PostgreSQL 15.5.

(используется `pg_catalog.pg_index.indnullsnotdistinct`, см.`UNIQUE NULLS NOT DISTINCT` https://postgrespro.ru/docs/postgresql/15/release-15)

## Структура проекта

* [`db_verifier.sql`](db_verifier.sql) - скрипт, проверяет и выводит список ошибок/предупреждений/рекомендаций с комментариями
* `tests` - каталог с DDL/DML скриптами, которые используются для отладки db_verifier и демонстрации ошибок

## Перечень проверок

 code     | parent_code    | name                      | level     | default state | description
:---------|:---------------|:--------------------------|:----------|:--------------|:-------------
no1001    |                | no unique key             | error     | enable        | У отношения нет уникального ключа (набора полей). Это может создавать проблемы при удалении записей, при логической репликации и др.
no1002    | no1001         | no primary key constraint | error     | enable        | У отношения нет ограничения primary key.                    
fk1001    |                | fk uses mismatched types  | error     | enable        | Внешний ключ использует колонки с несовпадающими типами.    
fk1002    |                | fk uses nullable columns  | warning   | disable       | Внешний ключ использует колонки, допускающие значение NULL. 

## Пример использования

Пример использования скрипта для проверки метаданных базы с использованием docker контейнера с PostgreSQL 15.

Выгрузим схему базы данных в формате sql с помощью `pg_dump`, указав необходимые параметры для соединения.
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

Запустим контейнер с PostgreSQL 15, порт `5444` локального интерфейса будет проброшен в контейнер.
```shell
docker container run \
  -p 127.0.0.1:5444:5432 \
  --name db_verifier \
  --env POSTGRES_USER=user_name \
  --env POSTGRES_PASSWORD=user_password \
  --env POSTGRES_DB=db_verifier \
  --detach postgres:15-alpine
```

Подключимся к контейнеру на порт `5444` локального интерфейса консольным клиентом `psql`. 

```shell
psql \
  --host=localhost \
  --port=5444 \
  --username=user_name \
  --dbname=db_verifier
```

Настроим вывод данных в консольном клиенте и выполним скрипт [`db_verifier.sql`](db_verifier.sql).

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

Останавливаем и удаляем контейнер.

```shell
docker stop db_verifier
docker container remove db_verifier
```

## Другие описания проекта

* \[EN] [`README.md`](README.md)