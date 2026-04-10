-- FUNCTION: ccc.cal_ccc_valorizar(text, integer, text)

-- DROP FUNCTION IF EXISTS ccc.cal_ccc_valorizar(text, integer, text);

CREATE OR REPLACE FUNCTION ccc.cal_ccc_valorizar(
	pperiodo text,
	pcalculo integer,
	pagrupacion text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
vindice double precision;
vparavariosHogares BOOLEAN;
BEGIN
SET search_path = ccc, cvp, comun, public;  --porque se corre suelto
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='comenzo');
SELECT indice INTO vindice
  FROM CalGru
  WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion='Z' and nivel=0 ;
IF vindice is null THEN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='error', pMensaje:='No está calculado el Indice para el nivel Z0', pAgrupacion:=pAgrupacion);
ELSE
  SELECT paravarioshogares INTO vparavariosHogares
    FROM agrupaciones_ccc
    WHERE agrupacion=pAgrupacion;

  EXECUTE CalProd_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);  --valoriza productos de ccc

  --EXECUTE Cal_Canasta_Borrar(pPeriodo, pCalculo, pAgrupacion);  ya se borró en Cal_CCC_Borrar, falta ver más adelante las tablas de hogares

  EXECUTE CalGru_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);

  --EXECUTE CalGru_Canasta_Variacion(pPeriodo, pCalculo, pAgrupacion); falta ver más adelante el cálculo de la variacion

  --IF vparavariosHogares THEN      ---- falta ver más adelante las tablas de hogares
  --  EXECUTE CalHog_Valorizar(pPeriodo, pCalculo, pAgrupacion);
  --  EXECUTE CalHog_Subtotalizar(pPeriodo, pCalculo, pAgrupacion);
  --END IF;
END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Valorizar', pTipo:='finalizo');
END;
$BODY$;