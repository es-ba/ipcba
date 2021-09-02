-- FUNCTION: cvp.periodobase(boolean)

-- DROP FUNCTION cvp.periodobase(boolean);

CREATE OR REPLACE FUNCTION cvp.periodobase(
	psolopreparar_nocalcular boolean DEFAULT false)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
declare
  vEmpezo     time;  
  vTermino    time;  
  vPeriodoLimiteInfPrehistoria text:='a2010m01';
  vPeriodoLimiteInfBase text:='a2011m07';
  vPeriodoLimiteSupBase text:='a2012m06';
  vPeriodoLimiteSupNormal text:='a2012m08';
  vCorridoProp boolean:=false;
  vMaxPasos integer:=99;
  vPeriodo text;
  vPrimerPeriodo text:=(select min(periodo) from periodos);
  vCalculo integer;
  vPeriodo_1 text;
  vCalculo_1 integer;
  vDummy text;
  vMaxLoop integer;
  vParaBorrarCalculo record;
  cParaBorrarCalculo cursor for
    select * 
      from Calculos 
      where calculo in (0,-1)
      order by case when calculo=0 then periodo else null end,
               case when calculo=-1 then periodo else null end desc;      
begin
  vEmpezo:=clock_timestamp(); 
  set search_path = cvp, comun, public;
  select ph_desde, pb_desde, pb_hasta, 'a2012m08'
    into vPeriodoLimiteInfPrehistoria, vPeriodoLimiteInfBase, vPeriodoLimiteSupBase, vPeriodoLimiteSupNormal 
    from parametros
    where unicoregistro;
  for vParaBorrarCalculo in cParaBorrarCalculo loop
    execute Calculo_Borrar(vParaBorrarCalculo.periodo,vParaBorrarCalculo.calculo);
  end loop;
  update Calculos set periodoAnterior=null, calculoAnterior=null
    where calculo in (0,-1);
  delete from Calculos where calculo in (0,-1);
  if true then
    DELETE FROM pb_calculos_reglas;
    INSERT INTO pb_calculos_reglas (
    calculo,tipo_regla,num_regla,desde,hasta,valor
    ) VALUES (
    '0','mes inicio','1',null,'a2011m07','estricta'
    ),(
    '0','mes inicio','2',null,'a2010m01','ultima'
    ),(
    '0','inclusion','1','a2012m06','a2012m07','2'
    ),(
    '0','inclusion','2','a2012m05','a2012m06','2'
    ),(
    '0','inclusion','3','a2012m01','a2012m05','3'
    ),(
    '0','inclusion','4','a2010m01','a2012m05','6'
    ),(
    '0','meses baja','1',null,'a2012m07','3'
    );
  end if;
  execute CalBase_Periodos(0);
  vPeriodo:=vPeriodoLimiteSupBase;
  vCalculo:=-1;
  vPeriodo_1:=vPeriodo;
  vCalculo_1:=vCalculo;
  loop
    if (vPeriodo>vPeriodoLimiteSupBase or vPeriodo is null) and not vCorridoProp then
      execute Cal_PerBase_Prop(0,vPeriodoLimiteInfBase,vPeriodoLimiteSupBase);
      vCorridoProp:=true;
    end if;
  exit when vmaxPasos=0 or vCalculo=0 and vPeriodo>vPeriodoLimiteSupNormal;
    insert into Calculos (periodo , calculo , periodoAnterior, calculoAnterior, abierto, 
                          esPeriodoBase, pb_calculobase
                          )
      values             (vPeriodo, vCalculo, vPeriodo_1     , vCalculo_1     ,  'S'   , 
                          case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                          case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
                          );
    if not pSoloPreparar_NoCalcular then
      select CalcularUnPeriodo(vPeriodo, vCalculo)
        into vDummy;
    end if;
    vMaxPasos:=vMaxPasos-1;
    vPeriodo_1:=vPeriodo;
    vCalculo_1:=vCalculo;
    if vCalculo=-1 then
      select periodoAnterior into vPeriodo
        from Periodos
        where periodo=vPeriodo;
      if vPeriodo is null or vPeriodo<vPeriodoLimiteInfPrehistoria then
        vPeriodo:=vPeriodo_1;
        vCalculo:=0;
      end if;
    else
      select periodo into vPeriodo 
        from Periodos
        where periodoAnterior=vPeriodo;
      if vPeriodo is null then
        vMaxPasos:=0; -- Fin
      end if;
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
