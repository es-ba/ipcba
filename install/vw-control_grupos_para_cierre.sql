CREATE OR REPLACE VIEW control_grupos_para_cierre AS 
SELECT x.periodo, x.calculo, x.agrupacion, x.grupo, x.nombregrupo as nombre, x.nivel, c.variacion, c.incidencia, 
       c.variacioninteranualredondeada, c.incidenciainteranual, x.ponderador, 
       x.cantincluidos, x.cantrealesincluidos, x.cantimputados, 'Z'||substr(x.grupo,2) as ordenpor
  FROM (SELECT d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre as grupo, g.nombregrupo, g.ponderador, g.nivel, 
             sum(d.cantincluidos) cantincluidos, sum(d.cantrealesincluidos) cantrealesincluidos, sum(d.cantimputados) cantimputados 
        FROM cvp.caldiv d
        LEFT JOIN cvp.gru_prod gp ON d.producto=gp.producto
        LEFT JOIN cvp.grupos g ON gp.grupo_padre = g.grupo AND gp.agrupacion = g.agrupacion
        LEFT JOIN cvp.agrupaciones a ON gp.agrupacion = a.agrupacion 
        WHERE d.division = '0' and a.tipo_agrupacion = 'INDICE' and d.calculo = 0
        GROUP BY d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre, g.nombregrupo, g.ponderador, g.nivel) as x
      LEFT JOIN cvp.calgru_vw c ON c.periodo = x.periodo and c.calculo = x.calculo and c.agrupacion = x.agrupacion and c.grupo = x.grupo 
   ORDER BY ordenpor;
  
GRANT SELECT ON TABLE control_grupos_para_cierre TO cvp_administrador;
