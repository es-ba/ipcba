-- FUNCTION: ccc.calprod_ccc_valorizar(text, integer, text)

-- DROP FUNCTION IF EXISTS ccc.calprod_ccc_valorizar(text, integer, text);

CREATE OR REPLACE FUNCTION ccc.calprod_ccc_valorizar(
	pperiodo text,
	pcalculo integer,
	pagrupacion text DEFAULT NULL::text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  vcalprod RECORD;

BEGIN
set search_path = ccc, cvp;

Raise Notice 'Hola calProd_CCC_valorizar ' /*, vcalprod.peso_neto * vcalprod.factor_correccion */;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='comenzo');

FOR vcalprod IN
  SELECT a.periodo, a.calculo, a.producto, a.agrupacion, a.perfil, a.peso_neto, a.calorias, p.factor_correccion, p.cantidad, c.promedioredondeado, a.cantidad_ajuste
    FROM CalDiv c
    INNER JOIN CalProdPerAgr a ON c.producto = a.producto
    INNER JOIN productos_ccc p ON a.producto = p.producto
    WHERE c.division = '0' and c.periodo=pPeriodo AND c.calculo=pCalculo AND a.agrupacion = pAgrupacion
LOOP
   --Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;

 UPDATE CalProdPerAgr
   SET peso_bruto       = vcalprod.peso_neto * vcalprod.factor_correccion
   , cantidad_canasta = coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad
   , valorProd        = vcalprod.PromedioRedondeado * (coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad)
   WHERE periodo = vcalprod.periodo AND calculo = vcalprod.calculo AND producto = vcalprod.producto AND agrupacion = vcalprod.agrupacion AND perfil = vcalprod.perfil;
END LOOP;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='finalizo', pagrupacion:=pagrupacion);
END;
$BODY$;