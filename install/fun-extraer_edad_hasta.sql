CREATE OR REPLACE FUNCTION ccc.extraer_edad_hasta(
	rango_edad_str character varying)
    RETURNS integer
    LANGUAGE 'sql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
SELECT (extraer_rango_edad(rango_edad_str)).edad_hasta;
$BODY$;