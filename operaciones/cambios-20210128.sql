set search_path = cvp;

DROP SEQUENCE IF EXISTS secuencia_requerimientos CASCADE;
DROP SEQUENCE IF EXISTS secuencia_cambioPanTar_lote CASCADE;

CREATE SEQUENCE secuencia_cambioPanTar_lote;

ALTER SEQUENCE secuencia_cambioPanTar_lote
    OWNER TO cvpowner;

GRANT SELECT, USAGE ON SEQUENCE secuencia_cambiopantar_lote TO cvp_administrador;

DROP TABLE IF EXISTS requerimientos CASCADE;
DROP TABLE IF EXISTS req_cambiospantar CASCADE;
DROP TABLE IF EXISTS cambiopantar_lote CASCADE;

CREATE TABLE cambiopantar_lote
(
    id_lote integer NOT NULL DEFAULT nextval('cvp.secuencia_cambiopantar_lote'),
    fecha_lote date NOT NULL DEFAULT CURRENT_DATE,
    fechaprocesado timestamp without time zone, 
    PRIMARY KEY (id_lote)
);

ALTER TABLE cambiopantar_lote
    OWNER to cvpowner;

GRANT INSERT, UPDATE, SELECT ON TABLE cambiopantar_lote TO cvp_administrador;


CREATE OR REPLACE FUNCTION verificar_procesar_lote_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
BEGIN
  if TG_OP='UPDATE' then
    if OLD.fechaprocesado is null and NEW.fechaprocesado is not null
    then
      --activar la tarea, si no está activa	
      UPDATE cvp.tareas t SET activa = 'S' 
      FROM (SELECT distinct tarea_nueva FROM cvp.cambiopantar_det WHERE id_lote = NEW.id_lote) r
              WHERE t.tarea = r.tarea_nueva AND COALESCE(t.activa, 'N') = 'N';
      --activar la pantar, si no está activa
      UPDATE cvp.pantar pt SET activa = 'S' 
      FROM (SELECT distinct panel_nuevo, tarea_nueva FROM cvp.cambiopantar_det WHERE id_lote = NEW.id_lote) r
              WHERE pt.panel = r.panel_nuevo and pt.tarea = r.tarea_nueva AND COALESCE(pt.activa, 'N') = 'N';
      --agregar a pantar como activa, si no está
      INSERT INTO cvp.pantar (panel, tarea, activa) 
        (SELECT DISTINCT panel_nuevo, tarea_nueva, 'S' as activa 
           FROM cvp.cambiopantar_det r 
           JOIN cvp.tareas t ON r.tarea = t.tarea 
           LEFT JOIN cvp.pantar pt ON r.panel_nuevo = pt.panel AND r.tarea_nueva = pt.tarea 
           WHERE t.activa = 'S' AND pt.panel is null AND id_lote = NEW.id_lote);
      --cambiar el panel, tarea
      UPDATE cvp.relvis r SET panel = panel_nuevo, tarea= tarea_nueva 
        FROM cvp.cambiopantar_det pt 
        WHERE id_lote = NEW.id_lote AND r.periodo = pt.periodo AND r.informante = pt.informante AND r.panel = pt.panel AND r.tarea = pt.tarea;
      --agreagar a reltar
      INSERT INTO cvp.reltar (periodo,panel,tarea,encuestador) 
        (SELECT DISTINCT v.periodo, v.panel, v.tarea, t.encuestador 
           FROM cvp.cambiopantar_det cpt
           JOIN cvp.relvis v ON cpt.periodo = v.periodo AND cpt.informante = v.informante and cpt.panel_nuevo = v.panel and cpt.tarea_nueva = v.tarea
           JOIN cvp.tareas t ON v.tarea = t.tarea
           JOIN cvp.pantar pt ON cpt.panel_nuevo = pt.panel AND cpt.tarea_nueva = pt.tarea	  
           LEFT JOIN cvp.reltar rt ON v.periodo = rt.periodo and v.panel = rt.panel and v.tarea = rt.tarea  
           WHERE t.activa = 'S' AND pt.activa = 'S' and rt.periodo is null and id_lote = NEW.id_lote);
    end if;
  end if;
  RETURN NEW;
END;
$BODY$;

ALTER FUNCTION verificar_procesar_lote_trg()
    OWNER TO cvpowner;

CREATE TRIGGER cambiopantar_lote_proc_trg
    BEFORE INSERT OR UPDATE 
    ON cambiopantar_lote
    FOR EACH ROW
    EXECUTE PROCEDURE verificar_procesar_lote_trg();