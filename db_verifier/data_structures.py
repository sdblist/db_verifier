from enum import Enum
from typing import Optional

from pydantic import BaseModel


class CheckLevel(Enum):
    CRITICAL = "critical"
    ERROR = "error"
    WARNING = "warning"
    NOTICE = "notice"


class ObjectType(Enum):
    CONSTRAINT = "constraint"
    RELATION = "relation"
    INDEX = "index"
    SEQUENCE = "sequence"


class Check(BaseModel):
    check_code: str
    parent_check_code: Optional[str]
    check_name: str
    check_level: CheckLevel
    check_source_name: str
    description_language_code: Optional[str]
    description_value: str


class ReportItem(BaseModel):
    object_id: str
    object_name: str
    object_type: ObjectType
    check: Check
