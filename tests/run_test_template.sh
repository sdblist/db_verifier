# ${CHECK_NAME}
# ${MIN_PG_VERSION}

if ! [ -f "./shards/${CHECK_NAME}.sql" ]; then
  echo "Error: can not find ./shards/${CHECK_NAME}.sql"
  exit 1
fi

# check PostgreSQL version
if [[ $(psql --username=postgres --command="SELECT CASE WHEN current_setting('server_version_num')::integer >= '${MIN_PG_VERSION}'::integer THEN 1 ELSE 0 END;" --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on) -ne 1 ]]; then
    echo "${CHECK_NAME} - info - unsupported PostgreSQL version"
else
  # result to table db_verifier_result
  sed -i "/) AS check_result_json/s/.*/) AS check_result_json INTO UNLOGGED public.db_verifier_result/1" ./shards/${CHECK_NAME}.sql

  ## enable check
  sed -i "/AS enable_check_${CHECK_NAME}/s/.*/true AS enable_check_${CHECK_NAME},/"  db_verifier.sql
  ## create objects for test
  psql --file=./tests/${CHECK_NAME}.up.sql --set=ON_ERROR_STOP=on > /dev/null

  ### test db_verifier.sql
  psql --file=./db_verifier.sql --set=ON_ERROR_STOP=on > /dev/null
  if [[ $(psql --file=./tests/${CHECK_NAME}.test.sql --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on) -ne 0 ]]; then
      echo "${CHECK_NAME} - error - db_verifier.sql"
      exit 1
  else
      echo "${CHECK_NAME} - OK - db_verifier.sql"
  fi
  ## remove public.db_verifier_result
  psql --file=./tests/db_verifier_result.down.sql --set=ON_ERROR_STOP=on > /dev/null

  ### test shards/${CHECK_NAME}.sql
  psql --file=./shards/${CHECK_NAME}.sql --set=ON_ERROR_STOP=on > /dev/null
  if [[ $(psql --file=./tests/${CHECK_NAME}.test.sql --quiet --no-align --tuples-only --set=ON_ERROR_STOP=on) -ne 0 ]]; then
      echo "${CHECK_NAME} - error - shards/${CHECK_NAME}.sql"
      exit 1
  else
      echo "${CHECK_NAME} - OK - shards/${CHECK_NAME}.sql"
  fi
  ## remove public.db_verifier_result
  psql --file=./tests/db_verifier_result.down.sql --set=ON_ERROR_STOP=on > /dev/null

  ## remove objects for test
  PGOPTIONS="--client-min-messages=warning" psql --file=./tests/${CHECK_NAME}.down.sql --set=ON_ERROR_STOP=on > /dev/null

  ## disable check
  sed -i "/AS enable_check_${CHECK_NAME}/s/.*/false AS enable_check_${CHECK_NAME},/"  db_verifier.sql

fi
