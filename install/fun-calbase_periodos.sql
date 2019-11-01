CREATE OR REPLACE FUNCTION calbase_periodos(pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vSql text;
vreglas RECORD;
agrega text;  
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
    WHERE c.calculo=pCalculo
      AND r.tipo_regla='meses baja';

vSql := $$INSERT INTO calbase_obs (calculo, producto, informante, observacion, periodo_aparicion, periodo_anterior_baja, incluido) 
            SELECT calculo, producto, informante, observacion, periodo_aparicion, 
                   case when max_periodo_anterior <= ultimo_mes_anterior_bajas then max_periodo_anterior else null end, incluido
              FROM
                (SELECT $$||pCalculo||$$ as calculo, r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas, 
                       min(case when Precionormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as periodo_aparicion,
                       max(case when PrecioNormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as max_periodo_anterior,                     
                   $$;

for vreglas in
   SELECT num_regla, desde, hasta, valor
     FROM pb_calculos_reglas
     WHERE calculo = Pcalculo AND tipo_regla = 'inclusion'
     ORDER BY num_regla     
Loop
   if vreglas.num_regla = 1 then
      agrega := '';
   else
      agrega := ' OR';
   end if;
   vSql := vSql ||agrega||$$ COUNT( CASE WHEN (n.producto IS null OR (n.producto IS NOT null AND r.periodo > n.hasta_periodo))  AND periodo BETWEEN '$$||vreglas.desde||$$' AND '$$||vreglas.hasta||$$' THEN precionormalizado ELSE NULL END) >= $$ ||vreglas.valor; 
end loop;

vsql := vSql||$$ as incluido 
        FROM RelPre r 
          INNER JOIN Informantes i ON r.informante=i.informante -- PK verificada
          INNER JOIN ProdDiv pd ON pd.producto=r.producto AND (pd.TipoInformante=i.TipoInformante OR pd.sinDividir) -- UK verificada
          LEFT JOIN CalBase_Div d ON d.calculo = $$||pCalculo||$$ AND r.producto = d.producto AND d.Division=pd.Division -- PK verificada
          INNER JOIN Calculos_def cd ON cd.calculo=d.calculo  --PK verificada
          INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto  --PK verificada
          LEFT JOIN Novobs_Base n ON r.producto=n.producto AND r.informante=n.informante AND r.observacion=n.observacion  --PK verificada de Novobs_base
        GROUP BY r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas) as CBO;$$; 
EXECUTE vSql;

  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='finalizo');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;