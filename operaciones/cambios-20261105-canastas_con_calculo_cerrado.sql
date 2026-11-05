set search_path = ccc;
--Cal_CCC: Cálculo de las Canastas de Consumo y Crianza
------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Cal_CCC_Borrar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vAbierto character varying(1);
BEGIN
SET search_path = ccc, cvp, comun, public;

--los mensajes para bitácora de corridas los dejo en la tabla del esquema cvp
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', pTipo:='comenzo');

--Controles: Verificar que calculo ccc no este cerrado
SELECT abierto_ccc INTO vAbierto
   FROM calculos
   WHERE periodo=pPeriodo AND calculo=pCalculo;
IF not (vAbierto='S') THEN
   EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='error',
                        pMensaje := 'ERROR no se puede recalcular CCC porque el calculo CCC esta cerrado');
   RAISE EXCEPTION 'ERROR no se puede recalcular CCC porque el calculo CCC esta cerrado';
END IF;
--

DELETE FROM CalProdPerAgr WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGruPer     WHERE periodo=pPeriodo AND calculo=pCalculo;

DELETE FROM CalHogParGru  WHERE periodo=pPeriodo AND calculo=pCalculo;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='finalizo');

END;
$$;
