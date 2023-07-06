CREATE OR REPLACE VIEW control_hojas_ruta AS
SELECT v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, 
    v.encuestador, COALESCE(p.apellido, null)::text AS nombreencuestador,
    v.recepcionista, COALESCE(s.apellido, null)::text AS nombrerecepcionista, 
    v.ingresador, COALESCE(n.apellido, null)::text AS nombreingresador,
    v.supervisor, COALESCE(r.apellido, null)::text AS nombresupervisor, 
    v.formulario, f.nombreformulario, f.operativo, v.razon, r_1.razon as razonanterior, v.visita, i.nombreinformante, i.direccion, 
    i.conjuntomuestral, i.ordenhdr, ri.observaciones, ri.observaciones_campo, ri.fechasalidahasta, rt.modalidad, rt_1.modalidad modalidad_ant,
    i.telcontacto, i.web, i.email, ri.codobservaciones
   FROM cvp.relvis v
   JOIN cvp.informantes i ON v.informante = i.informante
   JOIN cvp.formularios f ON v.formulario = f.formulario
   LEFT JOIN cvp.relpantarinf ri ON v.periodo = ri.periodo AND v.informante = ri.informante AND v.visita = ri.visita and v.panel = ri.panel and v.tarea = ri.tarea
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
   
GRANT SELECT ON TABLE control_hojas_ruta TO cvp_usuarios;