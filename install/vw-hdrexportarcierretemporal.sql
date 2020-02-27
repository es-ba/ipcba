CREATE OR REPLACE VIEW hdrexportarcierretemporal AS 
SELECT c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, 
  CASE
    WHEN min(razon) <> max(razon) THEN (min(razon) || '~'::text) || max(razon)
    ELSE COALESCE(min(razon) || ''::text, ''::text)
  END as razon, c.visita, c.nombreinformante, c.direccion, string_agg(formulario::text||':'||nombreformulario, '|') as formularios, 
  (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
  c.conjuntomuestral, c.ordenhdr, distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado
FROM cvp.control_hojas_ruta c 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE razon = 1
                GROUP BY informante,visita) a ON c.informante = a.informante AND c.visita = a.visita
   WHERE c.razon IN (5,6,12)
   GROUP BY c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, c.visita, c.nombreinformante, c.direccion, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text,  c.conjuntomuestral, c.ordenhdr, 
   distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado;

GRANT SELECT ON TABLE hdrexportarcierretemporal TO cvp_usuarios;
