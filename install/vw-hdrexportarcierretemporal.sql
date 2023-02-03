CREATE OR REPLACE VIEW hdrexportarcierretemporal AS  ----informantes/hoja de ruta/cierre temporal
SELECT c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, 
  CASE
    WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
    ELSE COALESCE(min(c.razon) || ''::text, ''::text)
  END as razon, c.visita, c.nombreinformante, c.direccion, string_agg(formulario::text||':'||nombreformulario, '|') as formularios, 
  (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
  c.conjuntomuestral, c.ordenhdr, distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado,
  c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant, c.telcontacto, c.web, c.email
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
   c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant, c.telcontacto, c.web, c.email;

GRANT SELECT ON TABLE hdrexportarcierretemporal TO cvp_usuarios;
