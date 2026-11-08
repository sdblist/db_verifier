-- sm0002 - column with varchar/bpchar type and no length specified

-- sm0002 - yes - bpchar_wo_length
-- sm0002 - yes - varchar_wo_length
CREATE UNLOGGED TABLE public.sm0002_1
(
    bpchar_w_length bpchar(1),
    bpchar_wo_length bpchar,
    varchar_w_length varchar(1),
    varchar_wo_length varchar
);
