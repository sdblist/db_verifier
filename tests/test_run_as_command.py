from pathlib import Path

import psycopg

from db_verifier.run import run_db_verifier

SQL = Path(__file__).parent / "sql"


def test_finishes_with_zero_if_nothing_found(empty_temp_db: psycopg.Connection):
    info = empty_temp_db.info
    connection_uri = f"postgresql://{info.user}:{info.password}@{info.host}:{info.port}/{info.dbname}"
    actual = run_db_verifier(["db_verifier", f"--connection={connection_uri}"])
    assert actual == 0


def test_finishes_with_2_if_connection_problem(empty_temp_db: psycopg.Connection):
    info = empty_temp_db.info
    connection_uri = f"postgresql://wrong_user:{info.password}@{info.host}:{info.port}/{info.dbname}"
    actual = run_db_verifier(["db_verifier", f"--connection={connection_uri}"])
    assert actual == 2


def test_finishes_with_1_if_issues_found(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "no1001.sql").read_text())
    info = empty_temp_db.info
    connection_uri = f"postgresql://{info.user}:{info.password}@{info.host}:{info.port}/{info.dbname}"
    actual = run_db_verifier(["db_verifier", f"--connection={connection_uri}"])
    assert actual == 1
