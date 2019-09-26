-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalGru_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion TEXT) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
  vNivel record;
 
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Valorizar', pTipo:='comenzo');
IF pAgrupacion IS NULL THEN 
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Valorizar', pTipo:='error', pmensaje:='Falta definir el parametro agrupacion', pagrupacion:=pAgrupacion);
ELSE
    --- se inserta todo el arbol de la agrupacion
    EXECUTE Calgru_Insertar(pPeriodo, pCalculo, pAgrupacion);
    /*
    INSERT INTO CalGru(periodo, calculo, agrupacion, grupo, grupopadre, nivel, esproducto)
      (SELECT         pPeriodo, pCalculo, g.agrupacion, g.grupo, g.grupoPadre, g.nivel, g.esProducto
         FROM Grupos g 
           WHERE g.agrupacion=pAgrupacion); 
     */      
    -- PRODUCTOS
    UPDATE CalGru cg SET ValorGru=cp.ValorProd
        FROM CalProdAgr cp
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion= pAgrupacion AND cg.grupo=cp.producto --PK verificada
          AND cg.periodo=cp.periodo AND cg.calculo=cp.calculo AND cg.agrupacion = cp.agrupacion --fk verificada
          AND cg.esproducto='S';
    --Hojas que no son producto y se construyen a partir de otra agrupacion       
    UPDATE CalGru cg SET ValorGru=cp.ValorGru
        FROM Calgru cp, Grupos g
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion= pAgrupacion AND cg.grupo=cp.grupo --PK verificada
          AND cp.periodo=cg.periodo AND cp.calculo=cg.calculo AND cp.agrupacion= g.agrupacionOrigen AND cp.grupo=cg.grupo--pk verificada
          AND cg.esproducto='N'  AND g.agrupacionOrigen IS NOT NULL
          AND g.grupo=cg.grupo AND g.agrupacion=cg.Agrupacion; --PK verificada
        
    -- GRUPOS 
    FOR vNivel IN
      SELECT cg.nivel
        FROM Grupos cg 
        WHERE cg.agrupacion = pAgrupacion AND cg.esProducto = 'N'
        GROUP BY cg.nivel
        ORDER BY cg.nivel DESC
    LOOP
      UPDATE CalGru cg SET ValorGru=SumValor
        FROM (SELECT ch.GrupoPadre, sum(ch.ValorGru) AS SumValor
                FROM CalGru ch
                WHERE ch.periodo=pPeriodo AND ch.calculo=pCalculo  AND ch.agrupacion=pAgrupacion 
                GROUP BY ch.GrupoPadre) ch
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=pAgrupacion  AND cg.grupo=ch.grupoPadre -- PK verificada
          AND cg.nivel=vNivel.nivel AND cg.esproducto='N' ;
    END LOOP;
END IF;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Valorizar', pTipo:='finalizo');
END;
$$;