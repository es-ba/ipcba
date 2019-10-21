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
          JOIN cvp.grupos g ON c.agrupacion::text = g.agrupacion::text AND c.grupo::text = g.grupo::text
          JOIN cvp.matrizperiodos6 a ON (a.periodo1 IS NULL OR c.periodo::text >= a.periodo1::text) AND c.periodo::text <= a.periodo6::text
          WHERE c.calculo = 0 AND c.agrupacion in ('A','B') AND g.nivel in (2,3) AND substr(g.grupopadre::text, 1, 2) in ('A1','B1')
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
	
GRANT SELECT ON TABLE canasta_alimentaria TO cvp_administrador;	
