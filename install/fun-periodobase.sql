-- FUNCTION: cvp.periodobase(boolean)

-- DROP FUNCTION cvp.periodobase(boolean);

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