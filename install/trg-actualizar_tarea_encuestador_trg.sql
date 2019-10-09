CREATE FUNCTION actualizar_tarea_encuestador_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER 
AS $BODY$
DECLARE
venc character varying(10);

BEGIN
  
 IF new.tarea is distinct from old.tarea  THEN
   SELECT encuestador INTO venc
      FROM cvp.tareas
      WHERE tarea=new.tarea;
   IF venc is not null and venc is distinct from old.encuestador and new.razon is null and new.ingresador is null and new.fechaingreso is null THEN
         new.encuestador= venc;
   END IF;
 END IF;
 RETURN NEW;

END;
$BODY$;

CREATE TRIGGER relvis_actualiza_encuestador_trg
    BEFORE UPDATE 
    ON relvis
    FOR EACH ROW
    EXECUTE PROCEDURE actualizar_tarea_encuestador_trg();