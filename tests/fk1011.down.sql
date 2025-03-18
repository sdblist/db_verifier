-- fk1011 - FK have common attributes

DROP TABLE IF EXISTS public.fk1011_1 CASCADE;

-- fk1011 - yes fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i1
-- fk1011 - yes fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i2
-- fk1011 - yes fk1011_1_fk_fk1011_1_id + fk1011_1_fk_fk1011_1_id_i2_copy
-- fk1011 - yes fk1011_1_fk_fk1011_1_id_i1 + fk1011_1_fk_fk1011_1_id_i2
-- fk1011 - yes fk1011_1_fk_fk1011_1_id_i1 + fk1011_1_fk_fk1011_1_id_i2_copy
-- fk1011 - yes fk1011_1_fk_fk1011_1_id_i2_copy + fk1011_1_fk_fk1011_1_i2
DROP TABLE IF EXISTS public.fk1011_1_fk;
