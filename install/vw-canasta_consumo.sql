CREATE OR REPLACE VIEW canasta_consumo AS 
  SELECT    x.hogar, CASE WHEN x.nivel=1 THEN x.grupo||'X' ELSE x.grupo END as  grupo, x.nombre, 
            ROUND(CASE WHEN x.nivel=1 THEN  s1.valorhogsub ELSE c1.valorhoggru END::DECIMAL,2)  as valorgru1, 
            ROUND(CASE WHEN x.nivel=1 THEN  s2.valorhogsub ELSE c2.valorhoggru END::DECIMAL,2)  as valorgru2,  
            ROUND(CASE WHEN x.nivel=1 THEN  s3.valorhogsub ELSE c3.valorhoggru END::DECIMAL,2)  as valorgru3, 
            ROUND(CASE WHEN x.nivel=1 THEN  s4.valorhogsub ELSE c4.valorhoggru END::DECIMAL,2)  as valorgru4, 
            ROUND(CASE WHEN x.nivel=1 THEN  s5.valorhogsub ELSE c5.valorhoggru END::DECIMAL,2)  as valorgru5,   
            ROUND(CASE WHEN x.nivel=1 THEN  s6.valorhogsub ELSE c6.valorhoggru END::DECIMAL,2)  as valorgru6,   
			CASE WHEN x.nivel=1 THEN s1.periodo ELSE c1.periodo END as periodo1,
			CASE WHEN x.nivel=1 THEN s2.periodo ELSE c2.periodo END as periodo2,
			CASE WHEN x.nivel=1 THEN s3.periodo ELSE c3.periodo END as periodo3,  	
			CASE WHEN x.nivel=1 THEN s4.periodo ELSE c4.periodo END as periodo4, 
			CASE WHEN x.nivel=1 THEN s5.periodo ELSE c5.periodo END as periodo5,
			CASE WHEN x.nivel=1 THEN s6.periodo ELSE c6.periodo END as periodo6,
            x.agrupacion, x.nivel, x.calculo
    FROM cvp.matrizperiodos6 p
    JOIN ( SELECT c.grupo,c.hogar,g.nombregrupo nombre, c.agrupacion,c.calculo ,a.periodo6, g.nivel
             FROM cvp.calhoggru c
             JOIN cvp.grupos g ON  c.agrupacion=g.agrupacion AND c.grupo=g.grupo
             JOIN cvp.matrizperiodos6 a on (a.periodo1 IS NULL OR c.periodo >= a.periodo1) AND c.periodo <= a.periodo6
             JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
             WHERE cd.principal AND (g.nivel=2 AND substr(g.grupopadre,1,2)  not in ( 'A1','B1') )  
           UNION 
		   SELECT c.grupo, c.hogar, g.nombrecanasta nombre, c.agrupacion, c.calculo, a.periodo6, g.nivel
		     FROM cvp.calhogsubtotales c
		     JOIN cvp.grupos g ON  c.agrupacion=g.agrupacion AND c.grupo=g.grupo
		     JOIN cvp.matrizperiodos6 a on (a.periodo1 IS NULL OR c.periodo >= a.periodo1) AND c.periodo <= a.periodo6 
             JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
		     WHERE cd.principal AND ((g.nivel=1 )) 
		     GROUP BY c.grupo, c.hogar,nombre , c.agrupacion,c.calculo,a.periodo6,g.nivel ) x on x.periodo6=p.periodo6 
  LEFT JOIN cvp.calhoggru c1 ON x.agrupacion=c1.agrupacion AND x.grupo=c1.grupo AND x.hogar=c1.hogar AND c1.periodo=p.periodo1 AND c1.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhoggru c2 ON x.agrupacion=c2.agrupacion AND x.grupo=c2.grupo AND x.hogar=c2.hogar AND c2.periodo=p.periodo2 AND c2.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhoggru c3 ON x.agrupacion=c3.agrupacion AND x.grupo=c3.grupo AND x.hogar=c3.hogar AND c3.periodo=p.periodo3 AND c3.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhoggru c4 ON x.agrupacion=c4.agrupacion AND x.grupo=c4.grupo AND x.hogar=c4.hogar AND c4.periodo=p.periodo4 AND c4.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhoggru c5 ON x.agrupacion=c5.agrupacion AND x.grupo=c5.grupo AND x.hogar=c5.hogar AND c5.periodo=p.periodo5 AND c5.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhoggru c6 ON x.agrupacion=c6.agrupacion AND x.grupo=c6.grupo AND x.hogar=c6.hogar AND c6.periodo=p.periodo6 AND c6.calculo=x.calculo  AND x.nivel=2 
  LEFT JOIN cvp.calhogsubtotales s1 ON x.agrupacion=s1.agrupacion AND x.grupo=s1.grupo AND x.hogar=s1.hogar AND s1.periodo=p.periodo1 AND s1.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.calhogsubtotales s2 ON x.agrupacion=s2.agrupacion AND x.grupo=s2.grupo AND x.hogar=s2.hogar AND s2.periodo=p.periodo2 AND s2.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.calhogsubtotales s3 ON x.agrupacion=s3.agrupacion AND x.grupo=s3.grupo AND x.hogar=s3.hogar AND s3.periodo=p.periodo3 AND s3.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.calhogsubtotales s4 ON x.agrupacion=s4.agrupacion AND x.grupo=s4.grupo AND x.hogar=s4.hogar AND s4.periodo=p.periodo4 AND s4.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.calhogsubtotales s5 ON x.agrupacion=s5.agrupacion AND x.grupo=s5.grupo AND x.hogar=s5.hogar AND s5.periodo=p.periodo5 AND s5.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.calhogsubtotales s6 ON x.agrupacion=s6.agrupacion AND x.grupo=s6.grupo AND x.hogar=s6.hogar AND s6.periodo=p.periodo6 AND s6.calculo=x.calculo  AND x.nivel=1 
  LEFT JOIN cvp.periodos p0 ON p0.periodo= p.periodo1 AND p0.periodoanterior <> p.periodo1
  LEFT JOIN cvp.calhoggru cl0 ON x.agrupacion = cl0.agrupacion AND  x.grupo=cl0.grupo AND x.hogar=cl0.hogar AND cl0.periodo = p0.periodoanterior AND cl0.calculo = x.calculo
ORDER BY agrupacion, periodo6, hogar, grupo ;

GRANT SELECT ON TABLE canasta_consumo TO cvp_administrador;
