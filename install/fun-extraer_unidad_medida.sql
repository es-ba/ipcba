CREATE OR REPLACE FUNCTION ccc.extraer_unidad_medida(
	rango_edad_str character varying)
    RETURNS character varying
    LANGUAGE 'sql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
SELECT (extraer_rango_edad(rango_edad_str)).unidad_medida;
$BODY$;