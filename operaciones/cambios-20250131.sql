set search_path = cvp;

CREATE OR REPLACE FUNCTION calculo_borrarcopia(
    pperiodo text,
    pcalculo integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$

DECLARE    
  vAbierto character varying(1);
  vCalculoprincipal integer := (select calculo from calculos_def where principal);
  vexiste integer;
  vultimocalculo integer := (select max(calculo) from calculos where periodo = pperiodo);
  vmotivocopia text;
BEGIN  

SET search_path = cvp;
--Controles: Verificar que exista el calculo que se quiere borrar
SELECT 1 INTO vexiste 
   FROM calculos c 
   WHERE periodo=pPeriodo AND calculo=pcalculo;
IF vexiste is distinct from 1 THEN 
   RAISE EXCEPTION 'ERROR no existe el periodo %, calculo %', pperiodo, pcalculo;
END IF;
--Controles: Verificar que no se quiera borrar el calculo principal
IF vCalculoprincipal=pCalculo THEN
   RAISE EXCEPTION 'ERROR no se puede borrar el cálculo principal';
END IF;
--Controles: Verificar que el calculo que se quiere borrar no sea un provisiorio   
SELECT motivocopia INTO vmotivocopia 
   FROM calculos c 
   WHERE periodo=pPeriodo AND calculo=pcalculo;
IF UPPER(vmotivocopia) LIKE '%PROVISORIO%' THEN
   RAISE EXCEPTION 'ERROR no se puede borrar porque el periodo %, calculo % esta identificado como provisorio: %', pperiodo, pcalculo, vmotivocopia;
END IF;
--Controles: Verificar que el calculo que se quiere borrar sea el último calculo para el periodo
IF vultimocalculo is distinct from pCalculo THEN
   RAISE EXCEPTION 'ERROR el cálculo % no es el último cálculo para el periodo %', pcalculo, pperiodo;
END IF;
--
    
DELETE FROM CalObs            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalDiv            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProd           WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProdAgr        WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGru            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalHogGru         WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalHogSubtotales  WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProdResp       WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM Calculos          WHERE periodo=pPeriodo AND calculo=pCalculo;

RETURN 'listo';
END;
$BODY$;
