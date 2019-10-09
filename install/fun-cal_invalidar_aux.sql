CREATE OR REPLACE FUNCTION Cal_Invalidar_aux(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER 
    AS $$
DECLARE    
vvalido    character varying(1);
vrecsiguiente record;
BEGIN  
 SELECT valido INTO vvalido
   FROM calculos 
   WHERE periodo=pPeriodo AND calculo=pCalculo ;
 IF vvalido='S' THEN 
   UPDATE calculos SET valido='N'
     WHERE periodo=pPeriodo AND calculo=pCalculo ;

   FOR vrecsiguiente in
     SELECT periodo, calculo 
       FROM calculos
       WHERE periodoanterior=pPeriodo AND calculoanterior=pCalculo
         AND (periodoanterior<>periodo OR calculoanterior<>calculo) 
   LOOP 
     EXECUTE Cal_Invalidar_aux(vrecsiguiente.periodo, vrecsiguiente.calculo);
   END LOOP;
 END IF;
END;
$$;
