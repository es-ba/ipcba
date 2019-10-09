CREATE OR REPLACE FUNCTION Calculo_Borrar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vAbierto character varying(1);
BEGIN  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Calculo_Borrar', pTipo:='comenzo');

--Controles: Verificar que calculo no este cerrado e invalidar los calculos siguientes   
SELECT abierto INTO vAbierto 
   FROM calculos
   WHERE periodo=pPeriodo AND calculo=pCalculo;
IF vAbierto='S' THEN
   EXECUTE Cal_Invalidar(pPeriodo,pCalculo);
ELSE
   EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Calculo_Borrar', ptipo:='error', 
                        pMensaje := 'ERROR no se puede recalcular porque el calculo esta cerrado');
   RAISE EXCEPTION 'ERROR no se puede recalcular porque el calculo esta cerrado';
END IF;
--
    
DELETE FROM CalObs     WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalDiv     WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProd    WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProdAgr WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGru     WHERE periodo=pPeriodo AND calculo=pCalculo;
--DELETE FROM CalHogGru  WHERE periodo=pPeriodo AND calculo=pCalculo;
--DELETE FROM CalHogSubtotales  WHERE periodo=pPeriodo AND calculo=pCalculo;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Calculo_Borrar', ptipo:='finalizo');

END;
$$;
