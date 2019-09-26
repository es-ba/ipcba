-- UTF8:Sí 

CREATE OR REPLACE FUNCTION calgru_insertar(pPeriodo Text, pCalculo Integer, pAgrupacion TEXT) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
  vNivel record;
 
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'calgru_insertar', pTipo:='comenzo');
IF pAgrupacion IS NULL THEN 
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'calgru_insertar', pTipo:='error', pmensaje:='Falta definir el parametro agrupacion', pagrupacion:=pAgrupacion);
ELSE
    --- se inserta todo el arbol de la agrupacion
    INSERT INTO CalGru(periodo, calculo, agrupacion, grupo, grupopadre, nivel, esproducto, ponderador)
      (SELECT         pPeriodo, pCalculo, g.agrupacion, g.grupo, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
         FROM Grupos g 
           WHERE g.agrupacion=pAgrupacion); 
END IF;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'calgru_insertar', pTipo:='finalizo');
END;
$$;