-- FUNCTION: ccc.extraer_rango_edad(character varying)

-- DROP FUNCTION IF EXISTS ccc.extraer_rango_edad(character varying);

CREATE OR REPLACE FUNCTION ccc.extraer_rango_edad(
	rango_edad_str character varying)
    RETURNS TABLE(edad_desde integer, edad_hasta integer, unidad_medida character varying)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    -- Normalizamos la entrada para evitar problemas con espacios en blanco.
    input_str text := TRIM(rango_edad_str);
    match_data text[];
BEGIN
    ----------------------------------------------------------
    -- 1. PATRÓN DE RANGO: '20-35 años'
    -- Captura: (Edad_Desde) - (Edad_Hasta) (Unidad)
    ----------------------------------------------------------
    match_data := REGEXP_MATCHES(input_str, '^(\d+)\s*-\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 3 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := match_data[2]::integer;
        unidad_medida := TRIM(match_data[3]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 2. PATRÓN DE LÍMITE INFERIOR (Desde/Mínimo): '≥ 60 años' o '>= 60 años'
    -- Captura: (Símbolo ≥ o >) (Edad_Desde) (Unidad)
    ----------------------------------------------------------
    -- El patrón (?:≥|[>]?=) coincide con ≥, > o >=
    match_data := REGEXP_MATCHES(input_str, '^(?:≥|[>]?=)\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := NULL; -- Límite superior abierto
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 3. PATRÓN DE LÍMITE SUPERIOR (Hasta/Máximo): '≤ 18 años' o '<= 18 años'
    -- Captura: (Símbolo ≤ o <) (Edad_Hasta) (Unidad)
    ----------------------------------------------------------
    -- El patrón (?:≤|[<]?=) coincide con ≤, < o <=
    match_data := REGEXP_MATCHES(input_str, '^(?:≤|[<]?=)\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := NULL; -- Límite inferior abierto
        edad_hasta := match_data[1]::integer;
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 4. PATRÓN DE EDAD ÚNICA: '1 año' o '3 años'
    -- Captura: (Edad) (Unidad)
    ----------------------------------------------------------
    match_data := REGEXP_MATCHES(input_str, '^(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := match_data[1]::integer; -- Desde y Hasta son el mismo valor
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 5. NINGÚN PATRÓN ENCONTRADO
    ----------------------------------------------------------
    edad_desde := NULL;
    edad_hasta := NULL;
    unidad_medida := NULL;
    RETURN NEXT;

END;
$BODY$;