-- FUNCTION: ccc.calcularcccunperiodo(text, integer)

-- DROP FUNCTION IF EXISTS ccc.calcularcccunperiodo(text, integer);

CREATE OR REPLACE FUNCTION ccc.CalcularCCCUnPeriodo(pPeriodo text, pCalculo integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
as
$BODY$
declare
   vEmpezo     time;
   vTermino    time;
   vEmpezo1    time;
   vTermino1   time;
  vError text; -- periodo anterior del cálculo
  vagrup_valorizar_indexar record;

begin
  vEmpezo:=clock_timestamp();
  set search_path = ccc, cvp, comun, public;
  Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalcularCCCUnPeriodo', pTipo:='comenzo');
  execute Cal_CCC_Borrar(pPeriodo, pCalculo);
  execute Cal_CCC_Copiar(pPeriodo, pCalculo);

  analyze cvp.CalGru;
  vTermino1:=clock_timestamp();
  
  if pCalculo=20 then
    for vagrup_valorizar_indexar IN
       select agrupacion, valoriza --, case when agrupacion='A' then true else false end AS actcalprod
         from agrupaciones_ccc
         where calcular_junto_grupo='Z'
         order by agrupacion
    loop
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_CCC_Valorizar(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion/*, vagrup_valorizar_indexar.actcalprod*/);
      end if;
    end loop;
  end if;

  vTermino:=clock_timestamp();
  Raise Notice '%', 'CALCULO CCC COMPLETO: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalcularCCCUnPeriodo', pTipo:='finalizo');
end;
$BODY$;
