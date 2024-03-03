import sys
from contextlib import contextmanager
from io import StringIO
from uuid import uuid4

import pytest
from environs import Env
from psycopg import Connection, connect
from psycopg.errors import InvalidCatalogName


def safe_drop_db(connection: Connection, db_name: str):
    try:
        connection.execute(f"DROP DATABASE {db_name};")
    except InvalidCatalogName as e:
        exc = str(e)
        if "database" in exc and "does not exist" in exc:
            pass
        else:
            raise e


@pytest.fixture(scope="function")
def empty_temp_db() -> Connection:
    env = Env()
    uri = env.str("TEST_DB_CONNECTION", default="postgresql://db_verifier:db_verifier@localhost:5434/db_verifier")
    with connect(uri, autocommit=True) as master_connection:
        db_name = f"{master_connection.info.dbname}_{uuid4()}".replace("-", "")
        safe_drop_db(master_connection, db_name)
        try:
            master_connection.execute(f"CREATE DATABASE {db_name} WITH OWNER={master_connection.info.user};")
            with connect(uri, dbname=db_name, autocommit=True) as test_conn:
                yield test_conn
        finally:
            safe_drop_db(master_connection, db_name)


@contextmanager
def fake_stdout() -> StringIO:
    temp_out = StringIO()
    sys.stdout = temp_out
    try:
        yield temp_out
    finally:
        sys.stdout = sys.__stdout__
