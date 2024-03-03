from collections import defaultdict
from pathlib import Path
from typing import Set, Dict, Iterable

import psycopg

from db_verifier import verify
from db_verifier.data_structures import ReportItem

SQL = Path(__file__).parent / "sql"


def collect_check_codes(issues: Iterable[ReportItem]) -> Dict[str, Set[str]]:
    d = defaultdict(set)
    for item in issues:
        d[item.object_name].add(item.check.check_code)
    return d


def test_c1001(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "c1001.sql").read_text())
    actual = collect_check_codes(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    expected = {"c1001_1_chk": {"c1001"}, "c1001_1_fk": {"c1001"}}
    assert expected == actual


def test_fk1001(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "fk1001.sql").read_text())
    actual = collect_check_codes(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    expected = {"fk1001_2_fk_fk1001_2": {"fk1001"}, "fk1001_3_fk_fk1001_3": {"fk1001"}}
    assert expected == actual


def test_fk1002(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "fk1002.sql").read_text())
    issues = list(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    assert not issues


def test_fk1007(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "fk1007.sql").read_text())
    issues = list(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    assert not issues


def test_i1001(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "i1001.sql").read_text())
    actual = collect_check_codes(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    expected = {
        "public.i1001_1_pk": {"i1001", "i1003"},
        "public.i1001_1_unique": {"i1001", "i1003"},
        "public.i_id_unique": {"i1001", "i1003"},
        "public.i_value_unique": {"i1001", "i1003"},
        "public.i_id_unique_desc": {"i1003"},
        "public.i_id_unique_include_value": {"i1003"},
        "public.i_id_value_unique": {"i1003"},
        "public.i_value_unique_desc": {"i1003"},
    }
    assert expected == actual


def test_no1001(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "no1001.sql").read_text())
    actual = collect_check_codes(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    expected = {
        "public.no1001_3": {"no1001"},
        "public.no1001_5": {"no1001"},
        "public.no1001_6": {"no1001"},
        "public.no1001_2": {"no1002"},
        "public.no1001_4": {"no1002"},
        "public.no1001_7": {"no1002"},
        "public.no1001_8": {"no1002"},
    }
    assert expected == actual


def test_s1010(empty_temp_db: psycopg.Connection):
    empty_temp_db.execute((SQL / "s1010.sql").read_text())
    actual = collect_check_codes(verify(empty_temp_db, raise_on_warnings=False, raise_on_errors=False))
    expected = {"public.s1010_1_id_seq": {"s1010"}, "public.s1010_2": {"s1011"}, "public.s1010_3": {"s1012"}}
    assert expected == actual
