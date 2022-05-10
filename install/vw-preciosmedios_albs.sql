CREATE OR REPLACE VIEW preciosmedios_albs AS 
 SELECT gruponivel1, nombregruponivel1, x.grupopadre, x.nombregrupopadre, x.producto, x.nombreproducto, x.unidadmedidaabreviada,
        ROUND(c1.promdiv::DECIMAL,2) AS promprod1,
        ROUND(c2.promdiv::DECIMAL,2) AS promprod2, 
        ROUND(c3.promdiv::DECIMAL,2) AS promprod3, 
        ROUND(c4.promdiv::DECIMAL,2) AS promprod4,
        ROUND(c5.promdiv::DECIMAL,2) AS promprod5, 
        ROUND(c6.promdiv::DECIMAL,2) AS promprod6, 
        c1.periodo as periodo1 , c2.periodo as periodo2 ,c3.periodo as periodo3 ,c4.periodo as periodo4, c5.periodo as periodo5, c6.periodo as periodo6,
        x.agrupacion   
   FROM cvp.matrizperiodos6 p
   JOIN ( SELECT c.producto, p.nombreproducto, p.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre,g2.nombregrupo as nombregrupopadre,g2.grupopadre as gruponivel1, g3.nombregrupo as  nombregruponivel1 
            FROM cvp.caldiv c
            JOIN cvp.calculos_def cd on c.calculo = cd.calculo
            JOIN cvp.grupos g ON g.grupo = c.producto AND g.esproducto = 'S'
            JOIN cvp.productos p ON g.grupo = p.producto AND g.esproducto = 'S'
            JOIN cvp.matrizperiodos6 a ON (a.periodo1 IS NULL OR c.periodo >= a.periodo1) AND c.periodo <= a.periodo6
            LEFT JOIN cvp.grupos g2 ON  g.grupopadre=g2.grupo AND g2.agrupacion=g.agrupacion
            LEFT JOIN cvp.grupos g3 ON g2.grupopadre=g3.grupo AND g3.agrupacion=g2.agrupacion
            WHERE cd.principal AND g.esproducto = 'S'  AND g.agrupacion='C'  AND c.division='0' -- AND g.agrupacion in ('A','B','C')
            GROUP BY c.producto, p.nombreproducto, p.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre,g2.nombregrupo,g2.nombregrupo,g2.grupopadre,g3.nombregrupo
        ) x ON x.periodo6 = p.periodo6
   LEFT JOIN cvp.caldiv c1 ON x.producto = c1.producto AND c1.periodo = p.periodo1 AND c1.calculo = x.calculo AND c1.division='0'
   LEFT JOIN cvp.caldiv c2 ON x.producto= c2.producto AND c2.periodo = p.periodo2 AND c2.calculo = x.calculo  AND c2.division='0'
   LEFT JOIN cvp.caldiv c3 ON x.producto = c3.producto AND c3.periodo = p.periodo3 AND c3.calculo = x.calculo AND c3.division='0'
   LEFT JOIN cvp.caldiv c4 ON x.producto = c4.producto AND c4.periodo = p.periodo4 AND c4.calculo = x.calculo AND c4.division='0'
   LEFT JOIN cvp.caldiv c5 ON x.producto = c5.producto AND c5.periodo = p.periodo5 AND c5.calculo = x.calculo AND c5.division='0'
   LEFT JOIN cvp.caldiv c6 ON x.producto = c6.producto AND c6.periodo = p.periodo6 AND c6.calculo = x.calculo AND c6.division='0'
   LEFT JOIN cvp.periodos p0 ON p0.periodo = p.periodo1 AND p0.periodoanterior <> p.periodo1
   LEFT JOIN cvp.caldiv cl0 ON x.producto = cl0.producto AND cl0.periodo = p0.periodoanterior AND cl0.calculo = x.calculo AND cl0.division='0'
   ORDER BY agrupacion, periodo6, gruponivel1, grupopadre, producto;

GRANT SELECT ON TABLE preciosmedios_albs TO cvp_administrador;
