CREATE OR REPLACE VIEW reemplazosexportar AS 
 SELECT 
   v.periodo,
   v.panel,
   v.tarea,
   v.fechasalida,
   ii.conjuntomuestral,
   v.encuestador,
   COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text AS nombreencuestador,
   v.visita,
   regexp_replace(cvp.formularioshdr(v.periodo::text, v.informante, v.visita, v.fechasalida, v.encuestador),chr(10),' | ', 'g') AS formularios,
   CASE WHEN ii.informante = v.informante THEN 'Titular' ELSE 'Reemplazo' END as tipoinformante,
   ii.informante,
   ii.nombreinformante,
   ii.direccion,
   ii.ordenhdr,
   ii.distrito,
   ii.fraccion_ant,
   ii.rubro,
   r.nombrerubro
   FROM cvp.relvis v
     INNER JOIN (SELECT periodo FROM cvp.periodos WHERE ingresando = 'N' ORDER BY periodo DESC LIMIT 1) e ON v.periodo = e.periodo
     INNER JOIN cvp.informantes i ON v.informante = i.informante
     INNER JOIN cvp.informantes ii ON ii.conjuntomuestral = i.conjuntomuestral
     INNER JOIN cvp.personal p ON v.encuestador::text = p.persona::text
     INNER JOIN cvp.rubros r ON ii.rubro = r.rubro
     LEFT JOIN (SELECT distinct informante, conjuntomuestral, 1 AS estaenhojaderuta FROM cvp.hojaderuta) h ON ii.conjuntomuestral = h.conjuntomuestral and ii.informante = h.informante
     WHERE CASE WHEN ii.informante = v.informante THEN 'Titular' ELSE 'Reemplazo' END = 'Titular' OR estaenhojaderuta is null  
     GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, ii.conjuntomuestral, v.encuestador, 
       COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text, v.visita, 
       CASE WHEN ii.informante = v.informante THEN 'Titular' ELSE 'Reemplazo' END, v.informante, ii.informante,    
       ii.nombreinformante, ii.direccion,  ii.ordenhdr, ii.distrito, ii.fraccion_ant, ii.rubro, r.nombrerubro 
     ORDER BY v.panel, v.tarea, ii.conjuntomuestral, CASE WHEN ii.informante = v.informante THEN 'Titular' ELSE 'Reemplazo' END desc, ii.informante;

GRANT SELECT ON TABLE reemplazosexportar TO cvp_usuarios;
