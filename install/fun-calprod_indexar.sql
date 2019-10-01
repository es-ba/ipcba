-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalProd_Indexar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
 vEmpezo  time:=clock_timestamp();
 vTermino time; 
 vcalprod RECORD;
 
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Indexar', ptipo:='comenzo');
UPDATE CalProd p 
   SET IndicePrel=case when cd0.PromDiv is null and c.esPeriodoBase='S' and (c.pb_CalculoBase is null or c.periodo=c.periodoAnterior) then p0.indice else cd.PromPrel/cd0.PromDiv*p0.indice end,
       Indice=    case when cd0.PromDiv is null and c.esPeriodoBase='S' and (c.pb_CalculoBase is null or c.periodo=c.periodoAnterior) then p0.indice else cd.PromDiv/cd0.PromDiv*p0.indice end
   FROM CalDiv cd,
        Calculos c,
        CalDiv cd0,
        CalProd p0
   WHERE c.periodo=pPeriodo AND c.calculo=pCalculo
     AND p.periodo=c.periodo AND p.calculo=c.calculo
     AND cd.periodo=p.periodo AND cd.calculo=p.calculo AND cd.producto=p.producto AND cd.division='0'
     AND p0.periodo=c.periodoAnterior AND p0.calculo=c.calculoAnterior AND p0.producto=p.producto 
     AND cd0.periodo=p0.periodo AND cd0.calculo=p0.calculo AND cd0.producto=p0.producto AND cd0.division='0';  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Indexar', ptipo:='finalizo');
END;
$$;