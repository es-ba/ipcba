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

GRANT SELECT ON TABLE desvios TO cvp_administrador;