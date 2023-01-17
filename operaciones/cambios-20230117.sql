set search_path = cvp;

CREATE OR REPLACE VIEW control_hojas_ruta AS
SELECT v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, 
    v.encuestador, COALESCE(p.apellido, null)::text AS nombreencuestador,
    v.recepcionista, COALESCE(s.apellido, null)::text AS nombrerecepcionista, 
    v.ingresador, COALESCE(n.apellido, null)::text AS nombreingresador,
    v.supervisor, COALESCE(r.apellido, null)::text AS nombresupervisor, 
    v.formulario, f.nombreformulario, f.operativo, v.razon, r_1.razon as razonanterior, v.visita, i.nombreinformante, i.direccion, 
    i.conjuntomuestral, i.ordenhdr, ri.observaciones, ri.observaciones_campo, ri.fechasalidahasta, rt.modalidad, rt_1.modalidad modalidad_ant
   FROM cvp.relvis v
   JOIN cvp.informantes i ON v.informante = i.informante
   JOIN cvp.formularios f ON v.formulario = f.formulario
   LEFT JOIN cvp.relinf ri ON v.periodo = ri.periodo AND v.informante = ri.informante AND v.visita = ri.visita
   LEFT JOIN cvp.reltar rt ON v.periodo = rt.periodo AND v.panel = rt.panel AND v.tarea = rt.tarea
   LEFT JOIN cvp.personal p ON v.encuestador = p.persona
   LEFT JOIN cvp.personal s ON v.recepcionista = s.persona
   LEFT JOIN cvp.personal n ON v.ingresador = n.persona
   LEFT JOIN cvp.personal r ON v.supervisor = r.persona
   LEFT JOIN cvp.periodos o ON v.periodo = o.periodo
   LEFT JOIN cvp.relvis r_1 ON r_1.periodo=
        CASE
          WHEN v.visita > 1 THEN v.periodo
          ELSE o.periodoanterior
        END AND (r_1.ultima_visita = true AND v.visita = 1 OR v.visita > 1 AND r_1.visita = (v.visita - 1)) 
        AND r_1.informante = v.informante AND r_1.formulario = v.formulario
   LEFT JOIN cvp.reltar rt_1 ON r_1.periodo = rt_1.periodo AND r_1.panel = rt_1.panel AND r_1.tarea = rt_1.tarea
   order by v.periodo, v.panel, v.tarea, v.informante, v.formulario;
   
CREATE OR REPLACE VIEW hdrexportarcierretemporal AS 
SELECT c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, 
  CASE
    WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
    ELSE COALESCE(min(c.razon) || ''::text, ''::text)
  END as razon, c.visita, c.nombreinformante, c.direccion, string_agg(formulario::text||':'||nombreformulario, '|') as formularios, 
  (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
  c.conjuntomuestral, c.ordenhdr, distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado,
  c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant
FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.razones z on c.razon = z.razon 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE razon = 1
                GROUP BY informante,visita) a ON c.informante = a.informante AND c.visita = a.visita
   WHERE z.escierretemporalfor = 'S'
   GROUP BY c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, c.visita, c.nombreinformante, c.direccion, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text,  c.conjuntomuestral, c.ordenhdr, 
   distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado,
   c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant;