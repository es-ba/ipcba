CREATE OR REPLACE VIEW cvp.frecCambio_Nivel1 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    substr(x.grupo,1,3) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster") AS cantobsporgrupo, 
    ROUND(COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster")/COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster")::decimal*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, 
        CASE WHEN abs(o.promobs - o1.promobs) < par.umbraligualdad THEN 'Igual'
             WHEN o.promobs < o1.promobs THEN 'Bajó' 
             WHEN o.promobs > o1.promobs THEN 'Subió' 
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
        WHERE cd.principal AND  g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs like 'R%' AND o1.impobs like 'R%'  
      ) as x
    LEFT JOIN cvp.grupos u ON substr(x.grupo,1,3) = u.grupo
    WHERE periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;

GRANT SELECT ON TABLE frecCambio_Nivel1 TO cvp_administrador;

