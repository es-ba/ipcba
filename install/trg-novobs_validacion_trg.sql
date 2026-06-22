CREATE OR REPLACE FUNCTION novobs_validacion_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vexistecalobs integer;
  vexisterelpre integer;
BEGIN
  IF new.estado = 'Baja' AND (TG_OP = 'INSERT' OR old.estado IS DISTINCT FROM 'Baja') THEN
    PERFORM 1
    FROM cvp.calculos c
    JOIN cvp.calobs o ON c.periodoanterior = o.periodo AND c.calculoanterior = o.calculo
    WHERE c.periodo = new.periodo AND c.calculo = new.calculo
      AND o.producto = new.producto AND o.informante = new.informante AND o.observacion = new.observacion
      AND o.impobs LIKE 'R%' AND o.antiguedadincluido is not null;

    IF FOUND THEN
        RAISE EXCEPTION 'No se permite dar una baja en el periodo actual si en el periodo anterior fue real e incluido en el cálculo.';
        RETURN NULL;
    END IF;
  END IF;

  IF TG_OP = 'INSERT' THEN
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
  END IF;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

DROP TRIGGER IF EXISTS novobs_existe_observacion_trg ON novobs;
CREATE TRIGGER novobs_existe_observacion_trg
  BEFORE INSERT OR UPDATE
  ON novobs
  FOR EACH ROW
  EXECUTE PROCEDURE novobs_validacion_trg();

