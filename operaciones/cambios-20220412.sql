set search_path = cvp;
CREATE OR REPLACE VIEW calobs_periodos AS
 SELECT c.producto,
    c.informante,
    c.observacion,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m01'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m01_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m01'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m01_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m02'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m02_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m02'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m02_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m03'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m03_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m03'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m03_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m04'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m04_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m04'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m04_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m05'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m05_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m05'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m05_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m06'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m06_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m06'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m06_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m07'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m07_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m07'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m07_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m08'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m08_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m08'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m08_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m09'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m09_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m09'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m09_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m10'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m10_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m10'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m10_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m11'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m11_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m11'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m11_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m12'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m12_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m12'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m12_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m01'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m01_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m01'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m01_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m02'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m02_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m02'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m02_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m03'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m03_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m03'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m03_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m04'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m04_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m04'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m04_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m05'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m05_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m05'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m05_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m06'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m06_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m06'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m06_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m07'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m07_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m07'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m07_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m08'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m08_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m08'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m08_imp
   FROM cvp.calobs c
     JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
     LEFT JOIN cvp.relpre r ON c.periodo::text = r.periodo::text AND c.producto::text = r.producto::text AND c.informante = r.informante AND c.observacion = r.observacion AND r.visita = 1
  WHERE cd.principal
  GROUP BY c.producto, c.informante, c.observacion
  ORDER BY c.producto, c.informante, c.observacion;
----------------------------------------------------------------------
  CREATE OR REPLACE VIEW calobs_vw AS
  SELECT c.* 
    FROM CalObs c JOIN calculos_def cd on c.calculo = cd.calculo 
    WHERE cd.principal;
----------------------------------------------------------------------
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
------------------------------------------------------------------------- 
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
------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW canasta_consumo_var AS 
  SELECT c.hogar, c.grupo AS grupo, g.nombregrupo nombre, 
		 ROUND(c0.valorhoggru::DECIMAL,2) AS valorgruant, ROUND(c.valorhoggru::DECIMAL,2) AS valorhg, 
         CASE WHEN c0.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/c0.ValorhogGru*100-100)::decimal,1) END AS variacion,
         CASE WHEN ca.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/ca.ValorhogGru*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.Valorhoggru=0 THEN null ELSE round((c.ValorHogGru/cm.ValorhogGru*100-100)::decimal,1) END AS variacionmesanioanterior, 
		 c.agrupacion, c.calculo, c.periodo, c0.calculo AS calculoant, c0.periodo periodoant, ca.periodo periododiciembre, cm.periodo periodoaniooanterior, g.nivel 
    FROM cvp.calhoggru c
    JOIN cvp.grupos g ON  c.agrupacion=g.agrupacion AND c.grupo=g.grupo
	JOIN cvp.calculos p ON c.periodo=p.periodo and  'A'=p.agrupacionprincipal AND c.calculo=p.calculo
    JOIN cvp.calculos_def cd on p.calculo = cd.calculo
    JOIN cvp.calhoggru c0 ON c.agrupacion=c0.agrupacion AND c.hogar=c0.hogar AND c.grupo=c0.grupo AND c0.calculo=p.calculoAnterior AND  c0.periodo=p.periodoAnterior 
	LEFT JOIN cvp.calhoggru ca ON c.agrupacion=ca.agrupacion  AND c.hogar=ca.hogar AND c.grupo=ca.grupo AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' 
    LEFT JOIN cvp.calhoggru cm ON c.agrupacion=cm.agrupacion  AND c.hogar=cm.hogar AND c.grupo=cm.grupo AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)
    WHERE cd.principal AND (g.nivel=2 AND substr(g.grupopadre,1,2)  not in ( 'A1','B1') )  
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
    JOIN cvp.calculos p ON c.periodo=p.periodo and  'A'=p.agrupacionprincipal AND c.calculo=p.calculo
    JOIN cvp.calculos_def cd on p.calculo = cd.calculo
    JOIN cvp.calhogsubtotales c0 ON c.agrupacion=c0.agrupacion AND c.hogar=c0.hogar AND c.grupo=c0.grupo AND c0.calculo=p.calculoAnterior AND  c0.periodo=p.periodoAnterior 
    LEFT JOIN cvp.calhogsubtotales ca ON c.agrupacion=ca.agrupacion  AND c.hogar=ca.hogar AND c.grupo=ca.grupo AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' 
    LEFT JOIN cvp.calhogsubtotales cm ON c.agrupacion=cm.agrupacion  AND c.hogar=cm.hogar AND c.grupo=cm.grupo AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)
    WHERE cd.principal AND ((g.nivel=1 )) 
ORDER BY agrupacion, periodo, hogar, grupo;
---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW canasta_producto AS
select c.periodo, c.calculo, c.agrupacion, c.grupo as producto, p.nombreProducto, c.valorgru as valorProd, c.grupoPadre
      , g.grupo_padre as grupoParametro, string_agg(ph.parametro,', ') as parametro, string_agg(o.nombreparametro,', ') as nombreparametro
      , hp.hogar, CASE WHEN MIN(COALESCE(ABS(hp.CoefHogPar)))>0 THEN EXP(SUM(LN(NULLIF(hp.CoefHogPar,0)))) ELSE 0 END AS CoefHogGru
      , c.valorgru*CASE WHEN MIN(COALESCE(ABS(hp.CoefHogPar)))>0 THEN EXP(SUM(LN(NULLIF(hp.CoefHogPar,0)))) ELSE 0 END as valorHogProd
      , substr(c.grupo,2,2) as divisionCanasta
      , Agrupo1, Agrupo2, Agrupo3, Agrupo4 --ancestros de la rama A
      , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4 --ancestros de la rama B
   from cvp.calgru c
     join calculos_def cd on c.calculo = cd.calculo
     left join cvp.gru_grupos g on c.agrupacion = g.agrupacion and c.grupo = g.grupo
     left join cvp.productos p on c.grupo = p.producto
     left join cvp.prodagr ag on c.agrupacion = ag.agrupacion and p.producto = ag.producto 
     join cvp.parhoggru ph on c.agrupacion = ph.agrupacion and grupo_padre = ph.grupo
     left join cvp.hogparAgr hp on ph.parametro = hp.parametro and ph.agrupacion = hp.agrupacion
     left join cvp.parhog o on ph.parametro = o.parametro
     left join (select g.agrupacion, g.grupo as Agrupo0, g4.grupo as Agrupo4, g3.grupo as Agrupo3, g2.grupo as Agrupo2, g1.grupo as Agrupo1
                  from cvp.grupos g
                  inner join cvp.grupos g4 on g.grupopadre=g4.grupo and g.agrupacion = g4.agrupacion and g4.agrupacion in ('A','D')
                  inner join cvp.grupos g3 on g4.grupopadre=g3.grupo and g.agrupacion = g4.agrupacion and g3.agrupacion in ('A','D')
                  inner join cvp.grupos g2 on g3.grupopadre=g2.grupo and g.agrupacion = g4.agrupacion and g2.agrupacion in ('A','D')
                  inner join cvp.grupos g1 on g2.grupopadre=g1.grupo and g.agrupacion = g4.agrupacion and g1.agrupacion in ('A','D')
                  where g.agrupacion in ('A','D') and g.nivel=5
               ) as A on c.grupo = Agrupo0 AND c.agrupacion = A.agrupacion 
     left join (select g.grupo as Bgrupo0, g4.grupo as Bgrupo4, g3.grupo as Bgrupo3, g2.grupo as Bgrupo2, g1.grupo as Bgrupo1
                  from cvp.grupos g
                  inner join cvp.grupos g4 on g.grupopadre=g4.grupo and g4.agrupacion='B'
                  inner join cvp.grupos g3 on g4.grupopadre=g3.grupo and g3.agrupacion='B'
                  inner join cvp.grupos g2 on g3.grupopadre=g2.grupo and g2.agrupacion='B'
                  inner join cvp.grupos g1 on g2.grupopadre=g1.grupo and g1.agrupacion='B'
                  where g.agrupacion='B'and g.nivel=4
                ) as B on grupo_padre = Bgrupo0
   where cd.principal and c.agrupacion in ('A','D') and g.esproducto = 'S' and ag.cantporunidcons >0 and valorgru is not null 
         --and hp.hogar = 'Hogar 5b' and c.periodo = 'a2014m06' 
   group by c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar
            , Agrupo1, Agrupo2, Agrupo3, Agrupo4
            , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4 
   order by c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar
            , Agrupo1, Agrupo2, Agrupo3, Agrupo4
            , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4;
---------------------------------------------------------------------------------
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
  WHERE cd.principal AND c.agrupacion = cd.agrupacionprincipal AND c.esproducto = 'N'
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
  WHERE cd.principal;
---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW control_calobs AS 
    SELECT c.producto ,c.informante, c.observacion, c.periodo, r.visita, 
           CASE WHEN visita>1 THEN null ELSE ROUND(c.promobs::DECIMAL,2) END AS promobs, CASE WHEN visita>1 THEN null ELSE c.impobs END, 
           CASE WHEN visita>1 THEN null ELSE ROUND(c_1.promobs::DECIMAL,2) END AS promobs_1, 
           CASE WHEN (visita>1 OR c_1.promobs = 0) THEN NULL ELSE ROUND((c.promobs / c_1.promobs * 100 - 100)::DECIMAL, 1) END AS variacion, 
           r.cambio, r.precionormalizado, r.precio, r.tipoprecio
      FROM cvp.relpre r
      FULL OUTER JOIN cvp.calobs c ON c.periodo=r.periodo  AND c.producto=r.producto AND c.observacion=r.observacion AND c.informante=r.informante 
      JOIN cvp.calculos ca ON ca.periodo=c.periodo AND ca.calculo=c.calculo
      JOIN calculos_def cd on ca.calculo = cd.calculo
      LEFT JOIN cvp.calobs c_1 ON c_1.producto=c.producto AND c_1.calculo=ca.calculoanterior AND c_1.informante=c.informante AND c_1.observacion=c.observacion
                                  AND c_1.periodo=ca.periodoanterior
      WHERE cd.principal ;
---------------------------------------------------------------------------------- 
CREATE OR REPLACE VIEW control_grupos_para_cierre AS 
SELECT x.periodo, x.calculo, x.agrupacion, x.grupo, x.nombregrupo as nombre, x.nivel, c.variacion, c.incidencia, 
       c.variacioninteranualredondeada, c.incidenciainteranual, x.ponderador, 
       x.cantincluidos, x.cantrealesincluidos, x.cantimputados, 'Z'||substr(x.grupo,2) as ordenpor
  FROM (SELECT d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre as grupo, g.nombregrupo, g.ponderador, g.nivel, 
             sum(d.cantincluidos) cantincluidos, sum(d.cantrealesincluidos) cantrealesincluidos, sum(d.cantimputados) cantimputados 
        FROM cvp.caldiv d
        JOIN calculos_def cd on d.calculo = cd.calculo
        LEFT JOIN cvp.gru_prod gp ON d.producto=gp.producto
        LEFT JOIN cvp.grupos g ON gp.grupo_padre = g.grupo AND gp.agrupacion = g.agrupacion
        LEFT JOIN cvp.agrupaciones a ON gp.agrupacion = a.agrupacion 
        WHERE d.division = '0' and a.tipo_agrupacion = 'INDICE' and cd.principal
        GROUP BY d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre, g.nombregrupo, g.ponderador, g.nivel) as x
      LEFT JOIN cvp.calgru_vw c ON c.periodo = x.periodo and c.calculo = x.calculo and c.agrupacion = x.agrupacion and c.grupo = x.grupo 
   ORDER BY ordenpor;
-----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW control_ingresados_calculo AS
SELECT p.periodo, p.producto, o.nombreproducto, p.informante, i.nombreinformante, p.observacion, i.tipoinformante, pd.divisionesdelproducto, 
   case when not(i.tipoinformante is distinct from pd.divisionesdelproducto) then date_trunc('second',i.modi_fec) else null end as fechamodificacioninformante 
  FROM 
    (SELECT distinct periodo, producto, informante, observacion, modi_fec
       FROM cvp.relpre 
       WHERE precionormalizado is not null) as p --los candidatos a ir a calobs
    INNER JOIN cvp.productos o on p.producto = o.producto --pk verificada
    INNER JOIN cvp.informantes i on p.informante = i.informante --pk verificada
    INNER JOIN (select calculo from calculos_def where principal) d on true
    INNER JOIN cvp.calculos a on p.periodo = a.periodo and a.calculo = d.calculo --pk verificada 
    LEFT JOIN (SELECT producto, string_agg(division, ',' ORDER BY division) as divisionesdelproducto 
                 FROM cvp.proddiv 
                 GROUP BY producto) pd on p.producto = pd.producto
    LEFT JOIN (SELECT * FROM cvp.calobs co JOIN cvp.calculos_def df on co.calculo = df.calculo WHERE df.principal) c 
                 on c.periodo = p.periodo and c.producto = p.producto and c.informante = p.informante and c.observacion = p.observacion
    WHERE c.division is null AND p.modi_fec < a.fechacalculo
    ORDER BY p.periodo, p.producto, p.informante, p.observacion;
-----------------------------------------------------------------------------------------
