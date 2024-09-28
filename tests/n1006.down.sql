-- n1006 - unwanted characters in attribute name

-- "n1006 "     - yes
-- "	n1006"  - yes
-- "n.1006"     - yes
-- "n+1006"     - yes
-- "n\n1006"    - yes
-- "n
-- 1006"        - yes
DROP TABLE IF EXISTS public.n1006 CASCADE;
