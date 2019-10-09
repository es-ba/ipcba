CREATE OR REPLACE FUNCTION verificar_sincronizacion()
  RETURNS trigger AS
$BODY$

DECLARE
 vexisterazon integer:=null;
BEGIN
IF new.vencimiento_sincronizacion IS NOT NULL THEN
    SELECT DISTINCT 1 INTO vexisterazon
    FROM cvp.relvis
    WHERE periodo = new.periodo AND panel = new.panel AND tarea = new.tarea AND not(razon IS NULL OR razon=0);
    IF vexisterazon is distinct from NULL THEN  
        RAISE EXCEPTION 'Existe algún formulario con razon no nula en el periodo: %, panel: %, tarea: %',new.periodo, new.panel, new.tarea;
        RETURN NULL;
    END IF;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER reltar_verificar_sincronizacion
  BEFORE UPDATE OF vencimiento_sincronizacion
  ON reltar
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_sincronizacion();
  