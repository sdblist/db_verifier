# db_verifier

Скрипт для проверки структуры БД на наличие ошибок или нерекомендуемых практик.

Скрипт состоит из набора проверок, которые обращаются к таблицам системного каталога и не требуют обращения к данным в 
пользовательских таблицах.

Актуальная версия применима к PostgreSQL 12 и новее. Протестировано в версии PostgreSQL 15.5.

## Структура проекта

* [`db_verifier.sql`](db_verifier.sql) - скрипт, проверяет и выводит список ошибок/предупреждений/рекомендаций с комментариями
* `tests` - каталог с DDL/DML скриптами, которые используются для отладки db_verifier и демонстрации ошибок

## Перечень проверок

| code   | parent_code | name                                     | level    | default state | description                                                                                                                          |
|:-------|:------------|:-----------------------------------------|:---------|:--------------|:-------------------------------------------------------------------------------------------------------------------------------------|
| no1001 |             | no unique key                            | error    | enable        | У отношения нет уникального ключа (набора полей). Это может создавать проблемы при удалении записей, при логической репликации и др. |
| no1002 | no1001      | no primary key constraint                | error    | enable        | У отношения нет ограничения primary key.                                                                                             |
| fk1001 |             | fk uses mismatched types                 | error    | enable        | Внешний ключ использует колонки с несовпадающими типами.                                                                             |
| fk1002 |             | fk uses nullable columns                 | warning  | disable       | Внешний ключ использует колонки, допускающие значение NULL.                                                                          |
| fk1007 |             | not involved in foreign keys             | notice   | disable       | Отношение не используется во внешних ключах (возможно оно больше не нужно).                                                          |
| fk1010 |             | similar FK                               | warning  | enable        | FK очень похожи (возможно совпадают).                                                                                                |
| fk1011 | fk1010      | FK have common attributes                | warning  | enable        | Между отношениями несколько FK, FK имеют общие атрибуты.                                                                             |
| c1001  |             | constraint not validated                 | warning  | enable        | Ограничение не проверено для всех данных (возможно присутствуют записи, нарушающие ограничение).                                     |
| i1001  |             | similar indexes                          | warning  | enable        | Индексы очень похожи (возможно совпадают).                                                                                           |
| i1002  |             | index has bad signs                      | error    | enable        | Индекс имеет признаки проблем.                                                                                                       |
| i1003  |             | similar indexes unique and not unique    | warning  | enable        | Уникальный и не уникальный индексы очень похожи (возможно не уникальный лишний).                                                     |
| i1005  |             | similar indexes (roughly)                | notice   | disable       | Индексы похожи по набору полей (грубое сравнение).                                                                                   |
| i1010  |             | b-tree index for array column            | notice   | enable        | B-tree индекс на поле с массивом значений, не индексирует элементы массива (возможно нужен GIN индекс).                              |
| s1010  |             | less 5% unused sequence values           | critical | enable        | У последовательности осталось менее 5% неиспользованных значений.                                                                    |
| s1011  | s1010       | less 10% unused sequence values          | error    | enable        | У последовательности осталось менее 10% неиспользованных значений.                                                                   |
| s1012  | s1011       | less 20% unused sequence values          | warning  | enable        | У последовательности осталось менее 20% неиспользованных значений.                                                                   |
| n1001  |             | confusion in name of schemas             | warning  | enable        | Возможна путаница в наименованиях схем. Наименования опасно похожи.                                                                  |
| n1005  |             | confusion in name of relation attributes | warning  | enable        | Возможна путаница в наименованиях атрибутов отношения (колонок). Наименования опасно похожи.                                         |
| n1010  |             | confusion in name of relations           | warning  | enable        | Возможна путаница в наименованиях отношений в одной схеме. Наименования опасно похожи.                                               |
| n1015  |             | confusion in name of indexes             | warning  | enable        | Возможна путаница в наименованиях индексов. Наименования опасно похожи.                                                              |
| n1020  |             | confusion in name of sequences           | warning  | enable        | Возможна путаница в наименованиях последовательностей в одной схеме. Наименования опасно похожи.                                     |



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

## Примеры адаптации и интеграции в CI

### Переключение локализации сообщений с помощью bash команды

Изменение настройки локализации сообщений на `en`, атрибут `conf_language_code`.

```shell
sed -i "/AS conf_language_code,/c\'en' AS conf_language_code," db_verifier.sql
```

### Явное включение/отключение проверок с помощью bash команды

Явное отключение проверки `i1001` (similar indexes), атрибут `enable_check_i1001`.

```shell
sed -i "s/AS enable_check_i1001/AND false AS enable_check_i1001/" db_verifier.sql
```

```sql
-- до корректировки
    true AS enable_check_i1001      -- [warning] similar indexes
-- после корректировки
    true  AND false AS enable_check_i1001      -- [warning] similar indexes
```

Явное включение проверки `fk1007` (not involved in foreign keys), атрибут `enable_check_fk1007`.

```shell
sed -i "s/AS enable_check_fk1007/OR true AS enable_check_fk1007/" db_verifier.sql
```

```sql
-- до корректировки
    false AS enable_check_fk1007,    -- [notice] not involved in foreign keys
-- после корректировки
    false OR true AS enable_check_fk1007,    -- [notice] not involved in foreign keys
```

### Фильтрация результатов проверки

Фильтрация результатов проверки необходима для исключения ложных срабатываний или для реализации функционала исключения 
известных ошибок (baseline, error suppression).
Для этого можно добавить в скрипт условие `WHERE` на этапе фильтрации результатов проверки, точка для установки такого 
условия указана в строке комментария `>>> WHERE`. 

Пример условий для фильтрации результатов (подавления некоторых ошибок).

```shell
cat examples/where.sql 
WHERE
NOT (check_code = 'fk1007' AND object_name = 'public.schema_migrations')
```

```shell
sed -i "/>>> WHERE/ r examples/where.sql" db_verifier.sql
```

### Кумулятивная оценка (одно значение)

Вариант реализации получения агрегированной оценки одним значением. 
Сопоставим каждой строке результата числовой значение на основе `check_level`, пример в файле 
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

Объединим скрипты, результат в `examples/cumulative_score.sql`.

```shell
sed -i "/^;$/d" db_verifier.sql
sed -i "/>>> db_verifier/ r db_verifier.sql" ./examples/cumulative_score.sql
```

## Описание таблицы результатов проверки

| column name       | description                                                      |
|:------------------|:-----------------------------------------------------------------|
| object_id         | id (oid) объекта в соответствующей системной таблице             |
| object_name       | наименование объекта, в некоторых случаях со схемой              |    
| object_type       | тип проверяемого объекта (relation, constraint, index, sequence) |  
| check_code        | код проверки (см. таблицу выше)                                  |  
| check_level       | уровень важности результата (см. таблицу выше)                   |  
| check_name        | наименование проверки (см. таблицу выше)                         |  
| check_result_json | подробные результаты проверки в формате json                     |  
 

## Другие описания проекта

* \[EN] [`README.md`](README.md)