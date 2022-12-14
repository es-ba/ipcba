CREATE OR REPLACE FUNCTION setear_periodo_calculo_anterior_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vperiodoanterior character varying(11);
  vcalculoanterior integer;
BEGIN
  vperiodoanterior := null;
  SELECT periodoanterior INTO vperiodoanterior
  FROM cvp.periodos
  WHERE periodo = NEW.periodo;
  IF vperiodoanterior IS NOT NULL THEN
    SELECT calculoanterior INTO vcalculoanterior
    FROM cvp.calculos
    WHERE periodo = vperiodoanterior AND calculo = NEW.calculo;
  ELSE
     vcalculoanterior = null;
  END IF;
  NEW.periodoanterior:= vperiodoanterior;
  NEW.calculoanterior:= vcalculoanterior;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER calculos_periodo_calculo_anterior_trg
  BEFORE INSERT
  ON calculos
  FOR EACH ROW
  EXECUTE PROCEDURE setear_periodo_calculo_anterior_trg();

  