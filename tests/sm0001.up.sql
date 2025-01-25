-- sm0001 - invalid attribute type for uuid

-- sm0001 - ok
CREATE TABLE public.sm0001_1
(
    uid       uuid,
    "uuid"    uuid,
    "guid"    uuid,
    user_id   text,
    data_uuid text,
    data_guid bytea,
    CONSTRAINT sm0001_1_pk PRIMARY KEY (uid)
);

-- sm0001 - yes - id
-- sm0001 - yes - data_uid
-- sm0001 - yes - data_guid
-- sm0001 - yes - data_id
CREATE TABLE public.sm0001_2
(
    id  varchar(32),
    data_uid  varchar(32),
    data_guid varchar(36),
    data_id   varchar(36)
);