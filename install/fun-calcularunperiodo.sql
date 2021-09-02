CREATE OR REPLACE FUNCTION CalcularUnPeriodo(pPeriodo text, pCalculo integer) returns text
as
$BODY$
declare
   vEmpezo     time;  
   vTermino    time;  
   vEmpezo1    time;  
   vTermino1   time;  
  vError text; -- periodo anterior del cálculo
  vPeriodo_1 text;
  vEsPeriodobase text;
  vRellenante_de integer;
  v_para_rellenado_de_base boolean;
  vagrup_valorizar_indexar record;
  
begin
  vEmpezo:=clock_timestamp(); 
  set search_path = cvp, comun, public;
  Raise Notice '--------------- COMIENZA UN CÁLCULO % %',pPeriodo,pCalculo;  
  select Calculo_ControlarAbierto(pPeriodo, pCalculo) into vError;
  select PeriodoAnterior, EsPeriodoBase, para_rellenado_de_base, Rellenante_de
    into vPeriodo_1, vEsPeriodobase, v_para_rellenado_de_base, vRellenante_de
    from calculos c inner join calculos_def cd on c.calculo=cd.calculo
    where c.periodo=pPeriodo
      and c.calculo=pCalculo;
  if vError is not null then
      return vError;
  end if;
  execute Calculo_Borrar(pPeriodo, pCalculo);
  execute Cal_Copiar(pPeriodo, pCalculo);
  execute CalObs_Promedio(pPeriodo, pCalculo);
  -- execute CalObs_ImpPerBase(pPeriodo, pCalculo); 
  execute CalObs_Rellenar(pPeriodo, pCalculo);
  execute CalDiv_Rellenar(pPeriodo, pCalculo); 
  execute CalDiv_Contar(pPeriodo, pCalculo); 
  if vEsPeriodobase='S' and vRellenante_de is not null then
    update CalProd set CantPerAltaAuto=0, CantPerBajaAuto=999 where periodo=pPeriodo and calculo=pCalculo;
    -- update CalDiv set UmbralPriImp=0, UmbralDescarte=0 where periodo=pPeriodo and calculo=pCalculo;
  end if;
  --if pPeriodo=vPeriodo_1 then
  --optimizar la ejecución de cálculos en forma concurrente
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalObs;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalObs: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalProd;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalProd: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalDiv;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalDiv: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalGru;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalGru: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  --end if;
  if v_para_rellenado_de_base or pPeriodo=vPeriodo_1 then
      vEmpezo1:=clock_timestamp(); 
      update CalObs set AntiguedadIncluido=1, AntiguedadExcluido=null
          , AntiguedadConPrecio=CASE WHEN PromObs IS NULL THEN NULL ELSE 1 END
          , AntiguedadSinPrecio=CASE WHEN PromObs IS NULL THEN 1 ELSE NULL END
          , SinDatosEstacional=CASE WHEN PromObs IS NULL THEN 100 ELSE NULL END
        where periodo=pPeriodo and calculo=pCalculo;
      vTermino1:=clock_timestamp();  
      Raise Notice '%', 'update: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  else
      execute CalObs_AltasyBajas(pPeriodo, pCalculo);
  end if;  
  execute CalDiv_PromPriImp(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  execute CalDiv_Bajar(pPeriodo, pCalculo);
  execute CalObs_PriImp(pPeriodo, pCalculo);
  execute CalDiv_PromSegImp(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  if pPeriodo=vPeriodo_1 and v_para_rellenado_de_base then
    update CalProd set indice=100, indicePrel=100 where calculo=pCalculo and periodo=pPeriodo;
    update CalGru set indice=100, indicePrel=100 where calculo=pCalculo and periodo=pPeriodo;
  else
    execute CalProd_Indexar(pPeriodo, pCalculo);
  end if;
  -- execute CalProd_Valorizar(pPeriodo, pCalculo);
  execute CalGru_SegImp(pPeriodo, pCalculo);
  execute CalObs_SegImp_PerBase(pPeriodo, pCalculo);
  execute CalObs_SegImp(pPeriodo, pCalculo);
  execute CalDiv_PromFinal(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  execute CalProd_Indexar(pPeriodo, pCalculo);
  -- execute CalProd_Valorizar(pPeriodo, pCalculo);
  execute CalGru_Indexar(pPeriodo, pCalculo);
  -- execute CalGru_Valorizar(pPeriodo, pCalculo);
  execute CalGru_Info(pPeriodo, pCalculo);
   
  if pCalculo=0 then
    for vagrup_valorizar_indexar IN
       select agrupacion, valoriza, case when agrupacion='A' then true else false end AS actcalprod
         from agrupaciones
         where calcular_junto_grupo='Z'
         order by agrupacion
    loop
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_Canasta_Valorizar(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion, vagrup_valorizar_indexar.actcalprod); 
      else   
        execute CalGru_Indexar_Otro(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion); 
        execute CalGru_Info_Otro(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion); 
      end if;  
    end loop;    
  
  end if;
  execute Cal_Control(pPeriodo, pCalculo);
  
  vTermino:=clock_timestamp();  
  Raise Notice '%', 'CALCULO COMPLETO: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);  
  return 'Calculo completo en '||(vTermino - vEmpezo);
end;
$BODY$;
  language plpgsql security definer;
