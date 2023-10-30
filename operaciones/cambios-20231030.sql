set search_path =cvp;
CREATE OR REPLACE VIEW calgru_vw AS
select c.periodo, c.calculo, c.agrupacion, c.grupo
       , COALESCE(g.nombregrupo,p.nombreproducto) AS nombre 
       , c.variacion, c.impgru, c.grupopadre, c.nivel, c.esproducto, c.ponderador, c.indice, c.indiceprel
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