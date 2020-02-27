CREATE OR REPLACE VIEW hdrexportar AS 
 SELECT c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante as ti, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista,
   c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor,
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon, 
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|'::text) AS formularios, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
    c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado, min(periodo) AS minperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE control_hojas_ruta.razon = 1
                GROUP BY informante, visita) a ON c.informante = a.informante AND c.visita = a.visita
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, 
    c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado;

GRANT SELECT ON TABLE hdrexportar TO cvp_usuarios;
