#!/usr/bin/env bash

set -e

if ! [ -f "db_verifier.sql" ]; then
  echo "Error: can not find db_verifier.sql in $(pwd)"
  exit 1
fi

# disable all checks
## c1001
sed -i "/AS enable_check_c1001/s/.*/false AS enable_check_c1001,/"  db_verifier.sql
## fk1001
sed -i "/AS enable_check_fk1001/s/.*/false AS enable_check_fk1001,/"  db_verifier.sql
## fk1002
sed -i "/AS enable_check_fk1002/s/.*/false AS enable_check_fk1002,/"  db_verifier.sql
## fk1007
sed -i "/AS enable_check_fk1007/s/.*/false AS enable_check_fk1007,/"  db_verifier.sql
## fk1010
sed -i "/AS enable_check_fk1010/s/.*/false AS enable_check_fk1010,/"  db_verifier.sql
## fk1011
sed -i "/AS enable_check_fk1011/s/.*/false AS enable_check_fk1011,/"  db_verifier.sql
## i1001
sed -i "/AS enable_check_i1001/s/.*/false AS enable_check_i1001,/"  db_verifier.sql
## i1002
sed -i "/AS enable_check_i1002/s/.*/false AS enable_check_i1002,/"  db_verifier.sql
## i1003
sed -i "/AS enable_check_i1003/s/.*/false AS enable_check_i1003,/"  db_verifier.sql
## i1005
sed -i "/AS enable_check_i1005/s/.*/false AS enable_check_i1005,/"  db_verifier.sql
## i1010
sed -i "/AS enable_check_i1010/s/.*/false AS enable_check_i1010,/"  db_verifier.sql
## n1001
sed -i "/AS enable_check_n1001/s/.*/false AS enable_check_n1001,/"  db_verifier.sql
## n1002
sed -i "/AS enable_check_n1002/s/.*/false AS enable_check_n1002,/"  db_verifier.sql
## n1005
sed -i "/AS enable_check_n1005/s/.*/false AS enable_check_n1005,/"  db_verifier.sql
## n1006
sed -i "/AS enable_check_n1006/s/.*/false AS enable_check_n1006,/"  db_verifier.sql
## n1010
sed -i "/AS enable_check_n1010/s/.*/false AS enable_check_n1010,/"  db_verifier.sql
## n1011
sed -i "/AS enable_check_n1011/s/.*/false AS enable_check_n1011,/"  db_verifier.sql
## n1015
sed -i "/AS enable_check_n1015/s/.*/false AS enable_check_n1015,/"  db_verifier.sql
## n1016
sed -i "/AS enable_check_n1016/s/.*/false AS enable_check_n1016,/"  db_verifier.sql
## n1020
sed -i "/AS enable_check_n1020/s/.*/false AS enable_check_n1020,/"  db_verifier.sql
## n1021
sed -i "/AS enable_check_n1021/s/.*/false AS enable_check_n1021,/"  db_verifier.sql
## no1001
sed -i "/AS enable_check_no1001/s/.*/false AS enable_check_no1001,/"  db_verifier.sql
## no1002
sed -i "/AS enable_check_no1002/s/.*/false AS enable_check_no1002,/"  db_verifier.sql
## r1001
sed -i "/AS enable_check_r1001/s/.*/false AS enable_check_r1001,/"  db_verifier.sql
## r1002
sed -i "/AS enable_check_r1002/s/.*/false AS enable_check_r1002,/"  db_verifier.sql
## s1001
sed -i "/AS enable_check_s1001/s/.*/false AS enable_check_s1001,/"  db_verifier.sql
## s1010
sed -i "/AS enable_check_s1010/s/.*/false AS enable_check_s1010,/"  db_verifier.sql
## s1011
sed -i "/AS enable_check_s1011/s/.*/false AS enable_check_s1011,/"  db_verifier.sql
## s1012
sed -i "/AS enable_check_s1012/s/.*/false AS enable_check_s1012,/"  db_verifier.sql
## sm0001
sed -i "/AS enable_check_sm0001/s/.*/false AS enable_check_sm0001,/"  db_verifier.sql

# result to table db_verifier_result
## db_verifier.sql
sed -i "/SELECT object_id, object_name, object_type, check_code, check_level, check_name, check_result_json FROM (/s/.*/SELECT object_id, object_name, object_type, check_code, check_level, check_name, check_result_json INTO UNLOGGED public.db_verifier_result FROM (/1" db_verifier.sql
## c1001
sed -i "/) AS check_result_json/s/.*/) AS check_result_json INTO UNLOGGED public.db_verifier_result/1" ./shards/c1001.sql

# echo postgres server version
echo "Server version: $(psql --command='select version();' --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on)"

# c1001
## enable check
sed -i "/AS enable_check_c1001/s/.*/true AS enable_check_c1001,/"  db_verifier.sql
## test
psql --file=./tests/c1001.up.sql --set=ON_ERROR_STOP=on > /dev/null
### test db_verifier.sql
psql --file=./db_verifier.sql --set=ON_ERROR_STOP=on > /dev/null
if [[ $(psql --file=./tests/c1001.test.sql --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on) -ne 0 ]]; then
    echo "db_verifier.sql - c1001 - error"
  exit 1
else
    echo "db_verifier.sql - c1001 - OK"
fi
psql --file=./tests/db_verifier_result.down.sql --set=ON_ERROR_STOP=on > /dev/null
### test shards/c1001.sql
psql --file=./shards/c1001.sql --set=ON_ERROR_STOP=on > /dev/null
if [[ $(psql --file=./tests/c1001.test.sql --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on) -ne 0 ]]; then
    echo "shards/c1001.sql - c1001 - error"
  exit 1
else
    echo "shards/c1001.sql - c1001 - OK"
fi
psql --file=./tests/db_verifier_result.down.sql --set=ON_ERROR_STOP=on > /dev/null
psql --file=./tests/c1001.down.sql --set=ON_ERROR_STOP=on > /dev/null
## disable check
sed -i "/AS enable_check_c1001/s/.*/false AS enable_check_c1001,/"  db_verifier.sql
