CREATE OR REPLACE VIEW control_calculoresultados AS 
 SELECT c.grupo AS codigo,
    g.nombregrupo AS nombre,
    NULL AS ti,
    c.nivel,
    c.valorgru AS valor,
    c.variacion,
    c.impgru AS imp,
    NULL::double precision AS cant,
    NULL AS unidad,
    NULL::double precision AS promedio,
    NULL AS unidadnormal,
    NULL::integer AS cantincluidos,
    NULL::integer AS cantimputados,
    NULL::double precision AS promvar,
    NULL::integer AS cantaltas,
    NULL::double precision AS promaltas,
    NULL::integer AS cantbajas,
    NULL::double precision AS prombajas,
    c.periodo,
    c.grupo AS ordenamiento,
    c.esproducto,
    NULL::double precision AS ponderadordiv,
    NULL::double precision AS promedio_1,
    NULL::double precision AS varprom,
    NULL::integer AS cantexcluidos,
    NULL::double precision AS promexcluidos
   FROM cvp.calgru c
     JOIN cvp.grupos g ON c.grupo = g.grupo
     JOIN cvp.calculos a ON a.periodo = c.periodo AND a.calculo = c.calculo
     JOIN cvp.calculos_def cd ON a.calculo = cd.calculo
  WHERE c.calculo = 0 AND c.agrupacion = cd.agrupacionprincipal AND c.esproducto = 'N'
UNION
 SELECT c.producto AS codigo,
    p.nombreproducto AS nombre,
    c.division AS ti,
    g.nivel,
    cpa.valorprod AS valor,
        CASE
            WHEN c.division = '0' THEN g.variacion
            ELSE NULL
        END AS variacion,
    c.impdiv AS imp,
    cpa.cantporunidcons AS cant,
    cp.unidadmedidaporunidcons AS unidad,
    c.promdiv AS promedio,
    cvp.obtenerunidadnormalizada(p.producto) AS unidadnormal,
    c.cantincluidos,
    c.cantimputados,
    c.promvar,
    c.cantaltas,
    c.promaltas,
    c.cantbajas,
    c.prombajas,
    c.periodo,
    g.grupopadre||'-'|| g.grupo AS ordenamiento,
    'S' AS esproducto,
    v.ponderadordiv,
    c_1.promdiv AS promedio_1,
    c.promdiv / c_1.promdiv * 100 - 100 AS varprom,
    c.cantexcluidos,
    c.promexcluidos
   FROM cvp.caldiv c
     JOIN cvp.productos p ON c.producto = p.producto
     JOIN cvp.calculos a ON a.periodo = c.periodo AND a.calculo = c.calculo
     JOIN cvp.calculos_def cd ON a.calculo = cd.calculo
     JOIN cvp.calgru g ON g.periodo = c.periodo AND g.calculo = c.calculo AND g.agrupacion = cd.agrupacionprincipal AND g.grupo = c.producto
     JOIN ( SELECT x.periodo,
            x.calculo,
            x.producto,
            count(*) AS canttipo
           FROM cvp.caldiv x
          GROUP BY x.periodo, x.calculo, x.producto) y ON y.periodo = c.periodo AND y.calculo = c.calculo AND y.producto = c.producto
     JOIN cvp.calprod cp ON c.periodo = cp.periodo AND c.calculo = cp.calculo AND c.producto = cp.producto
     JOIN cvp.calprodAgr cpa ON c.periodo = cpa.periodo AND c.calculo = cpa.calculo AND c.producto = cpa.producto and g.agrupacion = cpa.agrupacion
     LEFT JOIN cvp.proddiv v ON p.producto = v.producto AND c.division = v.division
     LEFT JOIN cvp.caldiv c_1 ON a.periodoanterior = c_1.periodo AND a.calculoanterior = c_1.calculo AND c.producto = c_1.producto AND c.division = c_1.division
  WHERE c.calculo = 0;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE control_calculoresultados TO cvp_administrador;
