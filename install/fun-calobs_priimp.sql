-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_PriImp(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vPeriodo_1 Text;
  vCalculo_1 INTEGER;
  vrec record;
  
BEGIN
execute Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_PriImp', pTipo:='comenzo');

for vrec in  
  SELECT co.producto, co.informante, co.observacion, co.division, 
          co_1.promObs AS promObsAnt, cd.promPriImpAct, cd.promPriImpAnt,cd.ImpDiv, 
          (cd.Division is not null) as existe_division, 
          CASE WHEN /*CUAL{*/ cc.esperiodobase='S' AND cb.periodo_aparicion > co.periodo /*}CUAL*/ THEN  1  ELSE CASE WHEN promPriImpAnt >0 THEN promPriImpAct/promPriImpAnt ELSE null END END AS factor_imputacion,
          CASE WHEN /*CUAL{*/ cc.esperiodobase='S' AND cb.periodo_aparicion > co.periodo /*}CUAL*/ THEN 'S' ELSE 'N'  END AS marcaimp_pb --Para Indicar como se va a setear la marca de imputacion 
    FROM CalObs co 
    JOIN Calculos cc ON cc.periodo=co.periodo AND cc.calculo=co.calculo
    LEFT JOIN CalBase_Obs cb ON cb.calculo=co.calculo AND cb.producto=co.producto AND cb.observacion=co.observacion AND cb.informante=co.informante
    JOIN CalObs co_1 ON co_1.periodo=CASE WHEN /*CUAL{*/ cc.esperiodobase='S' AND cb.periodo_aparicion > co.periodo /*}CUAL*/ THEN cc.periodo ELSE cc.periodoAnterior END 
                    AND co_1.calculo=CASE WHEN /*CUAL{*/ cc.esperiodobase='S' AND cb.periodo_aparicion > co.periodo /*}CUAL*/ THEN cc.pb_calculoBase ELSE cc.calculoAnterior END 
                                       AND co_1.producto=co.producto
                                       AND co_1.informante=co.informante
                                       AND co_1.observacion=co.observacion
    LEFT JOIN CalDiv cd ON cd.periodo=co.periodo AND cd.calculo=co.calculo AND cd.producto=co.producto AND cd.division=co.division
    WHERE co.periodo=pPeriodo 
      AND co.calculo=pCalculo 
      --AND co.AntiguedadIncluido>0 
      AND (co.AntiguedadIncluido >0 OR co.AntiguedadExcluido=1)
      AND (co.promObs IS NULL OR ImpDiv='BE') 
Loop
    UPDATE calObs 
        SET promObs=vrec.promObsAnt*vrec.factor_imputacion, 
             impObs=CASE WHEN vrec.marcaimp_pb='S' THEN 'PB'
                         ELSE          
                           CASE 
                             WHEN vrec.existe_division is not true THEN 'BEFD'
                             WHEN vrec.promPriImpAnt>0 AND vrec.promPriImpAct>0 AND vrec.promObsAnt>0 THEN
                               CASE WHEN vrec.ImpDiv='BE' THEN 'BE' WHEN vrec.ImpDiv<'IP' THEN vrec.ImpDiv ELSE 'IP' END
                             ELSE impObs
                           END
                    END        
        WHERE periodo= pPeriodo AND calculo=pCalculo
          AND producto=vrec.producto AND informante=vrec.informante AND observacion=vrec.observacion; 
        IF vrec.existe_division is not true THEN
            execute Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_PriImp', pMensaje:='Falta en CalDiv un registro para '||vrec.producto||' en la division '||vrec.division, 
                                 pTipo:='error', pProducto:=vrec.producto, pDivision:=vrec.division, pInformante:=vrec.informante, pObservacion:=vrec.observacion);
        END IF;
end loop;

execute Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_PriImp', pTipo:='finalizo');
END;
$$;