-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_Bajar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vRec record;
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_Bajar', pTipo:='comenzo');
FOR vRec IN 
  SELECT DISTINCT profundidad
    FROM CalDiv cd
    WHERE cd.periodo=pPeriodo AND cd.calculo=pCalculo 
      AND (cd.PromPriImpAct IS NULL OR cd.PromPriImpAnt IS NULL)
    ORDER BY profundidad
LOOP
  UPDATE CalDiv cd
    SET PromPriImpAct=cdr.PromPriImpAct,
        PromPriImpAnt=cdr.PromPriImpAnt,
        ImpDiv=CASE WHEN cdr.ImpDiv like 'I%' THEN cdr.ImpDiv ELSE 'IO'||cdr.profundidad END
    FROM CalDiv cdr
    WHERE (cd.PromPriImpAct IS NULL OR cd.PromPriImpAnt IS NULL)
      AND cd.periodo=pPeriodo AND cd.calculo=pCalculo
      AND cdr.periodo=cd.periodo AND cdr.calculo=cd.calculo AND cdr.producto=cd.producto and cdr.division=cd.divisionPadre;
END LOOP;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_Bajar', pTipo:='finalizo');   
END;
$$;