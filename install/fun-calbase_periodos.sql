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
   vSql := vSql ||agrega||$$ COUNT (CASE WHEN cierre.periodo_cierre IS null AND (n.producto IS null OR (n.producto IS NOT null AND r.periodo > n.hasta_periodo)) AND ($$||vreglas.num_regla||$$ <> 2 or $$||vreglas.num_regla||$$ = 2 and pbe.producto is not null) AND periodo BETWEEN '$$||vreglas.desde||$$' AND '$$||vreglas.hasta||$$' THEN precionormalizado ELSE NULL END) >= $$ ||vreglas.valor; 
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
          left join mant.pb_estacionales pbe on r.producto = pbe.producto 
        GROUP BY r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas) as CBO;$$; 

EXECUTE vSql;

  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='finalizo');
--raise notice 'sentencia: %', vsql;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
