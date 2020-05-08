CREATE OR REPLACE FUNCTION verificar_cargado_dm()
    RETURNS trigger
    LANGUAGE 'plpgsql' VOLATILE
AS $BODY$
DECLARE
vtabla       varchar(100);
vcambiatoken boolean;
BEGIN
vtabla= TG_TABLE_NAME;
CASE
    WHEN vtabla='relvis' THEN
        vcambiatoken = TG_OP = 'UPDATE' AND new.token_relevamiento IS DISTINCT FROM old.token_relevamiento;
		IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(vcambiatoken, old.periodo, old.panel, old.tarea, old.informante);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.panel, new.tarea, new.informante)<>(old.periodo, old.panel, old.tarea, old.informante) THEN
            perform cvp.controlar_estado_carga(vcambiatoken, new.periodo, new.panel, new.tarea, new.informante);
        END IF;
    WHEN vtabla='relpre' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, old.periodo, null, null, old.informante, old.visita, old.formulario);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.formulario)<>(old.periodo, old.formulario) THEN
            perform cvp.controlar_estado_carga(false, new.periodo, null, null, new.informante, new.visita, new.formulario);
        END IF;
    WHEN vtabla='relatr' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, old.periodo, null, null, old.informante, old.visita, null, old.producto, old.observacion);
        END IF;
        IF TG_OP = 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, new.periodo, null, null, new.informante, new.visita, null, new.producto, new.observacion);
        END IF;
END CASE;
IF TG_OP='DELETE' THEN
   RETURN OLD;
ELSE  
   RETURN NEW;
END IF;
END;
$BODY$;

CREATE TRIGGER relvis_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();

CREATE TRIGGER relpre_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();

CREATE TRIGGER relatr_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();