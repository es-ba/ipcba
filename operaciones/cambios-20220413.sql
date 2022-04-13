set search_path = cvp;
CREATE OR REPLACE VIEW canasta_alimentaria AS 
SELECT CASE WHEN (x.agrupacion='B' AND x.nivel=2 )THEN x.grupopadre ELSE x.grupo END AS grupo, x.nombregrupo,
		round(c1.valorgru::DECIMAL,2) AS valorgru1, 
		round(c2.valorgru::DECIMAL,2) AS valorgru2, 
        round(c3.valorgru::DECIMAL,2) AS valorgru3, 
		round(c4.valorgru::DECIMAL,2) AS valorgru4, 
		round(c5.valorgru::DECIMAL,2) AS valorgru5, 
		round(c6.valorgru::DECIMAL,2) AS valorgru6,
       c1.periodo AS periodo1, c2.periodo AS periodo2,c3.periodo AS periodo3, c4.periodo AS periodo4, c5.periodo AS periodo5,c6.periodo AS periodo6,
       x.agrupacion, x.calculo,x.nivel 
  FROM cvp.matrizperiodos6 p
  JOIN (SELECT DISTINCT c.grupo, g.nombregrupo, 
            c.agrupacion, c.calculo, c.periodo, g.nivel, 
            c.agrupacion AS agrupprincipal, g.grupopadre
          FROM cvp.calgru c
          JOIN cvp.calculos_def cd on c.calculo = cd.calculo
          JOIN cvp.grupos g ON c.agrupacion::text = g.agrupacion::text AND c.grupo::text = g.grupo::text
          JOIN cvp.matrizperiodos6 a ON (a.periodo1 IS NULL OR c.periodo::text >= a.periodo1::text) AND c.periodo::text <= a.periodo6::text
          WHERE cd.principal AND c.agrupacion in ('A','B') AND g.nivel in (2,3) AND substr(g.grupopadre::text, 1, 2) in ('A1','B1')
		) x ON x.periodo = p.periodo6	
    LEFT JOIN cvp.calgru c1 ON x.agrupprincipal = c1.agrupacion AND x.grupo = c1.grupo AND c1.periodo = p.periodo1 AND c1.calculo = x.calculo
    LEFT JOIN cvp.calgru c2 ON x.agrupprincipal = c2.agrupacion AND x.grupo = c2.grupo AND c2.periodo = p.periodo2 AND c2.calculo = x.calculo
    LEFT JOIN cvp.calgru c3 ON x.agrupprincipal = c3.agrupacion AND x.grupo = c3.grupo AND c3.periodo = p.periodo3 AND c3.calculo = x.calculo
    LEFT JOIN cvp.calgru c4 ON x.agrupprincipal = c4.agrupacion AND x.grupo = c4.grupo AND c4.periodo = p.periodo4 AND c4.calculo = x.calculo
    LEFT JOIN cvp.calgru c5 ON x.agrupprincipal = c5.agrupacion AND x.grupo = c5.grupo AND c5.periodo = p.periodo5 AND c5.calculo = x.calculo
    LEFT JOIN cvp.calgru c6 ON x.agrupprincipal = c6.agrupacion AND x.grupo = c6.grupo AND c6.periodo = p.periodo6 AND c6.calculo = x.calculo
    LEFT JOIN cvp.periodos p0 ON p0.periodo = p.periodo1 AND p0.periodoanterior <> p.periodo1
    LEFT JOIN cvp.calgru cl0 ON x.agrupacion = cl0.agrupacion AND x.grupo = cl0.grupo AND cl0.periodo = p0.periodoanterior AND cl0.calculo = x.calculo
    ORDER BY x.agrupacion, periodo6, x.nivel, grupo;
------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW control_rangos as
select periodo, producto, nombreproducto, informante, tipoinformante, observacion, visita, panel, tarea, encuestador, recepcionista, nombrerecep, 
   formulario, precionormalizado, comentariosrelpre, observaciones, tipoprecio, cambio, impobs, precioant, tipoprecioant, antiguedadsinprecioant, 
   variac, promvar, desvvar, promrotativo, desvprot, razon_impobs_ant, repregunta
   from (select v.periodo,
           v.producto,
           p.nombreproducto,
           v.informante,
           i.tipoinformante,
           v.observacion,
           v.visita,
           vi.panel,
           vi.tarea,
           (vi.encuestador || ':') || pe.apellido AS encuestador,
           vi.recepcionista,
           pc.apellido AS nombrerecep,
           v.formulario,
           v.precionormalizado,
           v.comentariosrelpre,
           v.observaciones,
           v.tipoprecio,
           v.cambio,
           c2.impobs,
           COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
           v.tipoprecio_1 AS tipoprecioant,
           co.antiguedadsinprecio AS antiguedadsinprecioant,
           v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100 AS variac,
           avg   (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as promvar,
           stddev(v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as desvvar,
           avgprot.promrotativo,
           avgprot.desvprot,
           (vi2.razon::text || ':'::text) || COALESCE(co.impobs, ' '::character varying)::text AS razon_impobs_ant,
           CASE WHEN pr.periodo IS NOT NULL THEN 'R'
           ELSE NULL
           END AS repregunta,
           tamannodesvvar,
           tamannodesvpre
           FROM cvp.relpre_1 v
           LEFT JOIN (select c_0.* from cvp.calobs c_0 JOIN calculos_def cd on c_0.calculo = cd.calculo where cd.principal) co ON co.periodo = v.periodo_1 AND co.producto = v.producto AND co.informante = v.informante AND co.observacion = v.observacion
                JOIN cvp.productos p on v.producto = p.producto
                JOIN cvp.informantes i on v.informante = i.informante
                JOIN cvp.relvis vi on v.periodo = vi.periodo and v.informante = vi.informante and v.visita = vi.visita and v.formulario = vi.formulario 
                LEFT JOIN cvp.personal pe on vi.encuestador = pe.persona
                LEFT JOIN cvp.personal pc on vi.recepcionista = pc.persona
                LEFT JOIN (select c_2.* from cvp.calobs c_2 JOIN calculos_def cd on c_2.calculo = cd.calculo where cd.principal) c2 ON c2.periodo::text = v.periodo::text AND c2.producto::text = v.producto::text AND c2.informante = v.informante AND c2.observacion = v.observacion
                JOIN cvp.panel_promrotativo avgprot ON v.periodo = avgprot.periodo AND v.producto = avgprot.producto
                JOIN cvp.parametros ON parametros.unicoregistro = true
                LEFT JOIN cvp.prerep pr ON v.periodo = pr.periodo AND v.informante = pr.informante AND v.producto = pr.producto
                LEFT JOIN cvp.relvis vi2 ON v.informante = vi2.informante AND v.periodo_1 = vi2.periodo AND v.visita = vi2.visita AND v.formulario = vi2.formulario
        ) Q
WHERE ((precionormalizado / precioant * 100 - 100) > (promvar + tamannodesvvar * desvvar) OR 
       (precionormalizado / precioant * 100 - 100) IS DISTINCT FROM 0 AND 
       (precionormalizado / precioant * 100 - 100) < (promvar - tamannodesvvar * desvvar) OR 
       precionormalizado > (promrotativo + tamannodesvpre * desvprot) OR 
       precionormalizado < (promrotativo - tamannodesvpre * desvprot)
      );
------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW control_rangos_mod AS 
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    v.informante,
    i.tipoinformante,
    v.observacion,
    v.visita,
    vi.panel,
    vi.tarea,
    v.precionormalizado,
    v.tipoprecio,
    v.cambio,
    c2.impobs,
    COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
    sum(v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    co.impobs AS impobs_1
   FROM cvp.relpre_1 v
     JOIN cvp.productos f ON v.producto::text = f.producto::text
     JOIN cvp.relvis vi ON v.informante = vi.informante AND v.periodo::text = vi.periodo::text AND v.visita = vi.visita AND v.formulario = vi.formulario
     LEFT JOIN (select c_0.* from cvp.calobs c_0 JOIN calculos_def cd on c_0.calculo = cd.calculo where cd.principal) co ON co.periodo::text = v.periodo_1::text AND co.producto::text = v.producto::text AND co.informante = v.informante AND co.observacion = v.observacion
     LEFT JOIN (select c_2.* from cvp.calobs c_2 JOIN calculos_def cd on c_2.calculo = cd.calculo where cd.principal) c2 ON c2.periodo::text = v.periodo::text AND c2.producto::text = v.producto::text AND c2.informante = v.informante AND c2.observacion = v.observacion
     JOIN ( SELECT avg(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100::double precision - 100::double precision) AS promvar,
            stddev(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100::double precision - 100::double precision) AS desvvar,
            va2.periodo,
            va2.producto
           FROM cvp.relpre_1 va2
             LEFT JOIN (select co_2.* from cvp.calobs co_2 JOIN calculos_def cd on co_2.calculo = cd.calculo where cd.principal) co2 ON co2.periodo::text = va2.periodo_1::text AND co2.producto::text = va2.producto::text AND co2.informante = va2.informante AND co2.observacion = va2.observacion
          GROUP BY va2.periodo, va2.producto) avgvar ON v.periodo::text = avgvar.periodo::text AND v.producto::text = avgvar.producto::text
     JOIN cvp.panel_promrotativo_mod avgprot ON v.periodo::text = avgprot.periodo::text AND v.producto::text = avgprot.producto::text
     JOIN cvp.parametros ON parametros.unicoregistro = true
     JOIN cvp.informantes i ON v.informante = i.informante
  WHERE (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) > (avgvar.promvar + parametros.tamannodesvvar * avgvar.desvvar) OR (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) IS DISTINCT FROM 0::double precision AND (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) < (avgvar.promvar - parametros.tamannodesvvar * avgvar.desvvar) OR v.precionormalizado > (avgprot.promrotativo + parametros.tamannodesvpre * avgprot.desvprot) OR v.precionormalizado < (avgprot.promrotativo - parametros.tamannodesvpre * avgprot.desvprot)
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, vi.tarea, v.precionormalizado, v.tipoprecio, v.cambio, c2.impobs, v.precionormalizado_1, co.promobs, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, avgprot.desvprot, co.impobs
  ORDER BY v.periodo, v.producto, vi.panel, vi.tarea, v.informante;
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW desvios AS 
SELECT co.periodo, co.calculo, co.producto, prod.nombreproducto, sqrt(sum(frec_n*(promobs-prom_aritmetico_pond)^2)) as desvio
FROM calobs co
    INNER JOIN productos prod ON prod.producto = co.producto
    INNER JOIN
    (SELECT F.periodo, F.calculo, F.producto, F.division, F.frec_n, PP.prom_aritmetico_pond
        FROM (SELECT c.periodo, c.calculo, c.producto, c.division, (CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END)/count(*) as frec_n
                FROM calobs c
                INNER JOIN calculos_def df on c.calculo = df.calculo
                INNER JOIN (SELECT grupo FROM gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg 
                ON c.producto = gg.grupo --sólo los publicados
                LEFT JOIN caldiv d 
                ON c.periodo = d.periodo and c.calculo = d.calculo and c.division = d.division and c.producto = d.producto 
                WHERE df.principal and c.AntiguedadIncluido>0 AND c.PromObs<>0 --incluidos en el cálculo
                GROUP BY c.periodo, c.calculo, c.producto, c.division, CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END
                ORDER BY c.periodo, c.calculo, c.producto, c.division, CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END) F
            INNER JOIN
            (SELECT periodo, calculo, producto, sum(prom_aritmetico_pond_div*ponderadordiv) prom_aritmetico_pond 
                FROM (SELECT c.periodo, c.calculo, c.producto, c.division,(CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END) as ponderadordiv, 
                        avg(promobs) as prom_aritmetico_pond_div
                        FROM calobs c
                        INNER JOIN calculos_def cd on c.calculo = cd.calculo 
                        INNER JOIN (SELECT grupo FROM gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg 
                        ON c.producto = gg.grupo --sólo los publicados
                        LEFT JOIN caldiv d 
                        ON c.periodo = d.periodo and c.calculo = d.calculo and c.division = d.division and c.producto = d.producto 
                        WHERE cd.principal and c.AntiguedadIncluido>0 AND c.PromObs<>0 --incluidos en el cálculo
                        GROUP BY c.periodo, c.calculo, c.producto, c.division, CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END 
                        ORDER BY c.periodo, c.calculo, c.producto, c.division, CASE WHEN c.division = '0' THEN 1 ELSE d.ponderadordiv END) P
            GROUP BY periodo, calculo, producto
            ORDER BY periodo, calculo, producto) PP
  ON F.periodo = PP.periodo and F.calculo = PP.calculo and F.producto = PP.producto) Expr
ON co.periodo = Expr.periodo and co.calculo = Expr.calculo and co.producto = Expr.producto and co.division = Expr.division
WHERE co.AntiguedadIncluido>0 AND co.PromObs<>0 --incluidos en el calculo
      AND prod.calculo_desvios = 'N'  --Forma normal de calcular los desvíos
GROUP BY co.periodo, co.calculo, co.producto, prod.nombreproducto   
UNION
SELECT ca.periodo, ca.calculo, ca.producto, prod.nombreproducto, sqrt(sum(frec_n*(promdiv-prom_aritmetico)^2)) as desvio
FROM caldiv ca
    join calculos_def f on ca.calculo = f.calculo
    INNER JOIN productos prod ON prod.producto = ca.producto
    INNER JOIN
    (SELECT periodo, cd.calculo, producto, 1/count(*)::decimal as frec_n, avg(promdiv) prom_aritmetico
       FROM caldiv cd join calculos_def d on cd.calculo = d.calculo
       WHERE d.principal and profundidad = 1 --para la forma especial, tomamos la profundidad 1 de caldiv
       GROUP BY periodo, cd.calculo, producto) F2
    ON ca.periodo = F2.periodo and ca.calculo = F2.calculo and ca.producto = F2.producto
WHERE prod.calculo_desvios = 'E' and f.principal and ca.profundidad = 1
GROUP BY ca.periodo, ca.calculo, ca.producto, prod.nombreproducto   
ORDER BY periodo, calculo, producto, nombreproducto;
-------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW cvp.freccambio_nivel0 AS
SELECT distinct cvp.devolver_mes_anio(periodo) Periodonombre, 
    periodo, 
    substr(x.grupo,1,2) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster")/ COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT o.periodo, g.grupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
            WHEN o.promobs > o1.promobs THEN 'Subió' 
            ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        JOIN cvp.calculos_def cd on o.calculo = cd.calculo 
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 ON o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg ON o.producto = gg.grupo
        LEFT JOIN cvp.grupos g ON gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p ON o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE cd.principal AND g.agrupacion = 'Z' AND g.nivel = 0 AND o.impobs = 'R' AND o1.impobs = 'R'
        --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo not in 
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
      ) as x
      LEFT JOIN cvp.grupos u ON substr(x.grupo,1,2) = u.grupo  
    WHERE cantobs > 6 and periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;
----------------------------------------------------------------------------------------------------------
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
        WHERE cd.principal AND  g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs = 'R' AND o1.impobs = 'R'
        --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo not in 
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
      ) as x
    LEFT JOIN cvp.grupos u ON substr(x.grupo,1,3) = u.grupo
    WHERE cantobs > 6 and periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;
--------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW frecCambio_resto AS
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
    join cvp.calculos_def cd on o.calculo = cd.calculo 
    LEFT JOIN cvp.calculos c ON o.periodo = c.periodo and o.calculo = c.calculo
    LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior and o1.calculo = c.calculoanterior and 
      o.producto = o1.producto and o.informante = o1.informante and o.observacion = o1.observacion
    LEFT JOIN cvp.productos p on o.producto = p.producto
    LEFT JOIN cvp.gru_grupos gu on gu.agrupacion = 'R' and gu.esproducto = 'S' and gu.grupo = o.producto and length(gu.grupo_padre) = 2
    LEFT JOIN cvp.grupos g on gu.grupo_padre = g.grupo and gu.agrupacion = g.agrupacion
    LEFT JOIN cvp.gru_grupos gg on gg.agrupacion = 'Z' and gg.esproducto = 'S' and gg.grupo = o.producto and length(gg.grupo_padre) = 5  --los niveles 3 para poder excluirlos
    LEFT JOIN cvp.parametros par ON unicoregistro
WHERE cd.principal and g.grupo ='R3' and o.impobs = 'R' and o1.impobs = 'R'
  --Excluimos los siguientes grupos:
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
   'Z1261'
  )
  ) as X
WHERE cantobs > 6 and periodo >= 'a2017m01'
order by "cluster", periodo, grupo, nombregrupo, estado;
---------------------------------------------------------------------------------------------------
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
    join cvp.calculos_def cd on o.calculo = cd.calculo
    LEFT JOIN cvp.calculos c ON o.periodo = c.periodo and o.calculo = c.calculo
    LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior and o1.calculo = c.calculoanterior and 
      o.producto = o1.producto and o.informante = o1.informante and o.observacion = o1.observacion
    LEFT JOIN cvp.productos p on o.producto = p.producto
    LEFT JOIN cvp.gru_grupos gu on gu.agrupacion = 'R' and gu.esproducto = 'S' and gu.grupo = o.producto and length(gu.grupo_padre) = 2
    LEFT JOIN cvp.grupos g on gu.grupo_padre = g.grupo and gu.agrupacion = g.agrupacion
    LEFT JOIN cvp.gru_grupos gg on gg.agrupacion = 'Z' and gg.esproducto = 'S' and gg.grupo = o.producto and length(gg.grupo_padre) = 5  --los niveles 3 para poder excluirlos
    LEFT JOIN cvp.parametros par ON unicoregistro
  WHERE cd.principal and g.grupo ='R3' and o.impobs = 'R' and o1.impobs = 'R'
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
--------------------------------------------------------------------------------------------