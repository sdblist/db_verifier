import argparse
import csv
import sys
from pathlib import Path
from traceback import print_exc
from typing import Sequence, Optional, Iterable

import psycopg
from psycopg.connection import Connection

from db_verifier.data_structures import ReportItem, CheckLevel

sql_script = Path(__file__).parents[1] / "db_verifier.sql"


class FatalDBIssuesException(Exception):
    pass


def verify(conn: Connection, raise_on_warnings: bool = False, raise_on_errors: bool = True) -> Iterable[ReportItem]:
    sql = sql_script.read_text("utf-8")
    warnings = False
    errors = False
    with conn.cursor() as cursor:
        cursor.execute(sql)
        rows = cursor.fetchmany()
        while rows:
            for row in rows:
                row_json_dict = row[6]
                item = ReportItem.model_validate(row_json_dict, strict=False)
                errors = errors or item.check.check_level in (CheckLevel.CRITICAL, CheckLevel.ERROR)
                warnings = warnings or item.check.check_level == CheckLevel.WARNING
                yield item
            rows = cursor.fetchmany()
    if errors and raise_on_errors:
        raise FatalDBIssuesException()
    if warnings and raise_on_warnings:
        raise FatalDBIssuesException()


def verify_and_print_txt(conn: Connection, fail_on_warnings: bool = False, fail_on_errors: bool = True):
    first_time = True
    for n, item in enumerate(verify(conn, raise_on_warnings=fail_on_warnings, raise_on_errors=fail_on_errors)):
        if first_time:
            print("\nThe following issues have been detected in the database:\n")
            first_time = False
        code_str = item.check.check_code or "no_code"
        if item.check.parent_check_code:
            code_str = item.check.parent_check_code + "/" + code_str
        print(
            f"{n+1}. {item.check.check_level.value.upper()} {item.object_name}: {item.check.check_name}\n"
            f"Check Code: {code_str}\n"
            f"DB Object Type: {item.object_type.value}\n"
            f"Details: {item.check.description_value}\n"
        )
    if first_time:
        print("No issues have been detected.")


def verify_and_print_csv(conn: Connection, fail_on_warnings: bool = False, fail_on_errors: bool = True):
    w = csv.writer(sys.stdout, dialect="excel")
    w.writerow(
        (
            "check_level",
            "object_type",
            "object_name",
            "parent_check_code",
            "check_code",
            "check_name",
            "check_description",
        )
    )
    for item in verify(conn, raise_on_warnings=fail_on_warnings, raise_on_errors=fail_on_errors):
        w.writerow(
            (
                item.check.check_level.value,
                item.object_type.value,
                item.object_name,
                item.check.parent_check_code,
                item.check.check_code,
                item.check.check_name,
                item.check.description_value,
            )
        )


def verify_and_print_json(conn: Connection, fail_on_warnings: bool = False, fail_on_errors: bool = True):
    for item in verify(conn, raise_on_warnings=fail_on_warnings, raise_on_errors=fail_on_errors):
        print(item.model_dump_json())


def run_db_verifier(argv: Optional[Sequence[str]] = None) -> int:
    arg_parser = argparse.ArgumentParser(prog="db_verifier", description="Linter for PostgreSQL DB structures.")
    arg_parser.add_argument(
        "--connection",
        type=str,
        required=True,
        help="""PostgreSQL connection string as accepted by psycopg library.
See: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
Example: postgresql://user:password@localhost:5433/my_db
Connection parameters can be specified via environment variables such as:
PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD/PGPASSFILE.
See: https://www.postgresql.org/docs/current/libpq-envars.html
""",
    )
    arg_parser.add_argument(
        "--format", type=str, choices=("csv", "json", "txt"), default="txt", help="Output report format."
    )
    arg_parser.add_argument(
        "--fail_on_warnings",
        type=bool,
        required=False,
        help="Exit with error code 1 if any warning is detected. "
        "If false - then fail on errors and critical errors only.",
    )
    args_to_parse = (argv or sys.argv)[1:] or ["--help"]
    args = arg_parser.parse_args(args_to_parse)
    connection_string: str = args.connection
    fail_on_warnings = args.fail_on_warnings
    output_format = (args.format or "txt").lower()
    try:
        with psycopg.connect(conninfo=connection_string) as conn:
            if output_format == "csv":
                verify_and_print_csv(conn, fail_on_warnings=fail_on_warnings, fail_on_errors=True)
            elif output_format == "json":
                verify_and_print_json(conn, fail_on_warnings=fail_on_warnings, fail_on_errors=True)
            else:
                verify_and_print_txt(conn, fail_on_warnings=fail_on_warnings, fail_on_errors=True)
        return 0
    except FatalDBIssuesException:
        return 1
    except:
        print_exc()
        return 2


if __name__ == "__main__":
    sys.exit(run_db_verifier())
