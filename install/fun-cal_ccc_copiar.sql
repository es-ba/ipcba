-- FUNCTION: ccc.cal_ccc_copiar(text, integer)

-- DROP FUNCTION IF EXISTS ccc.cal_ccc_copiar(text, integer);

CREATE OR REPLACE FUNCTION ccc.cal_ccc_copiar(
	pperiodo text,
	pcalculo integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  vAgrupPrincipal character varying(10) ;
  vParaVariosHogares boolean;
  vmaxnivel integer;
  pGrupo text;

BEGIN

SET search_path = ccc, cvp, comun, public;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Copiar', pTipo:='comenzo');

--CalProdPerAgr
  INSERT INTO CalProdPerAgr(periodo, calculo, producto, agrupacion, perfil, peso_neto, cantidad_ajuste, calorias)

  (SELECT pPeriodo, pCalculo, p.producto, pa.agrupacion, pa.perfil, pa.peso_neto, pa.cantidad_ajuste, pa.calorias
     FROM Productos_ccc p
     INNER JOIN ProdPerAgr pa on p.producto = pa.producto
     INNER JOIN agrupaciones_ccc a ON pa.agrupacion = a.agrupacion
     WHERE a.valoriza
  );

--CalGruPer --hojas
INSERT INTO CalGruPer(periodo, calculo, agrupacion, grupo, perfil, grupopadre, nivel, esproducto, ponderador)
  (SELECT pPeriodo, pCalculo, g.agrupacion, g.grupo, perfil, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
     FROM Productos_ccc p
     INNER JOIN ProdPerAgr pa on p.producto = pa.producto
     INNER JOIN agrupaciones_ccc a ON pa.agrupacion = a.agrupacion
     INNER JOIN grupos_ccc g ON pa.agrupacion = g.agrupacion and pa.producto = g.grupo
   where a.valoriza
  );
--CalGruPer --nodos
INSERT INTO CalGruPer(periodo, calculo, agrupacion, grupo, perfil, grupopadre, nivel, esproducto, ponderador)
  (SELECT distinct pPeriodo, pCalculo, gg.agrupacion, gg.grupo_padre grupo , pa.perfil, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
     FROM gru_grupos_ccc gg
     INNER JOIN agrupaciones_ccc a ON gg.agrupacion = a.agrupacion
    INNER JOIN prodperagr pa ON gg.grupo = pa.producto AND gg.agrupacion = pa.agrupacion
     INNER JOIN grupos_ccc g ON g.agrupacion = gg.agrupacion and g.grupo = gg.grupo_padre
   where a.valoriza
  );

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Copiar', pTipo:='finalizo');

 END;
$BODY$;