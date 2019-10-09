CREATE OR REPLACE FUNCTION Cal_Canasta_Borrar(pPeriodo Text, pCalculo Integer, pAgrupacion Text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE 
  vparavariosHogares BOOLEAN;
BEGIN 
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_canasta_borrar', pTipo:='comenzo');
DELETE FROM calGru
    WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion=pAgrupacion;
    
SELECT paravarioshogares INTO vparavariosHogares
  FROM agrupaciones
  WHERE agrupacion=pAgrupacion  ;
IF vparaVariosHogares THEN  
    DELETE FROM calHogGru
      WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion=pAgrupacion;
    DELETE FROM CalHogSubtotales
      WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion=pAgrupacion;
END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_canasta_borrar', pTipo:='finalizo');

END;
$$;
