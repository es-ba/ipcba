CREATE OR REPLACE VIEW canasta_consumo_var AS 
  SELECT c.hogar, c.grupo AS grupo, g.nombregrupo nombre, 
		 ROUND(c0.valorhoggru::DECIMAL,2) AS valorgruant, ROUND(c.valorhoggru::DECIMAL,2) AS valorhg, 
         CASE WHEN c0.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/c0.ValorhogGru*100-100)::decimal,1) END AS variacion,
         CASE WHEN ca.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/ca.ValorhogGru*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/cm.ValorhogGru*100-100)::decimal,1) END AS variacionmesanioanterior, 
		 c.agrupacion, c.calculo, c.periodo, c0.calculo AS calculoant, c0.periodo periodoant, ca.periodo periododiciembre, cm.periodo periodoaniooanterior, g.nivel 
    FROM cvp.calhoggru c
    JOIN cvp.grupos g ON  c.agrupacion=g.agrupacion AND c.grupo=g.grupo
	JOIN cvp.calculos p ON c.periodo=p.periodo and  'A'=p.agrupacionprincipal AND  0=p.calculo
    JOIN cvp.calhoggru c0 ON c.agrupacion=c0.agrupacion AND c.hogar=c0.hogar AND c.grupo=c0.grupo AND c0.calculo=p.calculoAnterior AND  c0.periodo=p.periodoAnterior 
	LEFT JOIN cvp.calhoggru ca ON c.agrupacion=ca.agrupacion  AND c.hogar=ca.hogar AND c.grupo=ca.grupo AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' 
    LEFT JOIN cvp.calhoggru cm ON c.agrupacion=cm.agrupacion  AND c.hogar=cm.hogar AND c.grupo=cm.grupo AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)
    WHERE c.calculo=0  AND (g.nivel=2 AND substr(g.grupopadre,1,2)  not in ( 'A1','B1') )  
  UNION 
  SELECT c.hogar, c.grupo||'X' AS grupo, g.nombrecanasta nombre,  
		 ROUND(c0.valorhogsub::DECIMAL,2) AS valorgruant, 
		 ROUND(c.valorhogsub ::DECIMAL,2) AS valorhg, 
		 CASE WHEN c0.valorhogsub=0 THEN null ELSE round((c.valorhogsub/c0.valorhogsub*100-100)::decimal,1) END AS variacion,  
         CASE WHEN ca.valorhogsub=0 THEN null ELSE round((c.valorhogsub/ca.valorhogsub*100-100)::decimal,1) END AS variaciondiciembre, 
         CASE WHEN cm.valorhogsub=0 THEN null ELSE round((c.valorhogsub/cm.valorhogsub*100-100)::decimal,1) END AS variacionmesanioanterior,
		 c.agrupacion, c.calculo, c.periodo, c0.calculo AS calculoant, c0.periodo periodoant, ca.periodo periododiciembre, cm.periodo periodoaniooanterior, g.nivel
    FROM cvp.calhogsubtotales c
    JOIN cvp.grupos g ON  c.agrupacion=g.agrupacion AND c.grupo=g.grupo
    JOIN cvp.calculos p ON c.periodo=p.periodo and  'A'=p.agrupacionprincipal AND  0=p.calculo
    JOIN cvp.calhogsubtotales c0 ON c.agrupacion=c0.agrupacion AND c.hogar=c0.hogar AND c.grupo=c0.grupo AND c0.calculo=p.calculoAnterior AND  c0.periodo=p.periodoAnterior 
	LEFT JOIN cvp.calhogsubtotales ca ON c.agrupacion=ca.agrupacion  AND c.hogar=ca.hogar AND c.grupo=ca.grupo AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' 
    LEFT JOIN cvp.calhogsubtotales cm ON c.agrupacion=cm.agrupacion  AND c.hogar=cm.hogar AND c.grupo=cm.grupo AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)
    WHERE c.calculo=0 AND ((g.nivel=1 )) 
ORDER BY agrupacion, periodo, hogar, grupo;

GRANT SELECT ON TABLE canasta_consumo_var TO cvp_administrador;	

