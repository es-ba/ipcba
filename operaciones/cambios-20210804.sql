set search_path = cvp;
CREATE OR REPLACE VIEW control_generacion_formularios AS 
 SELECT p.periodo, r_1.panel, r_1.tarea, r_1.informante, r_1.formulario, r_1.visita, r_1.razon AS razonant, r.razon,
   CASE WHEN r.periodo IS NULL AND z.escierredefinitivoinf = 'N' AND z.escierredefinitivofor = 'N' THEN 'Falta generar'
        WHEN r.periodo IS NOT NULL AND r.razon IS NULL THEN 'Razon en blanco'
        WHEN r.razon IS NOT NULL AND pr.tieneprecio IS DISTINCT FROM 1 THEN 
                        CASE WHEN fp.tieneproductos=1 THEN 'Sin precios'
                             ELSE 'Sin productos'
                        END     
        ELSE 'Error no contemplado' 
   END AS descripcion, r.panel as panelactual, r.tarea as tareaactual 
   FROM relvis r_1
   JOIN formularios f ON r_1.formulario = f.formulario 
   JOIN periodos p ON r_1.periodo = p.periodoanterior --pk verificada
   JOIN razones z ON r_1.razon = z.razon  --pk verificada
   LEFT JOIN relvis r ON r.periodo = p.periodo AND r.informante = r_1.informante AND r.formulario = r_1.formulario AND r.visita = r_1.visita -- verificado
   LEFT JOIN ( SELECT DISTINCT relpre.periodo, relpre.informante, relpre.formulario, relpre.visita, 1 AS tieneprecio
                   FROM relpre
              ) pr ON pr.periodo = r.periodo AND pr.informante = r.informante AND pr.formulario = r.formulario AND pr.visita = r.visita --pk verificada
   LEFT JOIN ( SELECT distinct f.formulario, 1 as tiene_vigencia
                   FROM forProd f 
                        INNER JOIN prodatr pa  ON f.producto= pa.producto 
                        INNER JOIN atributos a ON a.atributo=pa.atributo AND a.es_vigencia=TRUE
                   GROUP BY f.formulario   
              ) e ON e.formulario=r_1.formulario
   LEFT JOIN (SELECT distinct f.formulario, 1 as tieneproductos
                   FROM forprod f) as fp ON fp.formulario= r_1.formulario
   WHERE ((r.periodo IS NULL AND z.escierredefinitivoinf = 'N' AND z.escierredefinitivofor = 'N' AND e.tiene_vigencia IS DISTINCT FROM 1) OR
         (r.periodo IS NOT NULL AND r.razon IS NULL) OR
         (r.periodo IS NOT NULL AND r.razon IS NOT NULL AND pr.tieneprecio IS DISTINCT FROM 1))
         AND f.activo= 'S'
UNION 
  SELECT rv.periodo, rv.panel, rv.tarea, rv.informante, rv.formulario, rv.visita, r_ant.razon as razonant, rv.razon, 'Razon en blanco' as descripcion, 
    rv.panel as panelactual, rv.tarea as tareaactual
  FROM relvis rv
  JOIN periodos pp ON rv.periodo = pp.periodo
  LEFT JOIN relvis r_ant on pp.periodoanterior = r_ant.periodo and rv.informante = r_ant.informante and rv.formulario = r_ant.formulario and rv.visita = r_ant.visita 
  WHERE rv.razon is null and r_ant.periodo is null
ORDER BY periodo, panel, tarea, informante, formulario, visita;