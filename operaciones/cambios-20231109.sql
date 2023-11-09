set search_path = cvp;

-- FUNCTION: cvp.generar_panel(text, integer, date, timestamp without time zone)

-- DROP FUNCTION cvp.generar_panel(text, integer, date, timestamp without time zone);

CREATE OR REPLACE FUNCTION cvp.generar_panel(
    pperiodo text,
    ppanel integer,
    pfechasalida date,
    pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  f_hoy date= current_date;
BEGIN
  /*
   V230705
      genera filas para relpantarinf
   V190117
      genera el encuestador a partir de la tabla reltar
   V161201
      genera el encuestador a partir de la tabla relenc (si no hay relenc, entonces en tareas)
   V100730
      con borrado previo al insert por considerar re-generacion   
   V100726
      genera también las altas manuales. 
   V100527
      genera con última visita periodo anterior, única razon en relvis (informante-formulario)
   V100515
      genera el encuestador a partir de la tabla tareas
   V100508
      sin generar informantes con cierre definitivo en visita 1 del periodo anterior
     V080924
      sin generar de baja
  */
  if pFechaSalida is null then
    RAISE EXCEPTION 'no se puede generar un panel sin fecha de salida';
  end if;
  insert into cvp.bitacora (que) values ('nueva generacion panel '||pPeriodo||' p:'||pPanel||' g:'||pFechaGeneracionPanel);

  DELETE FROM cvp.relvis rd USING
    (SELECT r.periodo, r.informante, r.formulario, r.visita
      FROM cvp.relvis r
         LEFT JOIN cvp.informantes i ON r.informante = i.informante
         LEFT JOIN cvp.periodos p ON r.periodo=p.periodo
         LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior
                                    AND r_1.informante = r.informante 
                                    AND r_1.formulario = r.formulario
                                    AND r_1.visita = r.visita          
 
         --LEFT JOIN cvp.relvis r_1 ON r_1.periodo = r.periodo_1
         --                           AND r_1.informante = r.informante 
         --                           AND r_1.formulario = r.formulario
         --                           AND r_1.visita = r.visita_1          
         LEFT JOIN cvp.razones z ON r_1.razon = z.razon
         LEFT JOIN (SELECT distinct periodo, informante, visita, formulario, 'S' hayprecios 
                      FROM cvp.relpre) pr ON pr.periodo = r.periodo
                        AND pr.informante = r.informante
                        AND pr.visita = r.visita 
                        AND pr.formulario = r.formulario 
       WHERE r.periodo = Pperiodo
         AND r.panel= pPanel
         --AltaManualPeriodo no es el periodo actual
         AND (i.AltaManualPeriodo IS DISTINCT FROM Pperiodo OR NOT EXISTS (SELECT 1 FROM cvp.forinf fi WHERE fi.informante=r.informante AND fi.formulario=r.formulario))
         --periodo anterior sin visita en relvis o con cierre definitivo  
         AND (r_1.periodo IS NULL OR COALESCE(z.escierredefinitivoinf,'N')='S' OR COALESCE(z.escierredefinitivofor,'N')='S')
         -- periodo actual sin razon ingresada y sin precios
         AND r.razon IS NULL AND COALESCE(hayprecios,'N') = 'N') d
  WHERE rd.periodo = d.periodo and rd.informante = d.informante and rd.formulario = d.formulario and rd.visita = d.visita ;
  --08/01/19: todas las tareas a reltar en el momento de la generación del panel (hasta ahora se insertaban en el momento de preparar la supervisión):
  --14/02/19: las tareas que tuvieron por lo menos una respuesta positiva (o nula) el periodo anterior
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador, modalidad, visiblepararelevamiento)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.reltar x_1  ON x_1.periodo = cvp.moverperiodos(p.periodo, -1) AND x_1.panel = p.panel and x_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
        HAVING string_agg(COALESCE(z.escierredefinitivoinf,'N'),'') like '%N%' AND string_agg(COALESCE(z.escierredefinitivofor,'N'),'') like'%N%'
        ORDER BY p.periodo, p.panel, t.tarea;
  --11/08/2020: tareas nuevas (agregadas a pantar)
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador)
      SELECT pperiodo as periodo, t.panel, t.tarea, a.encuestador
        FROM cvp.pantar t   
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          LEFT JOIN cvp.reltar x ON x.periodo= pperiodo AND x.panel=t.panel AND x.tarea= t.tarea --pk verificada
        WHERE t.panel= ppanel AND a.activa = 'S' --tareas activas
              AND t.activa = 'S' --paneles-tarea activas
              AND x.periodo IS NULL
        ORDER BY t.panel, t.tarea;

  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT p.periodo, r_1.informante, 1, r_1.formulario, r_1.panel, r_1.tarea, pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.relvis r_1 INNER JOIN cvp.periodos p ON r_1.periodo=p.periodoanterior
        INNER JOIN cvp.formularios f ON f.formulario=r_1.formulario
        --INNER JOIN cvp.tareas t ON t.tarea=r_1.tarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=r_1.panel and e.tarea=r_1.tarea
        LEFT JOIN (SELECT periodo, informante, formulario, max(visita) AS maxvisita
                     FROM cvp.relvis
                     WHERE panel = pPanel
                     GROUP BY  periodo, informante, formulario) v ON v.periodo=r_1.periodo and v.informante = r_1.informante and v.formulario = r_1.formulario
        LEFT JOIN cvp.razones z ON r_1.razon = z.razon         
        LEFT JOIN cvp.relvis r ON r.periodo=p.periodo AND r.informante=r_1.informante AND r.visita=1 AND r.formulario=r_1.formulario 
      WHERE p.periodo=pPeriodo
        AND r_1.panel=pPanel
        AND r_1.visita=maxvisita
        AND COALESCE(z.escierredefinitivoinf,'N')='N'
        AND COALESCE(z.escierredefinitivofor,'N')='N'
        AND f.activo='S'
        AND r.periodo IS NULL;
  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT i.altaManualPeriodo, i.informante, 1, fi.formulario, i.altaManualPanel, i.altaManualTarea, 
           pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.informantes i 
        INNER JOIN cvp.forinf fi ON i.informante=fi.informante 
        INNER JOIN cvp.formularios f ON f.formulario=fi.formulario
        INNER JOIN cvp.periodos p ON p.periodo=i.altaManualPeriodo
        --INNER JOIN cvp.tareas t ON t.tarea=i.altaManualTarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=i.altaManualPanel and e.tarea=i.altaManualTarea
        LEFT JOIN cvp.relvis r ON r.periodo=i.altaManualPeriodo AND r.informante=i.informante AND r.visita=1 AND r.formulario=fi.formulario 
      WHERE p.periodo=pPeriodo
        AND r.periodo IS NULL
        AND f.activo='S'
        AND fi.altaManualPeriodo=pPeriodo
        AND i.altaManualPeriodo=pPeriodo
        AND i.altaManualPanel=pPanel;

--9/11/23 descontinuamos el uso de relinf, reemplazado por relpantarinf
--9/11/23 Borrado en relpantarinf de las filas que se borraron de relvis 
  DELETE FROM cvp.relpantarinf d USING
   (SELECT DISTINCT i.periodo, i.informante, i.visita, i.panel, i.tarea
      FROM cvp.relpantarinf i 
      LEFT JOIN cvp.relvis v ON i.periodo = v.periodo and i.informante = v.informante and i.visita = v.visita and i.panel = v.panel and i.tarea = v.tarea
      WHERE i.periodo = Pperiodo
        AND i.panel= pPanel 
        AND v.periodo IS NULL) rpi
    WHERE d.periodo = rpi.periodo AND d.informante = rpi.informante AND d.visita = rpi.visita AND d.panel = rpi.panel AND d.tarea = rpi.tarea;
  
  INSERT INTO cvp.relpantarinf(periodo, informante, visita, panel, tarea)
    SELECT v.periodo, v.informante, v.visita, v.panel, v.tarea
      FROM cvp.relvis v
      LEFT JOIN cvp.relpantarinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita and v.panel = i.panel and v.tarea = i.tarea 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

  RETURN NULL;
END
$BODY$;


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
