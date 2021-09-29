set search_path = cvp;

--nuevos códigos para las funciones del periodo base
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
      agrega := ' OR';
   end if;
   vSql := vSql ||agrega||$$ COUNT( CASE WHEN (n.producto IS null OR (n.producto IS NOT null AND r.periodo > n.hasta_periodo))  AND periodo BETWEEN '$$||vreglas.desde||$$' AND '$$||vreglas.hasta||$$' THEN precionormalizado ELSE NULL END) >= $$ ||vreglas.valor; 
end loop;

if vhayreglas then
  vsql := vSql||$$ as incluido $$;
end if;
vsql := vSql||$$
        FROM RelPre r 
          INNER JOIN Informantes i ON r.informante=i.informante -- PK verificada
          INNER JOIN ProdDiv pd ON pd.producto=r.producto AND (pd.TipoInformante=i.TipoInformante OR pd.sinDividir) -- UK verificada
          LEFT JOIN CalBase_Div d ON d.calculo = $$||pCalculo||$$ AND r.producto = d.producto AND d.Division=pd.Division -- PK verificada
          INNER JOIN Calculos_def cd ON cd.calculo=d.calculo  --PK verificada
          INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto  --PK verificada
          LEFT JOIN Novobs_Base n ON d.calculo = n.calculo and r.producto=n.producto AND r.informante=n.informante AND r.observacion=n.observacion  --PK verificada de Novobs_base
        GROUP BY r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas) as CBO;$$; 
EXECUTE vSql;

  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='finalizo');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cvp.periodobase(
    pPeriodoHasta text, 
    pCalculo integer, 
    psolopreparar_nocalcular boolean DEFAULT false)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
declare
  vEmpezo     time;  
  vTermino    time;  
  vPeriodoLimiteInfPrehistoria text/*:='a2010m01'*/;
  vPeriodoLimiteInfBase text       /*:='a2011m07'*/;
  vPeriodoLimiteSupBase text       /*:='a2012m06'*/;
  vPeriodoLimiteSupNormal text     /*:='a2012m08'*/;
  vPrimerPeriodo text:=(select min(periodo) from periodos);
  vCalculoRetrocede integer;
  vCorridoProp boolean:=false;
  vMaxPasos integer:=99;
  vPeriodo text;
  vPeriodo_1 text;
  vCalculo integer;
  vCalculo_1 integer;
  vDummy text;
  vMaxLoop integer;
  vParaRecorrerCalculo record;
  cParaRecorrerCalculo cursor for
    select * 
      from Calculos, parametros 
      where unicoregistro and calculo in (pCalculo,vCalculoRetrocede) 
        and periodo between vPeriodoLimiteInfPrehistoria and vPeriodoLimiteSupNormal
      order by case when calculo=pCalculo then null else periodo end desc nulls last, -- primero los del retroceso
               case when calculo=pCalculo then periodo else null end;      
begin
  vEmpezo:=clock_timestamp(); 
  -- esto tiene que estar: 
  set search_path = cvp, comun, public;
  select calculoAnterior into strict vCalculoRetrocede
    from calculos
    where calculo = pCalculo and calculoAnterior <> pCalculo;
  raise notice 'Calculo Retrocede: % ', vCalculoRetrocede;
  select 
      min(periodo) filter (where calculo = pCalculo),
      min(periodo) filter (where calculo = pCalculo and calculoAnterior = vCalculoRetrocede),
      max(periodo) filter (where calculo = vCalculoRetrocede),
      max(periodo) filter (where calculo = pCalculo)
    into 
      vPeriodoLimiteInfPrehistoria,
      vPeriodoLimiteInfBase,
      vPeriodoLimiteSupBase,
      vPeriodoLimiteSupNormal
    from calculos
    where calculo in (pCalculo, vCalculoRetrocede)
      and (periodo <= pPeriodoHasta or calculo = vCalculoRetrocede);

  raise notice 'Limite Inferior de la Prehistoria: % ', vPeriodoLimiteInfPrehistoria;
  raise notice 'Limite Inferior del Periodo Base : % ', vPeriodoLimiteInfBase;
  raise notice 'Limite Superior del Periodo Base : % ', vPeriodoLimiteSupBase;
  raise notice 'Limite Superior de los PNormales : % ', vPeriodoLimiteSupNormal;

  for vParaRecorrerCalculo in cParaRecorrerCalculo loop
    execute Calculo_Borrar(vParaRecorrerCalculo.periodo,vParaRecorrerCalculo.calculo);
    DELETE FROM calprodresp      WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
    DELETE FROM calhoggru        WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
    DELETE FROM calhogsubtotales WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
  end loop;
  execute CalBase_Periodos(pCalculo); 
  for vParaRecorrerCalculo in cParaRecorrerCalculo loop
    vPeriodo:=vParaRecorrerCalculo.periodo;
    vCalculo:=vParaRecorrerCalculo.calculo;
    vPeriodo_1:=vParaRecorrerCalculo.periodoAnterior;
    vCalculo_1:=vParaRecorrerCalculo.calculoAnterior;
    if (vPeriodo>vPeriodoLimiteSupBase or vPeriodo is null) and not vCorridoProp then    
	  execute Cal_PerBase_Prop(pCalculo,vPeriodoLimiteInfBase,vPeriodoLimiteSupBase);
      vCorridoProp:=true;
    end if;
    raise notice 'vPeriodo: %    vcalculo: %     vPeriodo_1: %       vcalculo_1: %', vPeriodo, vcalculo, vperiodo_1, vcalculo_1;
    if not pSoloPreparar_NoCalcular then
      select CalcularUnPeriodo(vPeriodo, vCalculo)
        into vDummy;
    end if;
  end loop;
  vTermino:=clock_timestamp();  
  Raise Notice '%', 'PERIODO BASE: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);  
  return 'Periodo base finalizado'||(vTermino - vEmpezo);
exception
  when others then
    execute Cal_Mensajes(coalesce(vPeriodo,vPrimerPeriodo), coalesce(vCalculo,0), 'PeriodoBase', 'error', pMensaje:='ERROR DE EJECUCION ' || sqlstate || ': ' || sqlerrm);
    raise;
    RETURN 'Ejecuto con error ' || sqlstate || ': ' || sqlerrm;
end;
$BODY$;
