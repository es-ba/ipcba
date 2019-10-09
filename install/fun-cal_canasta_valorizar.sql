CREATE OR REPLACE FUNCTION Cal_Canasta_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion Text, pActualizarCalProd Boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
vindice double precision;
vparavariosHogares BOOLEAN;
BEGIN
SET search_path = cvp, comun, public;  --porque se corre suelto  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_Canasta_Valorizar', pTipo:='comenzo');  
SELECT indice INTO vindice
  FROM CalGru
  WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion='Z' and nivel=0 ;
IF vindice is null THEN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_Canasta_Valorizar', pTipo:='error', pMensaje:='No está calculado el Indice para el nivel Z0', pAgrupacion:=pAgrupacion);  
ELSE 
  SELECT paravarioshogares INTO vparavariosHogares
    FROM agrupaciones
    WHERE agrupacion=pAgrupacion; 
  EXECUTE Cal_Canasta_Borrar(pPeriodo, pCalculo, pAgrupacion); 
  IF pActualizarCalProd THEN
    EXECUTE CalProd_Valorizar(pPeriodo, pCalculo);
  END IF;  
  EXECUTE CalGru_Valorizar(pPeriodo, pCalculo, pAgrupacion);
  EXECUTE CalGru_Canasta_Variacion(pPeriodo, pCalculo, pAgrupacion);
  IF vparavariosHogares THEN
    EXECUTE CalHog_Valorizar(pPeriodo, pCalculo, pAgrupacion); 
    EXECUTE CalHog_Subtotalizar(pPeriodo, pCalculo, pAgrupacion); 
  END IF;
END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Canasta_Valorizar', pTipo:='finalizo');
END;
$$;
