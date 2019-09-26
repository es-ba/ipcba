-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalGru_Canasta_Variacion(pPeriodo TEXT, pCalculo INTEGER, pAgrupacion TEXT) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$      
 
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Canasta_Variacion', pTipo:='comenzo');
 
  UPDATE CalGru c
    SET variacion=CASE WHEN c0.valorgru=0 THEN null ELSE round((c.valorgru/c0.valorgru*100-100)::decimal,1) END
    FROM CalGru c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo; --Pk verificada
  
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Canasta_Variacion', pTipo:='finalizo');
END;  
$$;