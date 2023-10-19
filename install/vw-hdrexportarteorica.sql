CREATE OR REPLACE VIEW hdrexportarteorica AS  ----informantes/hoja de ruta/teorica
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
   pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad, q.otropaneltarea, i.cadena
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
    LEFT JOIN cvp.reltar pta on c.periodo = pta.periodo and c.panel = pta.panel and c.tarea = pta.tarea
    LEFT JOIN (SELECT periodo, informante, string_agg('Panel '||panel||' , '||'Tarea '||tarea, chr(10) order by 'Panel '||panel||' , '||'Tarea '||tarea) as otropaneltarea
                 FROM (SELECT DISTINCT periodo, informante, panel, tarea from relvis) r
                 GROUP BY periodo, informante
                 HAVING COUNT(DISTINCT (panel, tarea)) > 1) q ON c.periodo = q.periodo and c.informante = q.informante
GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    i.contacto, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
    pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad, q.otropaneltarea, i.cadena;

GRANT SELECT ON TABLE hdrexportarteorica TO cvp_usuarios;
