CREATE OR REPLACE FUNCTION calcularvarios(
	p_periodo_desde text,
	p_periodo_hasta text,
	p_calculo integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
AS $BODY$
DECLARE
  vEmpezo time;
  vTermino time;
  mPeriodos RECORD;
BEGIN
  vEmpezo:=clock_timestamp();
  FOR mPeriodos IN 
    SELECT periodo
      FROM calculos
      WHERE periodo BETWEEN p_Periodo_Desde AND p_Periodo_Hasta 
        AND calculo=p_Calculo
      ORDER BY periodo
  LOOP
    PERFORM CalcularUnPeriodo(mPeriodos.Periodo, p_Calculo);
  END LOOP;
  vTermino:=clock_timestamp();
  RETURN 'Varios calculos Empezo '||cast(vEmpezo as text)||' termino '||cast(vTermino as text)||' demoro '||(vTermino - vEmpezo);
END;
$BODY$;
