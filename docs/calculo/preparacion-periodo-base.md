# Preparación del período base

La función periodobase() va a tomar como parámetro el período y cálculo hasta el
cual se quiere calcular. Para saber qué períodos tiene que calcular y cómo puede
usar la sentencia `for v_calculo in select...` usando la siguiente consulta sql.
Esa consulta se para en el último mes a calcular y buscar el oriden del período
base y desde allí va devolviendo cada uno de los renglones.

```sql
set search_path = cvp, public;

with recursive calculosr(periodo, calculo, esperiodobase, periodoanterior, calculoanterior) as
(
  select periodo, calculo, esperiodobase, periodoanterior, calculoanterior
    from calculos where periodo = 'a2016m01' and calculo = 0
  union
    select c.periodo, c.calculo, c.esperiodobase, c.periodoanterior, c.calculoanterior
	  from calculos c inner join calculosr r on r.calculoanterior = c.calculo and r.periodoanterior = c.periodo
)
select *
  from calculosr
  order by case when calculo < 0 then periodo else null end desc nulls last, case when calculo < 0 then null else periodo end;
```

## prototipo

(sin probar)

```sql
CREATE OR REPLACE FUNCTION cvp.periodobase(
    pPeriodoHasta text, 
    pCalculo numeric, 
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
  vCalculoRetrocede integer;
  vCorridoProp boolean:=false;
  vMaxPasos integer:=99;
  vPeriodo text;
  vDummy text;
  vMaxLoop integer;
  vParaRecorrerCalculo record;
  cParaRecorrerCalculo cursor for
    select * 
      from Calculos, parametros 
      where unicoregistro and calculo in (pCalculo,vCalculoRetrocede) 
        and periodo between vPeriodoLimiteInfPrehistoria and vPeriodoLimiteSupNormal
      order by case when calculo=pCalculo then null else periodo end desc null last, -- primero los del retroceso
               case when calculo=pCalculo then periodo else null end desc;      
begin
  vEmpezo:=clock_timestamp(); 
  -- esto tiene que estar: set search_path = cvp, comun, public;
  select calculoAnterior strict into vCalculoRetrocede
    from periodos
    where calculo = pCalculo and calculoAnterior <> pCalculo;
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
    from periodos
    where calculo in (pCalculo, vCalculoRetrocede)
      and (periodo <= pPeriodoHasta or calculo = vCalculoRetrocede);
  for vParaRecorrerCalculo in cParaRecorrerCalculo loop
    execute Calculo_Borrar(vParaRecorrerCalculo.periodo,vParaRecorrerCalculo.calculo);
    DELETE FROM calprodresp      WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
    DELETE FROM calhoggru        WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
    DELETE FROM calhogsubtotales WHERE periodo = vParaRecorrerCalculo.periodo and calculo = vParaRecorrerCalculo.calculo;
  end loop;
  execute CalBase_Periodos(vCalculo); 
  for vParaRecorrerCalculo in cParaRecorrerCalculo loop
    vPeriodo:=vParaRecorrerCalculo.periodo;
    vCalculo:=vParaRecorrerCalculo.calculo;
    vPeriodo_1:=vParaRecorrerCalculo.periodoAnterior;
    vCalculo_1:=vParaRecorrerCalculo.calculoAnterior;
    if (vPeriodo>vPeriodoLimiteSupBase or vPeriodo is null) and not vCorridoProp then
      execute Cal_PerBase_Prop(0,vPeriodoLimiteInfBase,vPeriodoLimiteSupBase);
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
$BODY$;```