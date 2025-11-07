-- FUNCTION: ccc.cal_ccc_borrar(text, integer)

-- DROP FUNCTION IF EXISTS ccc.cal_ccc_borrar(text, integer);

CREATE OR REPLACE FUNCTION ccc.cal_ccc_borrar(
	pperiodo text,
	pcalculo integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  vAbierto character varying(1);
BEGIN
SET search_path = ccc, cvp, comun, public;

--los mensajes para bitácora de corridas los dejo en la tabla del esquema cvp
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', pTipo:='comenzo');

--Controles: Verificar que calculo no este cerrado
SELECT abierto INTO vAbierto
   FROM calculos
   WHERE periodo=pPeriodo AND calculo=pCalculo;
IF not (vAbierto='S') THEN
   EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='error',
                        pMensaje := 'ERROR no se puede recalcular CCC porque el calculo esta cerrado');
   RAISE EXCEPTION 'ERROR no se puede recalcular CCC porque el calculo esta cerrado';
END IF;
--

DELETE FROM CalProdPerAgr WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGruPer     WHERE periodo=pPeriodo AND calculo=pCalculo;
--Para ver luego, tablas para HOGARES
--DELETE FROM CalHogGru  WHERE periodo=pPeriodo AND calculo=pCalculo;
--DELETE FROM CalHogSubtotales  WHERE periodo=pPeriodo AND calculo=pCalculo;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='finalizo');

END;
$BODY$;