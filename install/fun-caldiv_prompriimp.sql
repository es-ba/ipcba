-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_PromPriImp(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vPeriodo_1 TEXT;
  vCalculo_1 Integer; 
  vrec RECORD;  
BEGIN  
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_PromPriImp','comenzo');
SELECT periodoAnterior, CalculoAnterior INTO vPeriodo_1, vCalculo_1
  FROM Calculos
  WHERE periodo=pPeriodo AND calculo=pCalculo;

for vrec in
  SELECT c.periodo, c.calculo, c.producto, c.division, 
           EXP(AVG(LN(case when c.antiguedadIncluido>0 AND c0.antiguedadIncluido>0 AND c.promObs>0 AND c0.promObs>0 then c.promObs  else null end))) as promAct, 
           EXP(AVG(LN(case when c.antiguedadIncluido>0 AND c0.antiguedadIncluido>0 AND c.promObs>0 AND c0.promObs>0 then c0.promObs else null end))) as promAnt, 
           COUNT(     case when c.antiguedadIncluido>0 AND c0.antiguedadIncluido>0 AND c.promObs>0 AND c0.promObs>0 then 1          else null end) as cant, 
           t.umbralPriImp,
           x.indice as indice, x_1.indice as indice_1
    FROM CalObs c JOIN CalObs c0 ON c.periodo=pPeriodo AND c.calculo=pCalculo
                                    AND c0.periodo=vPeriodo_1 AND c0.calculo=vCalculo_1
                                    AND c.producto=c0.producto
                                    AND c.informante=c0.informante
                                    AND c.observacion=c0.observacion
          JOIN CalDiv t   ON  t.periodo=c.periodo AND  t.calculo=c.calculo AND  t.producto=c.producto AND t.division=c.division
          JOIN CalProd cp ON cp.periodo=t.periodo AND cp.calculo=t.calculo AND cp.producto=t.producto 
          LEFT JOIN pb_externos x   ON x.producto=t.producto and x.periodo=t.periodo 
          LEFT JOIN pb_externos x_1 ON x_1.producto=t.producto and x_1.periodo=vPeriodo_1
    GROUP BY c.periodo, c.calculo, c.producto, c.division, t.umbralPriImp, x.indice, x_1.indice
Loop    
    UPDATE CalDiv t
      SET PromPriImpAct=CASE WHEN vrec.Calculo=-1 AND vrec.indice>0 AND vrec.indice_1>0 THEN vrec.indice   WHEN vrec.Cant >= vrec.umbralPriImp THEN vrec.PromAct WHEN vrec.indice>0 AND vrec.indice_1>0 THEN vrec.indice   ELSE null END,
          PromPriImpAnt=CASE WHEN vrec.Calculo=-1 AND vrec.indice>0 AND vrec.indice_1>0 THEN vrec.indice_1 WHEN vrec.Cant >= vrec.umbralPriImp THEN vrec.PromAnt WHEN vrec.indice>0 AND vrec.indice_1>0 THEN vrec.indice_1 ELSE null END, 
          ImpDiv=       CASE WHEN vrec.Calculo=-1 AND vrec.indice>0 AND vrec.indice_1>0 THEN 'BE'          WHEN vrec.Cant >= vrec.umbralPriImp THEN 'IP'         WHEN vrec.indice>0 AND vrec.indice_1>0 THEN 'BE'          ELSE 'IOD' END,
          PromVar=      CASE WHEN vrec.PromAnt<>0 THEN vrec.PromAct/vrec.PromAnt*100-100 ELSE NULL END,
          CantPriImp = vrec.cant
    WHERE t.periodo=vrec.periodo AND t.calculo=vrec.calculo AND t.producto=vrec.producto AND t.division=vrec.division;
end loop;
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_PromPriImp','finalizo');   
 
END;
$$;