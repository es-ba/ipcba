-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_ImpExt(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

BEGIN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_ImpExt', pTipo:='comenzo');
  --Para poder calcular la variación antes de imputar por externos:
  UPDATE CalDiv SET promSinImpExt = PromDiv  
    WHERE periodo=pPeriodo AND calculo=pCalculo;
  UPDATE CalDiv p SET ImpDiv=CASE WHEN p.Promprel is null or p.impDiv ='IE' THEN 'IE' ELSE 'ES' END, 
                       PromPrel=n.PromedioExt,
                       PromDiv=n.PromedioExt,
                       PromedioRedondeado=round(n.PromedioExt::decimal,2)                       
    FROM NovProd n
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
      AND p.periodo=n.periodo AND p.calculo=n.calculo AND p.producto=n.producto
      AND p.division='0'
  ;  
 
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_ImpExt', pTipo:='finalizo');
END;
$$;