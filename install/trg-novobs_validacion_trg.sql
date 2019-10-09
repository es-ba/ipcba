CREATE OR REPLACE FUNCTION novobs_validacion_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vexistecalobs integer;
  vexisterelpre integer;
BEGIN
  SELECT 1 into vexistecalobs
  FROM cvp.calobs
  WHERE periodo = new.periodo 
     and calculo = new.calculo 
     and producto = new.producto 
     and informante = new.informante 
     and observacion = new.observacion;
  IF vexistecalobs IS NULL THEN
    SELECT distinct 1 into vexisterelpre
    FROM cvp.relpre
    WHERE periodo = new.periodo 
        and producto = new.producto 
        and informante = new.informante 
        and observacion = new.observacion;
    IF vexisterelpre IS NULL THEN
        RAISE EXCEPTION 'Se quiere insertar Periodo: % producto: % informante; % observacion: % inválido', new.periodo, new.producto, new.informante, new.observacion;
        RETURN NULL;
    END IF;
 END IF;
 RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER novobs_existe_observacion_trg
  BEFORE INSERT
  ON novobs
  FOR EACH ROW
  EXECUTE PROCEDURE novobs_validacion_trg();
