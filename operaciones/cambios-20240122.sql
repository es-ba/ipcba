set search_path =cvp;
CREATE OR REPLACE VIEW calgru_vw AS
select c.periodo, c.calculo, c.agrupacion, c.grupo
       , COALESCE(g.nombregrupo,p.nombreproducto) AS nombre 
       , CASE WHEN c.periodo IS DISTINCT FROM t.pb_desde THEN c.variacion ELSE NULL END as variacion, c.impgru, c.grupopadre, c.nivel, c.esproducto, c.ponderador, c.indice, c.indiceprel
       , c.incidencia, c.indiceredondeado, c.incidenciaredondeada
       , (c.indice - cb.indice) * c.ponderador / pb.indice * 100 as incidenciainteranual --con todos los decimales
       , case when c.nivel = 0 then
               round(((round(c.indice::decimal,2) - round(cb.indice::decimal,2)) * c.ponderador / round(pb.indice::decimal,2) * 100)::decimal,1) -- a un decimal para nivel 0
              when c.nivel = 1 then
               round(((round(c.indice::decimal,2) - round(cb.indice::decimal,2)) * c.ponderador / round(pb.indice::decimal,2) * 100)::decimal,2) -- a dos decimales para nivel 1
              else null
       end as incidenciainteranualredondeada
       , (c.indice - ca.indice) * c.ponderador / pa.indice * 100 as incidenciaacumuladaanual --con todos los decimales
       ,(case when c.nivel = 0 then
               round(((round(c.indice::decimal,2) - round(ca.indice::decimal,2)) * c.ponderador / round(pa.indice::decimal,2) * 100)::decimal, 1) -- a un decimal para nivel 0
              when c.nivel = 1 then
               round(((round(c.indice::decimal,2) - round(ca.indice::decimal,2)) * c.ponderador / round(pa.indice::decimal,2) * 100)::decimal, 2) -- a dos decimales para nivel 1
              else null
       end)::double precision as incidenciaacumuladaanualredondeada
       , CASE WHEN cb.IndiceRedondeado=0 THEN null ELSE round((c.IndiceRedondeado::decimal/cb.IndiceRedondeado::decimal*100-100)::numeric,1) END as variacioninteranualredondeada
       , CASE WHEN cb.Indice=0 THEN null ELSE (c.Indice::decimal/cb.Indice::decimal*100-100)::decimal END as variacioninteranual
       , CASE WHEN c_3.Indice=0 THEN null ELSE (c.Indice::decimal/c_3.Indice::decimal*100-100) END as variaciontrimestral
       , CASE WHEN ca.indiceRedondeado=0 THEN null ELSE round((c.indiceRedondeado/ca.indiceRedondeado*100-100)::numeric,1) END as variacionacumuladaanualredondeada
       , CASE WHEN ca.indice=0 THEN null ELSE c.indice/ca.indice*100-100 END as variacionacumuladaanual,
       c.ponderadorimplicito, 'Z'||substr(c.grupo,2) as ordenpor,
       CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, pr.responsable, p."cluster"
   from calgru c
     join calculos l on c.periodo = l.periodo and c.calculo = l.calculo
     join parametros t on unicoregistro
     left join calgru cb on  cb.agrupacion=c.agrupacion and cb.grupo=c.grupo and cb.calculo=l.calculoanterior  
                         and cb.periodo =periodo_igual_mes_anno_anterior(c.periodo)
     left join calgru c_3 on c_3.agrupacion=c.agrupacion and c_3.grupo=c.grupo and c_3.calculo=l.calculoanterior 
                          and c_3.periodo =moverperiodos(c.periodo,-3) --pk verificada
     left join calgru pb on  pb.calculo=l.calculoanterior AND pb.agrupacion=c.agrupacion  AND pb.periodo=periodo_igual_mes_anno_anterior(c.periodo) 
                         AND  pb.nivel = 0
     left join calgru pa on pa.calculo=l.calculoanterior AND pa.agrupacion=c.agrupacion  AND 
                             pa.periodo=(('a' || (substr(c.periodo, 2, 4)::integer - 1)) ||'m12') AND  pa.nivel = 0
     left join calgru ca on ca.agrupacion=c.agrupacion AND ca.grupo=c.grupo AND ca.calculo=l.calculoanterior 
                         AND ca.periodo =(('a' || (substr(c.periodo, 2, 4)::integer - 1)) ||'m12')
     inner join agrupaciones a on  a.agrupacion=c.agrupacion
     LEFT JOIN grupos g on c.agrupacion = g.agrupacion and c.grupo = g.grupo --pk verificada    
     LEFT JOIN productos p on c.grupo = p.producto --pk verificada
     LEFT JOIN (SELECT grupo FROM gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.grupo = gg.grupo     
     LEFT JOIN cvp.calProdResp pr on c.periodo = pr.periodo and c.calculo = pr.calculo and c.grupo = pr.producto
  where 
     a.tipo_agrupacion='INDICE';
  --order by c.periodo, c.agrupacion, c.nivel, c.grupo;

--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW caldiv_vw AS 
 SELECT c.periodo, c.calculo, c.producto, p.nombreproducto, c.division, c.prompriimpact, c.prompriimpant,
         CASE
            WHEN c.prompriimpact > 0 AND c.prompriimpant > 0 AND c.periodo IS DISTINCT FROM t.pb_desde THEN round((c.prompriimpact / c.prompriimpant * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp, c.promprel, c.promdiv, c0.promdiv AS promdivant, c.promedioredondeado, c.impdiv,
    --cantincluidos y cantrealesincluidos    
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantincluidos END AS cantincluidos, 
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantrealesincluidos END AS cantrealesincluidos, 
    c.cantrealesexcluidos, CASE WHEN c.periodo IS DISTINCT FROM t.pb_desde THEN c.promvar ELSE NULL END promvar, c.cantaltas, 
    c.promaltas, c.cantbajas, c.prombajas, c.cantimputados, c.ponderadordiv, 
    c.umbralpriimp, c.umbraldescarte, c.umbralbajaauto, c.cantidadconprecio, 
    c.profundidad, c.divisionpadre, c.tipo_promedio, c.raiz, c.cantexcluidos, 
    c.promexcluidos, c.promimputados, c.promrealesincluidos, 
    c.promrealesexcluidos, c.cantrealesdescartados, c.cantpreciostotales, 
    c.cantpreciosingresados, c.cantconprecioparacalestac, 
        CASE
            WHEN c.promdiv > 0 AND c0.promdiv > 0 AND c.periodo IS DISTINCT FROM t.pb_desde THEN round((c.promdiv / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promSinImpExt,
        CASE
            WHEN c.promSinImpExt > 0 AND c0.promdiv > 0 AND c.periodo IS DISTINCT FROM t.pb_desde THEN round((c.promSinImpExt / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinImpExt,
    --cs.varSinCambio
        CASE
            WHEN c.promrealessincambio > 0 AND c.promrealessincambioAnt > 0 AND c.periodo IS DISTINCT FROM t.pb_desde THEN round((c.promrealessincambio / c.promrealessincambioAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinCambio,
    --cs.varSinAltasBajas
        CASE
            WHEN c.promsinaltasbajas > 0 AND c.promsinaltasbajasAnt > 0 AND c.periodo IS DISTINCT FROM t.pb_desde THEN round((c.promsinaltasbajas / c.promsinaltasbajasAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinAltasBajas,
    CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, r.responsable, p."cluster", c.promImputadosInactivos, c.cantimputadosinactivos,
    CASE WHEN c.division = '0' AND c.periodo IS DISTINCT FROM t.pb_desde THEN cg.variacion_indice ELSE NULL END as variacion_indice
   FROM cvp.caldiv c
   JOIN cvp.parametros t on unicoregistro
   LEFT JOIN cvp.productos p on c.producto = p.producto
   LEFT JOIN cvp.calculos l ON c.periodo = l.periodo and c.calculo = l.calculo  
   LEFT JOIN cvp.caldiv c0 ON c0.periodo = l.periodoanterior AND 
       c0.calculo = l.calculoanterior AND --((c.calculo = 0 and c0.calculo = c.calculo) or (c.calculo > 0 and c0.calculo = 0)) AND 
       c.producto = c0.producto AND c.division = c0.division
   LEFT JOIN (SELECT grupo FROM cvp.gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.producto = gg.grupo     
   LEFT JOIN cvp.CalProdResp r on c.periodo = r.periodo and c.calculo = r.calculo and c.producto = r.producto
   LEFT JOIN (SELECT periodo, c.calculo, grupo as producto, variacion as variacion_indice
                FROM calgru c 
                JOIN calculos_def d on c.calculo = d.calculo 
                WHERE c.agrupacion = d.agrupacionprincipal and c.esproducto = 'S'
            ) cg ON c.periodo = cg.periodo AND c.calculo = cg.calculo AND  c.producto = cg.producto;
