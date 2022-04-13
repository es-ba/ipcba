CREATE OR REPLACE VIEW canasta_alimentaria_var AS 
  SELECT CASE WHEN (x.agrupacion='B' AND x.nivel=2 )THEN x.grupopadre ELSE x.grupo END AS grupo, x.nombregrupo, 
         round(c0.valorgru::DECIMAL,2) as valorgruant, 
         ROUND(c.valorgru ::DECIMAL,2) AS VALORGRU, 
         ROUND(c.variacion::DECIMAL,1) AS VARIACION, 
         CASE WHEN ca.Valorgru=0 THEN null ELSE round((c.ValorGru/ca.ValorGru*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.Valorgru=0 THEN null ELSE round((c.ValorGru/cm.ValorGru*100-100)::decimal,1) END AS variacionmesanioanterior,
         x.agrupacion, x.calculo, x.periodo, c0.calculo AS calculoant, c0.periodo as periodoant, ca.periodo periododiciembre, cm.periodo periodoaniooanterior, x.nivel
    FROM (SELECT DISTINCT c.grupo, g.nombregrupo, 
                          c.agrupacion, c.calculo,c.periodo ,g.nivel, c.agrupacion AS agrupprincipal, 
                          p.calculoanterior, p.periodoanterior, g.grupopadre                
            FROM cvp.calgru c
            JOIN cvp.grupos g ON c.agrupacion = g.agrupacion AND c.grupo = g.grupo
            JOIN cvp.calculos_def cd ON c.calculo = cd.calculo 
            JOIN cvp.calculos p ON c.periodo=p.periodo and  'A'=p.agrupacionprincipal AND  cd.calculo=p.calculo             
            WHERE cd.principal AND c.agrupacion in ('A','B') AND g.nivel in (2,3) AND substr(g.grupopadre::text, 1, 2) in ('A1','B1')) x 
    LEFT JOIN cvp.calgru c  ON x.agrupprincipal=c.agrupacion  AND x.grupo=c.grupo AND c.calculo=x.calculo AND  c.periodo=x.periodo				
    LEFT JOIN cvp.calgru c0 ON x.agrupprincipal=c0.agrupacion AND x.grupo=c0.grupo AND c0.calculo=x.calculoanterior AND  c0.periodo=x.periodoanterior 
    LEFT JOIN cvp.calgru ca ON x.agrupprincipal=ca.agrupacion AND x.grupo=ca.grupo AND ca.calculo=x.calculo AND  ca.periodo='a'||(substr(x.periodo,2,4)::integer-1)||'m12' 
    LEFT JOIN cvp.calgru cm ON x.agrupprincipal=cm.agrupacion AND x.grupo=cm.grupo AND cm.calculo=x.calculo AND  cm.periodo='a'||(substr(x.periodo,2,4)::integer-1)||'m'||substr(x.periodo,7,2)	
  ORDER BY x.agrupacion, x.periodo, x.nivel, grupo;	

GRANT SELECT ON TABLE canasta_alimentaria_var TO cvp_administrador;
