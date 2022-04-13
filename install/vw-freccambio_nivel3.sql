CREATE OR REPLACE VIEW cvp.frecCambio_Nivel3 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
    COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, g.nombregrupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
             WHEN o.promobs > o1.promobs THEN 'Subió' 
        ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        join cvp.calculos_def cd on o.calculo = cd.calculo
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg on o.producto = gg.grupo
        LEFT JOIN cvp.grupos g on gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p on o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE /*o.periodo >= 'a2012m07' AND o.periodo <= 'a2017m09' AND */ 
        cd.principal AND g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs = 'R' AND o1.impobs = 'R'
          --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo NOT IN 
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
           'Z1261'
          )
     ) AS X
WHERE cantobs > 6 and periodo >= 'a2017m01'
ORDER BY "cluster", periodo, grupo, nombregrupo, estado;

GRANT SELECT ON TABLE frecCambio_Nivel3 TO cvp_administrador;
