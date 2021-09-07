-- FUNCTION: cvp.periodobase(boolean)

-- DROP FUNCTION cvp.periodobase(boolean);

CREATE OR REPLACE FUNCTION cvp.periodobase(
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
  vCorridoProp boolean:=false;
  vMaxPasos integer:=99;
  vPeriodo text;
  vPrimerPeriodo text:=(select min(periodo) from periodos);
  vpbCalculo integer:=(select pb_calculo from parametros where unicoregistro);
  vCalculo integer;
  vPeriodo_1 text;
  vCalculo_1 integer;
  vDummy text;
  vMaxLoop integer;
  vParaBorrarCalculo record;
  cParaBorrarCalculo cursor for
    select * 
      from Calculos, parametros 
      where unicoregistro and calculo in (0,vpbCalculo) and periodo between ph_desde and pb_supnormal
      order by case when calculo=0 then periodo else null end,
               case when calculo=vpbCalculo then periodo else null end desc;      
begin
  vEmpezo:=clock_timestamp(); 
  set search_path = cvp, comun, public;
  select ph_desde, pb_desde, pb_hasta, pb_supnormal
    into vPeriodoLimiteInfPrehistoria, vPeriodoLimiteInfBase, vPeriodoLimiteSupBase, vPeriodoLimiteSupNormal 
    from parametros
    where unicoregistro;
  for vParaBorrarCalculo in cParaBorrarCalculo loop
    execute Calculo_Borrar(vParaBorrarCalculo.periodo,vParaBorrarCalculo.calculo);
    DELETE FROM calprodresp      WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
    --DELETE FROM calhoggru        WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
    --DELETE FROM calhogsubtotales WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
  end loop;
  /* usamos los registros de la tabla calculo sin borrarlos:{
  update Calculos set periodoAnterior=null, calculoAnterior=null
    where (calculo in (0,vpbCalculo) or calculo > 0) and periodo >= vPeriodoLimiteInfPrehistoria;
  delete from Calculos where calculo in (0,vpbCalculo) and periodo >= vPeriodoLimiteInfPrehistoria;
  }*/
  delete from calculos 
    where calculo in (select pb_calculo from parametros where unicoregistro);

  if true then
    DELETE FROM pb_calculos_reglas;
    /* Por ahora, sin reglas {
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
    }*/
  end if;
  execute CalBase_Periodos(0);
  vPeriodo:=vPeriodoLimiteSupBase;
  vCalculo:=vpbCalculo;
  vPeriodo_1:=vPeriodo;
  vCalculo_1:=vCalculo;
  loop
    if (vPeriodo>vPeriodoLimiteSupBase or vPeriodo is null) and not vCorridoProp then
      execute Cal_PerBase_Prop(0,vPeriodoLimiteInfBase,vPeriodoLimiteSupBase);
      vCorridoProp:=true;
    end if;
  exit when vmaxPasos=0 or vCalculo=0 and vPeriodo>vPeriodoLimiteSupNormal;
     /* updateamos en lugar de borrar e insertar en calculos: {
     insert into Calculos (periodo , calculo , periodoAnterior, calculoAnterior, abierto, 
                          esPeriodoBase, pb_calculobase
                          )
      values             (vPeriodo, vCalculo, vPeriodo_1     , vCalculo_1     ,  'S'   , 
                          case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                          case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
                          );
    }*/
    raise notice 'vPeriodo: %    vcalculo: %     vPeriodo_1: %       vcalculo_1: %', vPeriodo, vcalculo, vperiodo_1, vcalculo_1;
    if vCalculo = vpbCalculo then
        insert into Calculos (periodo , calculo , periodoAnterior, calculoAnterior, abierto, 
                             esPeriodoBase, pb_calculobase
                             )
         values             (vPeriodo, vCalculo, vPeriodo_1     , vCalculo_1     ,  'S'   , 
                             case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                             case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
                             );
    else
       UPDATE calculos set periodoAnterior = vPeriodo_1, 
                            calculoAnterior = vCalculo_1, 
                                 abierto = 'S', 
                                 esPeriodoBase = case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                                 pb_calculobase = case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
          WHERE periodo = vPeriodo AND  calculo = vCalculo;
     end if;
     if not pSoloPreparar_NoCalcular then
      select CalcularUnPeriodo(vPeriodo, vCalculo)
        into vDummy;
    end if;
    vMaxPasos:=vMaxPasos-1;
    vPeriodo_1:=vPeriodo;
    vCalculo_1:=vCalculo;
    if vCalculo=vpbCalculo then
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