-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalGru_SegImp(pPeriodo TEXT, pCalculo INTEGER) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$  
DECLARE     
   vPeriodo_1  TEXT;  
   vCalculo_1  INTEGER;
   vAgrupacion VARCHAR(10);   
   vrec RECORD;
   vnivelproducto INTEGER;   
    
BEGIN   
 EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImp', pTipo:='comenzo');

 SELECT periodoanterior, calculoanterior, cd.agrupacionprincipal INTO vPeriodo_1, vCalculo_1, vAgrupacion
   FROM Calculos c INNER JOIN Calculos_def cd ON c.calculo=cd.calculo
   WHERE c.periodo=pPeriodo AND c.calculo=pCalculo;

 SELECT DISTINCT nivel INTO vnivelproducto
   FROM CalGru
   WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion=vAgrupacion AND esproducto='S';
 IF vnivelProducto IS NULL OR vNivelProducto<=0 THEN
   --RAISE EXCEPTION 'CalGru_SegImp: No se encuentra el nivel de productos en la Agrupacion Principal  "%" en la tabla CalGru para %,%',vAgrupacion,pPeriodo,pCalculo;
   EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImp', pTipo:='error', 
   pMensaje:='CalGru_SegImp: Es incorrecto el nivel de productos ('||coalesce(vNivelProducto::text,'NULL')||') en la Agrupacion Principal ' ||vagrupacion|| ' en la tabla CalGru para '||pPeriodo||' , '||pCalculo,
   pAgrupacion := vAgrupacion);
 END IF;
 FOR vNivel IN REVERSE vnivelproducto..0 LOOP
    execute CalGru_SegImpUnPaso(pPeriodo,pCalculo, 's', vNivel, vAgrupacion, vNivelProducto, vPeriodo_1, vCalculo_1);
 END LOOP;
 IF vNivelProducto>0 THEN
   FOR vNivel IN 1..vnivelproducto LOOP
     execute CalGru_SegImpUnPaso(pPeriodo,pCalculo, 'b', vnivel, vAgrupacion::CHARACTER VARYING, vNivelProducto, vPeriodo_1, vCalculo_1);
   END LOOP;
 END IF;
 EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImp', pTipo:='finalizo');   
END;  
$$;