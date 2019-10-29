CREATE OR REPLACE VIEW preciosmedios_albs_var AS 
  SELECT g2.grupopadre AS gruponivel1, g3.nombregrupo AS nombregruponivel1, g.grupopadre, g2.nombregrupo AS nombregrupopadre, c.producto,
         coalesce(p.nombreparapublicar::character varying(250),p.nombreproducto) as nombreproducto,p.unidadmedidaabreviada, 
         ROUND(c0.promdiv::DECIMAL,2) AS promprodant, 
         ROUND(c.promdiv ::DECIMAL,2) AS promprod,  
         CASE WHEN c0.promdiv=0 THEN null ELSE round((c.promdiv/c0.promdiv*100-100)::decimal,1) END AS variacion,
         CASE WHEN ca.promdiv=0 THEN null ELSE round((c.promdiv/ca.promdiv*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.promdiv=0 THEN null ELSE round((c.promdiv/cm.promdiv*100-100)::decimal,1) END AS variacionmesanioanterior,         
         g.agrupacion,c.calculo, c.periodo, c0.calculo AS calculoant,c0.periodo periodoant,ca.periodo periododiciembre,cm.periodo periodoaniooanterior
    FROM cvp.caldiv c
    JOIN cvp.grupos g ON   c.calculo=0 AND g.grupo=c.producto AND g.esproducto='S'
    JOIN cvp.productos p ON g.grupo=p.producto AND g.esproducto='S'
    JOIN cvp.calculos pa ON c.periodo=pa.periodo and  'A'=pa.agrupacionprincipal AND  0=pa.calculo
    JOIN cvp.caldiv c0 ON  c.producto=c0.producto AND c0.calculo=pa.calculoAnterior AND  c0.periodo=pa.periodoAnterior  AND c0.division='0'
    LEFT JOIN cvp.caldiv ca ON c.producto=ca.producto AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' AND ca.division='0'
    LEFT JOIN cvp.caldiv cm ON c.producto=cm.producto AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)  AND cm.division='0'
    LEFT JOIN cvp.grupos g2 ON g.grupopadre = g2.grupo AND g2.agrupacion = g.agrupacion
    LEFT JOIN cvp.grupos g3 ON g2.grupopadre = g3.grupo AND g3.agrupacion = g2.agrupacion
    WHERE c.calculo=0 AND  (g.esproducto='S'  AND g.agrupacion='C') AND c.division='0'
   ORDER BY agrupacion, periodo, gruponivel1, grupopadre, producto;

GRANT SELECT ON TABLE preciosmedios_albs_var TO cvp_administrador;
