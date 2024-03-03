import json
from pathlib import Path

import psycopg
import pytest

from db_verifier import verify_and_print_txt, FatalDBIssuesException, verify_and_print_csv, verify_and_print_json
from tests.conftest import fake_stdout

SQL = Path(__file__).parent / "sql"


def test_verify_and_print_txt_raises_error_on_error(empty_temp_db: psycopg.Connection):
    # we know these test structures raise errors
    empty_temp_db.execute((SQL / "fk1001.sql").read_text())
    with pytest.raises(FatalDBIssuesException):
        verify_and_print_txt(empty_temp_db)


def test_verify_and_print_txt_raises_error_on_warning_if_requested(empty_temp_db: psycopg.Connection):
    # we know these test structures raise warnings
    empty_temp_db.execute((SQL / "c1001.sql").read_text())
    # no exception should be raised
    verify_and_print_txt(empty_temp_db, fail_on_warnings=False)
    with pytest.raises(FatalDBIssuesException):
        verify_and_print_txt(empty_temp_db, fail_on_warnings=True)


def test_verify_and_print_txt_proper_output(empty_temp_db: psycopg.Connection):
    # we know these test structures raise errors
    empty_temp_db.execute((SQL / "fk1001.sql").read_text())
    with fake_stdout() as temp_out:
        with pytest.raises(FatalDBIssuesException):
            verify_and_print_txt(empty_temp_db)
        actual = temp_out.getvalue().strip()
        expected = """The following issues have been detected in the database:

1. ERROR fk1001_2_fk_fk1001_2: fk uses mismatched types
Check Code: fk1001
DB Object Type: constraint
Details: Foreign key uses columns with mismatched types.

2. ERROR fk1001_3_fk_fk1001_3: fk uses mismatched types
Check Code: fk1001
DB Object Type: constraint
Details: Foreign key uses columns with mismatched types."""

    assert actual == expected


def test_verify_and_print_csv_proper_output(empty_temp_db: psycopg.Connection):
    # we know these test structures raise errors
    empty_temp_db.execute((SQL / "fk1001.sql").read_text())
    with fake_stdout() as temp_out:
        with pytest.raises(FatalDBIssuesException):
            verify_and_print_csv(empty_temp_db)
        actual = "\n".join(temp_out.getvalue().strip().split("\r\n"))
        expected = """check_level,object_type,object_name,parent_check_code,check_code,check_name,check_description
error,constraint,fk1001_2_fk_fk1001_2,,fk1001,fk uses mismatched types,Foreign key uses columns with mismatched types.
error,constraint,fk1001_3_fk_fk1001_3,,fk1001,fk uses mismatched types,Foreign key uses columns with mismatched types."""

    assert actual == expected


def test_verify_and_print_json_proper_output(empty_temp_db: psycopg.Connection):
    # we know these test structures raise errors
    empty_temp_db.execute((SQL / "fk1001.sql").read_text())
    with fake_stdout() as temp_out:
        with pytest.raises(FatalDBIssuesException):
            verify_and_print_json(empty_temp_db)
        actual = temp_out.getvalue().strip()
        expected = """{"object_name":"fk1001_2_fk_fk1001_2","object_type":"constraint","check":{"check_code":"fk1001","parent_check_code":null,"check_name":"fk uses mismatched types","check_level":"error","check_source_name":"system catalog","description_language_code":null,"description_value":"Foreign key uses columns with mismatched types."}}
{"object_name":"fk1001_3_fk_fk1001_3","object_type":"constraint","check":{"check_code":"fk1001","parent_check_code":null,"check_name":"fk uses mismatched types","check_level":"error","check_source_name":"system catalog","description_language_code":null,"description_value":"Foreign key uses columns with mismatched types."}}"""

    # we can't directly compare them because of different object ids each time
    # so removing them first
    actual = [json.loads(l) for l in actual.split("\n")]
    for l in actual:
        del l["object_id"]
    expected = [json.loads(l) for l in expected.split("\n")]

    assert actual == expected
