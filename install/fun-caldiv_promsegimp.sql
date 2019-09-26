--UTF8: Sí
CREATE OR REPLACE FUNCTION CalDiv_PromSegImp(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vrec RECORD;
  vpromPrel DOUBLE PRECISION;
  vmarca VARCHAR(10);
  vCant INTEGER;
  vCantRealesIncluidos INTEGER;
  vCantRealesExcluidos INTEGER; 
  vpromRealesIncluidos DOUBLE PRECISION;
  vpromRealesExcluidos DOUBLE PRECISION;

  BEGIN

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_PromSegImp', pTipo:='comenzo'); 
FOR vrec IN
    SELECT t.periodo,t.calculo, t.producto, t.division, t.PromPriImpAct
      FROM CalDiv t
      WHERE t.periodo=pPeriodo AND t.calculo=pCalculo
LOOP
    SELECT EXP(AVG(LN(CASE WHEN antiguedadIncluido>0 THEN PromObs ELSE NULL END))), 
           MIN(       CASE WHEN antiguedadIncluido>0 THEN ImpObs  ELSE NULL END), 
           count(     CASE WHEN antiguedadIncluido>0 THEN 1 ELSE NULL END),
           count(CASE WHEN ImpObs IN ('R','RA') AND antiguedadIncluido>0 THEN 1 ELSE NULL END),
           count(CASE WHEN ImpObs IN ('R','RA') AND antiguedadIncluido IS NULL THEN 1 ELSE NULL END),
           EXP(AVG(LN(CASE WHEN ImpObs IN ('R','RA') AND antiguedadIncluido>0 THEN PromObs ELSE NULL END))),
           EXP(AVG(LN(CASE WHEN ImpObs IN ('R','RA') AND antiguedadIncluido IS NULL THEN PromObs ELSE NULL END)))
      INTO vpromPrel, vmarca, vCant, vCantRealesIncluidos, vCantRealesExcluidos, vpromRealesIncluidos, vpromRealesExcluidos
      FROM CalObs
      WHERE periodo=vrec.periodo AND calculo=vrec.calculo
        AND producto=vrec.producto AND division=vrec.division
        AND promObs>0;
    IF vrec.PromPriImpAct IS NULL THEN
       vPromPrel:=null;
       vmarca:='IG';
    END IF;
    UPDATE CalDiv
        SET PromPrel=vPromPrel,
             ImpDiv=vmarca,
             CantIncluidos=vCant,
             CantRealesIncluidos=vCantRealesIncluidos,
             CantRealesExcluidos=vCantRealesExcluidos,
             promRealesIncluidos=vpromRealesIncluidos,
             promRealesExcluidos=vpromRealesExcluidos
      WHERE periodo=pPeriodo AND calculo=pCalculo AND producto=vrec.producto AND division= vrec.division;
end loop;
/*
UPDATE CalDiv cd
    SET PromPrel=ot.PromPrel*cd0mt.PromDiv/cd0ot.PromDiv,
        ImpDiv='IPOT'
    FROM Calculos c   
       , CalDiv cd0mt  -- Mismo tipo mes anterior
       , Divisiones d
       , CalDiv cd0ot -- Otro tipo mes anterior
       , CalDiv ot    -- Otro tipo mes actual 
    WHERE cd.periodo=pPeriodo and cd.calculo=pCalculo -- estoy en el periodo actual
        AND cd.PromPrel is null -- Los que no pude imputar por primera imputación del mismo tipo
        AND c.calculo=cd.calculo AND c.periodo=cd.periodo
        AND cd0mt.periodo=c.periodoAnterior AND cd0mt.calculo=c.calculoAnterior AND cd0mt.producto=cd.producto AND cd0mt.division=cd.division
        AND d.division=cd.division 
        AND cd0ot.periodo=cd0mt.periodo AND cd0ot.calculo=cd0mt.calculo AND cd0ot.producto=cd0mt.producto AND cd0ot.division=d.otraDivision   
        AND ot.calculo=cd.calculo AND ot.periodo=cd.periodo AND ot.producto=cd.producto AND ot.division=d.OtraDivision
        AND cd0ot.PromDiv>0 AND ot.PromPrel>0 -- Filtro de factibilidad
        ;   
*/
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_PromSegImp', pTipo:='finalizo');

END;
$$;