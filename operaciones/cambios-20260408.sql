CREATE OR REPLACE FUNCTION cvp.setear_periodo_calculo_anterior_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  vperiodoanterior character varying(11);
  vcalculo integer;
BEGIN
  vperiodoanterior := null;
  SELECT periodoanterior INTO vperiodoanterior
  FROM cvp.periodos
  WHERE periodo = NEW.periodo;
  IF vperiodoanterior IS NOT NULL THEN
	SELECT calculo INTO vcalculo
    FROM cvp.calculos_def
    WHERE principal;
  ELSE
     vcalculo = null;
  END IF;
  NEW.periodoanterior:= vperiodoanterior;
  NEW.calculoanterior:= vcalculo;
  RETURN NEW;
END;
$BODY$;