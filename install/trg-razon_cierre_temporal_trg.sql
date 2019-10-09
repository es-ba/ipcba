CREATE OR REPLACE FUNCTION razon_cierre_temporal_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vescierretemporalfor cvp.razones.escierretemporalfor%type;
 vcantausencias integer;
 vperiodo_1 cvp.relvis.periodo%type;
 vperiodo_2 cvp.relvis.periodo%type;
BEGIN
IF OLD.razon IS DISTINCT FROM NEW.razon or OLD.comentarios IS DISTINCT FROM NEW.comentarios THEN
    SELECT escierretemporalfor INTO vescierretemporalfor
      FROM  cvp.razones 
      WHERE razon=NEW.razon;
    --La nueva razon es cierre temporal, me fijo que pasó en los dos periodos anteriores
    IF vescierretemporalfor='S' THEN
        vperiodo_1:= cvp.moverperiodos(new.periodo, -1); 
        vperiodo_2:= cvp.moverperiodos(new.periodo, -2);
        SELECT count(*) INTO vcantausencias
            FROM cvp.relvis r
              LEFT JOIN cvp.razones z ON r.razon = z.razon  
            WHERE r.periodo IN (vperiodo_1, vperiodo_2) and z.escierretemporalfor = 'S' and r.visita = NEW.visita and r.formulario = NEW.formulario and r.informante = NEW.informante ;
        IF vcantausencias = 2 AND NEW.comentarios is null THEN
            RAISE EXCEPTION 'Tercer mes de ausencia/cierre temporal. Debe ingresar observaciones';
            RETURN NULL;
        END IF;
    END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER relvis_razon_cierre_temporal_trg
  BEFORE UPDATE
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE razon_cierre_temporal_trg();
