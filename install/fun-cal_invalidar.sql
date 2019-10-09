CREATE OR REPLACE FUNCTION Cal_Invalidar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER 
    AS $$
DECLARE    
vvalido    character varying(1);
vrecsiguiente record;
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Invalidar', pTipo:='comenzo');
EXECUTE Cal_Invalidar_aux(pPeriodo, pCalculo);
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Invalidar', pTipo:='finalizo');
END;
$$;
