-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalGru_Indexar_Otro(pPeriodo Text, pCalculo Integer, pAgrupacion TEXT) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
 vValorProd double precision;
 vImpProd character varying(10);
 vcalgru record;
 vNivel record;
 vAgrupacion text;
 vencadenadong double precision;
BEGIN  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Indexar_Otro', pTipo:='comenzo'); 
IF pAgrupacion IS NULL THEN  --agrupacion principal
    SELECT AgrupacionPrincipal INTO vAgrupacion
        FROM Calculos_def
        WHERE calculo=pCalculo;
ELSE
    vAgrupacion:=pAgrupacion;
    EXECUTE CalGru_Insertar(pPeriodo, pCalculo, vAgrupacion);
END IF;
-- PRODUCTOS
UPDATE CalGru cg SET Indice=cp.Indice, ImpGru=cp.ImpProd, ponderadorImplicito = cp.Indice * cg.ponderador
  FROM CalProd cp
  WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=vAgrupacion AND cg.esproducto='S'
    AND cg.periodo=cp.periodo AND cg.calculo=cp.calculo AND cg.grupo=cp.producto;
FOR vNivel IN
  SELECT cg.nivel, cg.agrupacion
    FROM CalGru cg INNER JOIN Calculos c ON cg.periodo=c.periodo AND cg.calculo=c.calculo
    WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=vAgrupacion -- AND cg.esproducto='N'
    GROUP BY cg.nivel, cg.agrupacion
    ORDER BY cg.nivel DESC
LOOP
  -- GRUPOS
  UPDATE CalGru cg SET Indice=encadenado/cg.ponderador, ImpGru=MinImp, ponderadorImplicito = encadenado
    FROM (SELECT ch.GrupoPadre, sum(ch.Indice*ch.ponderador) AS encadenado, min(ch.ImpGru) as MinImp
            FROM CalGru ch
            WHERE ch.periodo=pPeriodo AND ch.calculo=pCalculo  
            GROUP BY ch.GrupoPadre) ch
    WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=vNivel.agrupacion AND cg.esproducto='N' 
      AND cg.nivel=vNivel.nivel AND cg.grupo=ch.grupoPadre;
END LOOP;

SELECT sum(ng.Indice*ng.ponderador) INTO vencadenadong
  FROM CalGru ng
  WHERE ng.periodo=pPeriodo AND ng.calculo=pCalculo and ng.agrupacion = vagrupacion and ng.nivel = 1  
  GROUP BY ng.GrupoPadre;

UPDATE CalGru cg SET ponderadorimplicito = ponderadorimplicito/vencadenadong
  WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo and cg.agrupacion = vagrupacion;  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Indexar_Otro', pTipo:='finalizo');
END;
$$;

CREATE OR REPLACE FUNCTION CalGru_Indexar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN  
  execute CalGru_Indexar_Otro(pPeriodo, pCalculo, null);
END;
$$;