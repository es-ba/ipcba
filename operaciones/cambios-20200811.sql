set search_path = cvp;

--ALTER TABLE pantar DROP COLUMN activa;
ALTER TABLE pantar ADD COLUMN activa cvp.sino_dom;
GRANT UPDATE, INSERT ON TABLE pantar TO cvp_administrador;

--seteo activas los paneles-tarea que están en a2020m08 (todos los paneles están generados)
UPDATE pantar pt SET activa= 'S' 
FROM (SELECT p.panel, p.tarea 
      FROM pantar p
	  JOIN (SELECT distinct periodo, panel, tarea
	             FROM relvis r
				 WHERE periodo = 'a2020m08') v
	  ON p.tarea = v.tarea AND p.panel = v.panel
	  WHERE p.activa is null order by panel, tarea) q
WHERE pt.panel = q.panel AND pt.tarea = q.tarea;

--seteo no activas los paneles-tarea restantes
UPDATE pantar SET activa = 'N' WHERE activa is null;

--generacion de paneles para panel-tarea activas:
CREATE OR REPLACE FUNCTION cvp.generar_panel(
	pperiodo text,
	ppanel integer,
	pfechasalida date,
	pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
AS $BODY$
DECLARE
  f_hoy date= current_date;
BEGIN
  /*
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
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador
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
		
  INSERT INTO cvp.relinf(periodo, informante, visita)
    SELECT DISTINCT v.periodo, v.informante, v.visita
      FROM cvp.relvis v
      LEFT JOIN cvp.relinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

  --Si se modifica el encuestador de una tarea, hay que volver a generar el panel que aún no haya salido,
  --se cambiarán los encuestadores de los paneles siguientes para las tareas correspondientes
  UPDATE cvp.reltar r SET encuestador= s.encuestador
        FROM (SELECT p.periodo, p.panel, t.tarea, a.encuestador 
                FROM cvp.relpan p 
                  INNER JOIN cvp.pantar t ON p.panel= t.panel  
                  INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
                  LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
                  WHERE p.periodo=pperiodo AND p.panel= ppanel AND p.fechasalida > f_hoy AND a.activa = 'S' AND   --tareas activas
                        x.periodo IS NOT NULL
              ) as s
        WHERE r.periodo=s.periodo AND r.panel= s.panel and r.tarea=s.tarea AND s.encuestador IS DISTINCT FROM r.encuestador ;

  RETURN NULL;
END
$BODY$;

------------------------------------------------------
----periodoalta
set search_path = cvp;
CREATE OR REPLACE VIEW hdrexportar AS 
 SELECT c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante as ti, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista,
   c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor,
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon, 
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|'::text) AS formularios, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
    c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, 
    a.maxperiodoinformado, a.minperiodoinformado, a.periodoalta
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, 
    c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, 
    a.minperiodoinformado, a.periodoalta;
	
CREATE OR REPLACE VIEW hdrexportarteorica AS 
 SELECT c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante as ti, t.encuestador||':'||p.nombre||' '||p.apellido as encuestador,
   COALESCE(string_agg(distinct c.encuestador||':'||c.nombreencuestador, '|'::text),null) as encuestadores, 
   COALESCE(string_agg(distinct c.recepcionista||':'||c.nombrerecepcionista, '|'::text),null) as recepcionistas, 
   COALESCE(string_agg(distinct c.ingresador||':'||c.nombreingresador, '|'::text),null) as ingresadores, 
   COALESCE(string_agg(distinct c.supervisor||':'||c.nombresupervisor, '|'::text),null) as supervisores, 
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon,
   string_agg(c.formulario::text || ' '::text || c.nombreformulario::text, chr(10) order by c.formulario) AS formularioshdr,
   lpad(' '::text, count(*)::integer, chr(10)) AS espacio,   
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|') AS formularios, 
   i.contacto::text contacto, 
   c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
   pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.tareas t on c.tarea = t.tarea
   LEFT JOIN cvp.personal p on p.persona = t.encuestador 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
   LEFT JOIN (SELECT informante, visita, string_agg(distinct panel::text,',' order by panel::text) as panelreferencia, string_agg(distinct tarea::text,',' order by tarea::text) as tareareferencia
                FROM cvp.relvis v 
                JOIN cvp.parametros par ON unicoregistro AND v.periodo = par.periodoReferenciaParaPanelTarea
                GROUP BY informante, visita) pt ON c.informante = pt.informante AND c.visita = pt.visita 
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    i.contacto, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
    pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta;
	
CREATE OR REPLACE VIEW hojaderuta AS 
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.fechasalida,
    v.informante,
    i.tipoinformante,
    v.encuestador,
    COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text AS nombreencuestador,
        CASE
            WHEN min(v.razon) <> max(v.razon) THEN (min(v.razon) || '~'::text) || max(v.razon)
            ELSE COALESCE(min(v.razon) || ''::text, ''::text)
        END || lpad(' '::text, count(*)::integer, chr(10)) AS razon,
    v.visita,
    i.nombreinformante,
    i.direccion,
    cvp.formularioshdr(v.periodo::text, v.informante, v.visita, v.fechasalida, v.encuestador) AS formularios,
    lpad(' '::text, count(*)::integer, chr(10)) AS espacio,
    COALESCE(i.contacto,'')||chr(10)||COALESCE(i.telcontacto,'') as contacto,
    i.conjuntomuestral,
    i.ordenhdr,
    a.maxperiodoinformado,
    a.minperiodoinformado,
    a.periodoalta
   FROM cvp.relvis v
     JOIN cvp.informantes i ON v.informante = i.informante
     LEFT JOIN cvp.personal p ON v.encuestador::text = p.persona::text
     LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON v.informante = a.informante AND v.visita = a.visita
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, i.tipoinformante, v.encuestador, v.visita, 
    COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text,
    COALESCE(i.contacto,'')||chr(10)||COALESCE(i.telcontacto,''),    
    i.nombreinformante, i.direccion, i.conjuntomuestral, i.ordenhdr, a.maxperiodoinformado, a.minperiodoinformado, a.periodoalta ;	