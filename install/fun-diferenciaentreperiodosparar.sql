CREATE OR REPLACE FUNCTION DiferenciaEntrePeriodosParaR(PeriodoInicio text, pInformante integer, pPeriodoDesde text, pPeriodoHasta text)
  RETURNS integer AS
$BODY$
--calcula la cantidad de periodos que hay entre dos períodos pPeriodoDesde, pPeriodoHasta
--si pPeriodoDesde < PeriodoInicio, entonces se empieza a contar desde PeriodoInicio.
--si no se especifica pPeriodoDesde (pPeriodoDesde= null), entonces calcular la diferencia entre 
--primera_aparicion y periodo_hasta, siendo primera_aparicion el primer periodo en el que aparece el informante
  DECLARE
  intervalo integer;
  minper text;
  BEGIN
  if pPeriodoDesde is null then
    --periodo de aparición del informante:
    SELECT min(periodo) INTO minper 
      from cvp.relpre
      where informante = pInformante;
    select count(*) into intervalo
      from cvp.periodos 
      where PeriodoInicio <= periodo and minper <= periodo and periodo < pPeriodoHasta;
      --intervalo = intervalo + 1;
  else
    select count(*) into intervalo
      from cvp.periodos 
      where PeriodoInicio <= periodo and pPeriodoDesde < periodo and periodo < pPeriodoHasta;
  END IF;
  RETURN intervalo;
  END;
$BODY$
  LANGUAGE 'plpgsql' SECURITY DEFINER;