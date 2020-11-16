CREATE OR REPLACE VIEW cvp.frecCambio_restorest AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, periodo, grupo, nombregrupo, estado, 
EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
round((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
, x."cluster"
FROM (

SELECT
  o.periodo, g.grupo, g.nombregrupo, 
  CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
       WHEN o.promobs > o1.promobs THEN 'Subió' 
       ELSE 'Igual' 
       END as estado,
  o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
  COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs,
  coalesce(par.solo_cluster, p."cluster") as "cluster",
  gg.grupo_padre
  FROM cvp.calobs o
    LEFT JOIN cvp.calculos c ON o.periodo = c.periodo and o.calculo = c.calculo
    LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior and o1.calculo = c.calculoanterior and 
      o.producto = o1.producto and o.informante = o1.informante and o.observacion = o1.observacion
    LEFT JOIN cvp.productos p on o.producto = p.producto
    LEFT JOIN cvp.gru_grupos gu on gu.agrupacion = 'R' and gu.esproducto = 'S' and gu.grupo = o.producto and length(gu.grupo_padre) = 2
    LEFT JOIN cvp.grupos g on gu.grupo_padre = g.grupo and gu.agrupacion = g.agrupacion
    LEFT JOIN cvp.gru_grupos gg on gg.agrupacion = 'Z' and gg.esproducto = 'S' and gg.grupo = o.producto and length(gg.grupo_padre) = 5  --los niveles 3 para poder excluirlos
    LEFT JOIN cvp.parametros par ON unicoregistro
  WHERE o.calculo = 0 and g.grupo ='R3' and o.impobs = 'R' and o1.impobs = 'R'
  --A Pedido de Mariana excluimos los siguientes grupos:
  and gg.grupo_padre not in 
  ('Z0411',
   'Z0431',
   'Z0432',
   'Z0441',
   'Z0442',
   'Z0533',
   'Z0551',
   'Z0552',
   'Z0562',
   'Z0611',
   'Z0621',
   'Z0622',
   'Z0623',
   'Z0711',
   'Z0721',
   'Z0722',
   'Z0723',
   'Z0811',
   'Z0821',
   'Z0822',
   'Z0831',
   'Z0832',
   'Z0833',
   'Z0912',
   'Z0914',
   'Z0915',
   'Z0923',
   'Z0942',
   'Z0951',
   'Z1012',
   'Z1121',
   'Z1212',
   'Z1261',
   'Z0631',
   'Z1011'
  )
  ) as X
WHERE cantobs > 6 and periodo >= 'a2017m01'
order by "cluster", periodo, grupo, nombregrupo, estado;

GRANT SELECT ON TABLE frecCambio_restorest TO cvp_administrador;
