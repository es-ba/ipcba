CREATE OR REPLACE VIEW control_productos_para_cierre AS 
SELECT o.periodo, o.calculo, o.producto, p.nombreproducto, g.variacion, g.incidencia,
o.cantincluidos, o.cantrealesincluidos, o.cantimputados,
round((round(s.promdiv::decimal,2)/round(s0.promdiv::decimal,2)*100-100)::decimal,1) as s_variacion,  
s.cantincluidos s_cantincluidos, s.cantrealesincluidos s_cantrealesincluidos, s.cantimputados s_cantimputados,
round((round(t.promdiv::decimal,2)/round(t0.promdiv::decimal,2)*100-100)::decimal,1) as t_variacion,   
t.cantincluidos t_cantincluidos, t.cantrealesincluidos t_cantrealesincluidos, t.cantimputados t_cantimputados  
FROM
  (SELECT v.* FROM cvp.caldiv v JOIN calculos_def cd on v.calculo = cd.calculo WHERE  v.division = '0' and cd.principal) o
  LEFT JOIN cvp.periodos r on o.periodo = r.periodo  
  LEFT JOIN (SELECT v.* FROM cvp.caldiv v JOIN calculos_def cd on v.calculo = cd.calculo WHERE cd.principal and division = 'S' and v.calculo >= cd.calculo) s on o.periodo = s.periodo and o.calculo = s.calculo and o.producto = s.producto 
  LEFT JOIN (SELECT v.* FROM cvp.caldiv v JOIN calculos_def cd on v.calculo = cd.calculo WHERE cd.principal and division = 'S' and v.calculo >= cd.calculo) s0 on s0.periodo = r.periodoanterior and s0.calculo = s.calculo and s0.producto = s.producto and s0.division = s.division 
  LEFT JOIN (SELECT v.* FROM cvp.caldiv v JOIN calculos_def cd on v.calculo = cd.calculo WHERE cd.principal and division = 'T' and v.calculo >= cd.calculo) t on s.periodo = t.periodo and s.calculo = t.calculo and s.producto = t.producto 
  LEFT JOIN (SELECT v.* FROM cvp.caldiv v JOIN calculos_def cd on v.calculo = cd.calculo WHERE cd.principal and division = 'T' and v.calculo >= cd.calculo) t0 on t0.periodo = r.periodoanterior and t.calculo = t0.calculo and t.producto = t0.producto and t.division = t0.division 
  LEFT JOIN cvp.productos p on o.producto = p.producto 
  LEFT JOIN (SELECT * FROM cvp.calgru WHERE  esproducto = 'S' and agrupacion = 'Z') g on g.periodo = o.periodo and g.calculo = o.calculo and g.grupo = o.producto;
  
GRANT SELECT ON TABLE control_productos_para_cierre TO cvp_administrador;

