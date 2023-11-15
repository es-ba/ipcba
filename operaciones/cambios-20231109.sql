set search_path = cvp;

CREATE OR REPLACE FUNCTION verificar_procesar_lote_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
DECLARE
 vC record;
 vhabilitado boolean;
 vconflicto boolean;
 cParaRecorrerCambios cursor for
   SELECT d.periodo, d.informante, i.visita, d.panel, d.tarea, d.panel_nuevo, d.tarea_nueva
     FROM cvp.cambiopantar_det d 
     JOIN cvp.relpantarinf i ON d.periodo = i.periodo and d.informante = i.informante and d.panel = i.panel and d.tarea = i.tarea
     WHERE id_lote = NEW.id_lote;
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
      --cambiar el panel, tarea en relvis
      UPDATE cvp.relvis r SET panel = panel_nuevo, tarea= tarea_nueva 
        FROM cvp.cambiopantar_det pt 
        WHERE id_lote = NEW.id_lote AND r.periodo = pt.periodo AND r.informante = pt.informante AND r.panel = pt.panel AND r.tarea = pt.tarea;

      --cambiar el panel, tarea en relpantarinf
      FOR vC in cParaRecorrerCambios LOOP
        SELECT 
              b.periodo IS NOT NULL AND 
                 (b.observaciones       IS NOT NULL AND a.observaciones       <> b.observaciones       OR 
                  b.fechasalidadesde    IS NOT NULL AND a.fechasalidadesde    <> b.fechasalidadesde    OR 
                  b.fechasalidahasta    IS NOT NULL AND a.fechasalidahasta    <> b.fechasalidahasta    OR 
                  b.observaciones_campo IS NOT NULL AND a.observaciones_campo <> b.observaciones_campo OR
                  b.codobservaciones    IS NOT NULL AND a.codobservaciones    <> b.codobservaciones    OR 
                  b.recuperos           IS NOT NULL AND a.recuperos           <> b.recuperos) --está la fila con el panel nuevo-tarea nueva y hay conflicto entre lo comentado
              INTO vconflicto 
        FROM 
         (SELECT * FROM cvp.relpantarinf WHERE periodo = vC.periodo AND informante = vC.informante AND visita = vC.visita AND panel = vC.panel       AND tarea = vC.tarea      ) a
         LEFT JOIN
         (SELECT * FROM cvp.relpantarinf WHERE periodo = vC.periodo AND informante = vC.informante AND visita = vC.visita AND panel = vC.panel_nuevo AND tarea = vC.tarea_nueva) b
         ON a.periodo = b.periodo and a.informante = b.informante and a.visita = b.visita;
        IF vconflicto THEN
          --RAISE CON MENSAJE
          RAISE EXCEPTION 'Para periodo %, informante %, visita % Hay conflicto, dejar lo comentado el panel: %, tarea % (origen)',vC.periodo, vC.informante, vC.visita, vC.panel, vc.tarea;
          RETURN NULL;
        ELSE
          --BORRAR
          DELETE FROM cvp.relpantarinf WHERE periodo = vC.periodo AND informante = vC.informante AND visita = vC.visita AND panel = vC.panel_nuevo AND tarea = vC.tarea_nueva;
          --UPDATEAR
          UPDATE cvp.relpantarinf SET panel = vC.panel_nuevo, tarea = vC.tarea_nueva 
          WHERE periodo = vC.periodo AND informante = vC.informante AND visita = vC.visita AND panel = vC.panel AND tarea = vC.tarea;
        END IF;
      END LOOP;
      -- FIN cambiar el panel, tarea en relpantarinf

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
