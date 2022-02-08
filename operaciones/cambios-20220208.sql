set search_path = cvp;

CREATE OR REPLACE VIEW caldiv_vw AS 
 SELECT c.periodo, c.calculo, c.producto, p.nombreproducto, c.division, c.prompriimpact, c.prompriimpant,
         CASE
            WHEN c.prompriimpact > 0 AND c.prompriimpant > 0 THEN round((c.prompriimpact / c.prompriimpant * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp, c.promprel, c.promdiv, c0.promdiv AS promdivant, c.promedioredondeado, c.impdiv,
    --cantincluidos y cantrealesincluidos    
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantincluidos END AS cantincluidos, 
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantrealesincluidos END AS cantrealesincluidos, 
    c.cantrealesexcluidos, c.promvar, c.cantaltas, 
    c.promaltas, c.cantbajas, c.prombajas, c.cantimputados, c.ponderadordiv, 
    c.umbralpriimp, c.umbraldescarte, c.umbralbajaauto, c.cantidadconprecio, 
    c.profundidad, c.divisionpadre, c.tipo_promedio, c.raiz, c.cantexcluidos, 
    c.promexcluidos, c.promimputados, c.promrealesincluidos, 
    c.promrealesexcluidos, c.cantrealesdescartados, c.cantpreciostotales, 
    c.cantpreciosingresados, c.cantconprecioparacalestac, 
        CASE
            WHEN c.promdiv > 0 AND c0.promdiv > 0 THEN round((c.promdiv / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promSinImpExt,
        CASE
            WHEN c.promSinImpExt > 0 AND c0.promdiv > 0 THEN round((c.promSinImpExt / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinImpExt,
    --cs.varSinCambio
        CASE
            WHEN c.promrealessincambio > 0 AND c.promrealessincambioAnt > 0 THEN round((c.promrealessincambio / c.promrealessincambioAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinCambio,
    --cs.varSinAltasBajas
        CASE
            WHEN c.promsinaltasbajas > 0 AND c.promsinaltasbajasAnt > 0 THEN round((c.promsinaltasbajas / c.promsinaltasbajasAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinAltasBajas,
    CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, r.responsable
   FROM cvp.caldiv c
   LEFT JOIN cvp.productos p on c.producto = p.producto
   LEFT JOIN cvp.calculos l ON c.periodo = l.periodo and c.calculo = l.calculo  
   LEFT JOIN cvp.caldiv c0 ON c0.periodo = l.periodoanterior AND 
       c0.calculo = l.calculoanterior AND --((c.calculo = 0 and c0.calculo = c.calculo) or (c.calculo > 0 and c0.calculo = 0)) AND 
       c.producto = c0.producto AND c.division = c0.division
   LEFT JOIN (SELECT grupo FROM cvp.gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.producto = gg.grupo     
   LEFT JOIN cvp.CalProdResp r on c.periodo = r.periodo and c.calculo = r.calculo and c.producto = r.producto;
   
------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW caldivsincambio AS 
SELECT periodo, calculo, producto, division, promdivsincambio, promdivant,
       CASE
        WHEN promdivant > 0 AND promdivsincambio > 0 THEN round((promdivsincambio / promdivant * 100 - 100)::numeric, 1)
         ELSE NULL::numeric
       END AS varSinCambio
FROM (SELECT c.periodo, c.calculo, c.producto, c.division, 
        EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and c0.antiguedadIncluido>0 and r.periodo is null THEN c.PromObs ELSE NULL END))) as promdivsincambio, 
        EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and c0.antiguedadIncluido>0 and r.periodo is null THEN c0.PromObs ELSE NULL END))) as promdivant
           FROM cvp.calobs c
           LEFT JOIN 
           (SELECT DISTINCT periodo, producto, observacion, informante 
               FROM cvp.relpre 
               WHERE cambio = 'C') r 
           ON c.periodo = r.periodo and c.producto = r.producto and c.observacion = r.observacion and c.informante = r.informante
           LEFT JOIN cvp.calculos ca on c.periodo = ca.periodo and c.calculo = ca.calculo 
           LEFT JOIN cvp.calobs c0 on ca.periodoanterior = c0.periodo and ca.calculoanterior = c0.calculo and c.producto = c0.producto 
               and c.informante = c0.informante and c.observacion = c0.observacion
           LEFT JOIN cvp.caldiv d ON c.periodo = d.periodo and c.calculo = d.calculo and c.producto = d.producto and c.division = d.division
           LEFT JOIN cvp.calculos_def cf on c.calculo = cf.calculo
		WHERE cf.principal and c.impobs in ('R','RA') and c0.impobs in ('R','RA') --reales en ambos meses
        GROUP BY c.periodo, c.calculo, c.producto, c.division
     ) AS X;
	 
------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW calgru_promedios AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo,
    c.variacion,
    c.impgru,
    c.valorprel,
    c.valorgru,
    c.grupopadre,
    c.nivel,
    c.esproducto,
    c.ponderador,
    c.indice,
    c.indiceprel,
    c.incidencia,
    c.indiceredondeado,
    c.incidenciaredondeada,
    c.ponderadorimplicito,
    (c0.valorgru + c1.valorgru + c.valorgru) / 3::double precision AS valorgrupromedio
   FROM cvp.calgru c
     JOIN cvp.calculos_def cd on c.calculo = cd.calculo
     LEFT JOIN cvp.periodos p ON c.periodo::text = p.periodo::text
     LEFT JOIN cvp.calgru c0 ON c0.periodo::text = p.periodoanterior::text AND c.calculo = c0.calculo AND c.agrupacion::text = c0.agrupacion::text AND c.grupo::text = c0.grupo::text
     LEFT JOIN cvp.calgru c1 ON c1.periodo::text = cvp.moverperiodos(c.periodo::text, 1) AND c1.calculo = c.calculo AND c1.agrupacion::text = c.agrupacion::text AND c1.grupo::text = c.grupo::text
  WHERE cd.principal;
------------------------------------------------------------------------------------------------------------------

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
       , round( 
       case when (c.nivel in (0,1) ) then
              (round(c.indice::decimal,2) - round(ca.indice::decimal,2)) * c.ponderador / round(pa.indice::decimal,2) * 100
            else null
       end::decimal,2)::double precision as incidenciaacumuladaanualredondeada  -- a dos decimales para niveles 0 y 1
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
----
--pasan los hibridos al código que implementa las reglas del perbase:
CREATE OR REPLACE FUNCTION calbase_periodos(pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vSql text;
vreglas RECORD;
agrega text;
vhayreglas boolean := (select count(*) > 0 from cvp.pb_calculos_reglas where calculo = pcalculo);  
BEGIN   
  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='comenzo');

  DELETE FROM calbase_prod WHERE calculo = pCalculo;
  DELETE FROM calbase_div  WHERE calculo = pCalculo;
  DELETE FROM calbase_obs  WHERE calculo = pCalculo;

  INSERT INTO CalBase_Prod (calculo, producto, mes_inicio)
    (SELECT PCalculo, producto, max(hasta)
      FROM     
          (SELECT mp.producto, mp.minperiodo, pb.hasta 
             FROM
               (SELECT producto, min(periodo) AS minperiodo
                   FROM relpre
                   WHERE precionormalizado is not null
                   GROUP BY producto) AS mp
               CROSS JOIN pb_calculos_reglas pb
               INNER JOIN Calculos_def cd ON cd.calculo=Pcalculo  --PK verificada
               INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND mp.producto = gp.producto  --PK verificada
               WHERE pb.calculo = pCalculo AND pb.tipo_regla = 'mes inicio'
                 AND (mp.minperiodo >= hasta OR valor = 'ultima')) AS I
      GROUP BY PCalculo, producto);      
  INSERT INTO CalBase_Div  (calculo, producto, division, ultimo_mes_anterior_bajas)
    SELECT pCalculo, pd.producto, pd.division, 
       (select periodo 
          from (select periodo, row_number() over (order by periodo desc) as renglon
                  from RelPre p inner join Informantes i on p.informante=i.informante
                  where p.producto=c.producto
                    and p.precioNormalizado is not null
                    and (i.tipoInformante=pd.tipoInformante or pd.sinDividir)
                  group by periodo
                  having count(*)>umbralBajaAuto
               ) x
          where renglon=r.valor::integer+1
        ) 
    FROM pb_calculos_reglas r, 
         ProdDiv pd inner join CalBase_Prod c on c.producto=pd.producto
    WHERE c.calculo=pCalculo AND r.calculo = c.calculo
      AND r.tipo_regla='meses baja';

vSql := $$INSERT INTO calbase_obs (calculo, producto, informante, observacion, periodo_aparicion, periodo_anterior_baja$$;
if vhayreglas then
  vSql := vSql|| $$, incluido$$; 
end if;
vSql := vSql||$$) 
            SELECT calculo, producto, informante, observacion, periodo_aparicion, 
                   case when max_periodo_anterior <= ultimo_mes_anterior_bajas then max_periodo_anterior else null end$$;
if vhayreglas then
  vSql := vSql|| $$, incluido$$; 
end if;
vSql := vSql||$$ FROM
                (SELECT $$||pCalculo||$$ as calculo, r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas, 
                       min(case when Precionormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as periodo_aparicion,
                       max(case when PrecioNormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as max_periodo_anterior                     
                   $$;

for vreglas in
   SELECT num_regla, desde, hasta, valor
     FROM pb_calculos_reglas
     WHERE calculo = Pcalculo AND tipo_regla = 'inclusion'
     ORDER BY num_regla     
Loop
   vhayreglas := true;
   if vreglas.num_regla = 1 then
      agrega := ', ';
   else
      agrega := ' OR ';
   end if;
  /* con 3 reglas
  if vreglas.num_regla = 1 then
      agrega := ', ';
   else
      if vreglas.num_regla = 2 then
         agrega := ' AND (';
      else
         if vreglas.num_regla = 3 then
            agrega := ' OR ';
         end if;
      end if;
   end if;
   */
   vSql := vSql ||agrega||$$ COUNT (CASE WHEN cierre.periodo_cierre IS null AND (n.producto IS null OR (n.producto IS NOT null AND r.periodo > n.hasta_periodo))  AND periodo BETWEEN '$$||vreglas.desde||$$' AND '$$||vreglas.hasta||$$' THEN precionormalizado ELSE NULL END) >= $$ ||vreglas.valor; 
end loop;

if vhayreglas then
  /* con 3 reglas:
  vsql := vSql||$$) as incluido $$;
  */
  vsql := vSql||$$ as incluido $$;
end if;
vsql := vSql||$$
        FROM RelPre r 
          INNER JOIN Informantes i ON r.informante=i.informante -- PK verificada
          INNER JOIN (SELECT producto, division, tipoinformante, sindividir 
                        FROM proddiv
                      UNION
                      SELECT producto, divisionhibrido as division, tipoinformante, null as sindividir  
                        FROM productos, tipoinf 
                        WHERE divisionhibrido is not null and otrotipoinformante is null) pd on pd.producto=r.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
          LEFT JOIN CalBase_Div d ON d.calculo = $$||pCalculo||$$ AND r.producto = d.producto AND d.Division=pd.Division -- PK verificada
          INNER JOIN Calculos_def cd ON cd.calculo=d.calculo  --PK verificada
          INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto  --PK verificada
          LEFT JOIN Novobs_Base n ON d.calculo = n.calculo and r.producto=n.producto AND r.informante=n.informante AND r.observacion=n.observacion  --PK verificada de Novobs_base
          LEFT JOIN (select c.informante, c.periodo_cierre, a.ultimo_periodo_activo from
                       (select r.informante, r.periodo as periodo_cierre
                          from relvis r left join razones z on r.razon = z.razon
                          group by informante, periodo 
                          having min(case when coalesce(escierredefinitivoinf,'N') = 'S' or coalesce(escierredefinitivofor,'N') = 'S' then 'S' else 'N' end) =
                                 max(case when coalesce(escierredefinitivoinf,'N') = 'S' or coalesce(escierredefinitivofor,'N') = 'S' then 'S' else 'N' end) and 
                                 min(case when coalesce(escierredefinitivoinf,'N') = 'S' or coalesce(escierredefinitivofor,'N') = 'S' then 'S' else 'N' end) = 'S'
                          order by r.periodo desc) c left join
                       (select r.informante, max(periodo) ultimo_periodo_activo
                          from relvis r left join razones z on r.razon = z.razon
                          where coalesce(escierredefinitivoinf,'N') = 'N' and coalesce(escierredefinitivofor,'N') = 'N'
                          group by r.informante) a on c.informante = a.informante
                     where a.ultimo_periodo_activo is null or a.ultimo_periodo_activo < c.periodo_cierre) AS cierre on r.informante = cierre.informante
        GROUP BY r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas) as CBO;$$; 

EXECUTE vSql;

  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='finalizo');
--raise notice 'sentencia: %', vsql;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
 