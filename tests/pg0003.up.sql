-- pg0003 - function with SECURITY DEFINER and without fixed search_path

-- pg0003 - yes - public.pg0003_1
CREATE FUNCTION public.pg0003_1()
    RETURNS boolean AS
$$
BEGIN
    RETURN true;
END;
$$ LANGUAGE plpgsql
    SECURITY DEFINER;

-- pg0003 - ok - public.pg0003_2
CREATE FUNCTION public.pg0003_2()
    RETURNS boolean AS
$$
BEGIN
    RETURN true;
END;
$$
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = '';

-- pg0003 - ok - public.pg0003_3
CREATE FUNCTION public.pg0003_3()
    RETURNS boolean AS
$$
BEGIN
    RETURN true;
END;
$$
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = pg_catalog, pg_temp;
