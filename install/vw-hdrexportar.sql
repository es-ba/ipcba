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

GRANT SELECT ON TABLE hdrexportar TO cvp_usuarios;
