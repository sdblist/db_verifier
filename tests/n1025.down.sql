-- n1025 - confusion in name of constraint

-- n1025 - yes - n1025_1_pk
DROP TABLE IF EXISTS public.n1025_1;

-- n1025 - yes - n1025_1_fk
-- n1025 - no - "n1025_1_FK " (oid n1025_1_fk < oid n1025_1_FK)
-- n1025 - no - " n1025_1_PK" (oid n1025_1_pk < oid " n1025_1_PK")
