-- FUNCTION: ccc.calgru_ccc_valorizar(text, integer, text)

-- DROP FUNCTION IF EXISTS ccc.calgru_ccc_valorizar(text, integer, text);

CREATE OR REPLACE FUNCTION ccc.calgru_ccc_valorizar(
	pperiodo text,
	pcalculo integer,
	pagrupacion text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  vNivel record;

BEGIN
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='comenzo');
IF pAgrupacion IS NULL THEN
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='error', pmensaje:='Falta definir el parametro agrupacion', pagrupacion:=pAgrupacion);
ELSE
    --- se inserta todo el arbol de la agrupacion
    --EXECUTE Calgru_Insertar(pPeriodo, pCalculo, pAgrupacion); --ya están agregados
    -- PRODUCTOS
    UPDATE CalGruPer cg SET ValorGru=cp.ValorProd
        FROM CalProdPerAgr cp
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion= pAgrupacion AND cg.grupo=cp.producto AND cg.perfil = cp.perfil --PK verificada
          AND cg.periodo=cp.periodo AND cg.calculo=cp.calculo AND cg.agrupacion = cp.agrupacion --fk verificada
          AND cg.esproducto='S';
    --Hojas que no son producto y se construyen a partir de otra agrupacion
    --No hay
    -- GRUPOS
    FOR vNivel IN
      SELECT cg.nivel
        FROM Grupos_ccc cg
        WHERE cg.agrupacion = pAgrupacion AND cg.esProducto = 'N'
        GROUP BY cg.nivel
        ORDER BY cg.nivel DESC
    LOOP
      UPDATE CalGruPer cg SET ValorGru=SumValor
        FROM (SELECT ch.GrupoPadre, ch.perfil, sum(ch.ValorGru) AS SumValor
                FROM CalGruPer ch
                WHERE ch.periodo=pPeriodo AND ch.calculo=pCalculo  AND ch.agrupacion=pAgrupacion
                GROUP BY ch.GrupoPadre, ch.perfil) ch
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=pAgrupacion  AND cg.grupo=ch.grupoPadre AND cg.perfil = ch.perfil -- PK verificada
          AND cg.nivel=vNivel.nivel AND cg.esproducto='N' ;
    END LOOP;
END IF;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='finalizo');
END;
$BODY$;