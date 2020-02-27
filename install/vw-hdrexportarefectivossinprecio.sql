CREATE OR REPLACE VIEW hdrexportarefectivossinprecio AS 
SELECT c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista,
  c.razon, c.visita, c.nombreinformante, c.direccion, 
  c.formulario, c.nombreformulario, (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
  c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.rubro, r.nombrerubro, a.maxperiodoinformado, p.tipoprecios
FROM (SELECT * FROM cvp.control_hojas_ruta WHERE razon = 1) c
   INNER JOIN (SELECT periodo, informante, visita, formulario, 
                 CASE WHEN min(precio) is null and max(precio) is null /*AND min(tipoprecio) is null and max(tipoprecio) is null*/ THEN 'NO HAY PRECIO'
                   ELSE 'HAY PRECIO'
                   END as infoprecios, string_agg(distinct (coalesce(tipoprecio,'Sin Valor'))::text,';') as tipoprecios
                 FROM cvp.relpre 
                 GROUP BY periodo, informante, visita, formulario) p ON c.periodo = p.periodo and c.informante = p.informante and c.visita = p.visita and c.formulario = p.formulario 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE razon = 1
                GROUP BY informante,visita) a ON c.informante = a.informante AND c.visita = a.visita
   WHERE infoprecios = 'NO HAY PRECIO';

GRANT SELECT ON TABLE hdrexportarefectivossinprecio TO cvp_usuarios;
