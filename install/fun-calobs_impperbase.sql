-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_ImpPerBase(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  --vEmpezo  time:=clock_timestamp();
  --vTermino time; 
  vPeriodo_1 Text;
  vCalculo_1 integer;
  v_pbcalculoBase integer;
  vgrupo_raiz  Text;
BEGIN 
--perform VoyPor('CalObs_ImpPerBase');
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_ImpPerBase', pTipo:='comenzo');

SELECT c.periodoanterior, c.calculoanterior, c.pb_CalculoBase, cd.grupo_raiz
    INTO vPeriodo_1, vCalculo_1, v_pbCalculoBase, vgrupo_raiz
    FROM Calculos c, Calculos_def cd
    WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.calculo= cd.calculo;
    
INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, 
                   PromObs, ImpObs, Muestra)
  (SELECT          pPeriodo, pCalculo, a.producto, a.informante, a.observacion, pd.division,
                   c.promobs, a.impobs, i.Muestra
     FROM CalObs a  -- del periodo anterior
         LEFT JOIN CalObs b ON b.periodo = pPeriodo AND b.calculo=pCalculo 
                              AND b.informante = a.informante 
                              AND b.producto = a.producto AND b.observacion=a.observacion 
         JOIN Informantes i  ON a.informante=i.informante
         inner join ProdDiv pd on pd.producto=a.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
         LEFT JOIN CalObs c ON c.periodo = pPeriodo AND c.calculo= v_pbCalculoBase 
                              AND c.informante = a.informante 
                              AND c.producto = a.producto AND c.observacion=a.observacion 
         JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND a.producto=gp.producto                     
     WHERE  b.periodo IS NULL AND
             a.periodo=vPeriodo_1 AND a.calculo=vCalculo_1 AND
             a.impObs='PB' 
   );

INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, 
                   PromObs, ImpObs, Muestra)
  (SELECT          pPeriodo, pCalculo, c.producto, c.informante, c.observacion, pd.division,
                   c.promobs, c.impobs, i.Muestra
     FROM CalObs c  -- del calculo con imputacion para año base
         LEFT JOIN CalObs b ON b.periodo = pPeriodo AND b.calculo=pCalculo AND
                               b.informante = c.informante AND 
                               b.producto = c.producto AND b.observacion=c.observacion 
         JOIN Informantes i  ON c.informante=i.informante
         inner join ProdDiv pd on pd.producto=c.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
         LEFT JOIN CalObs a ON a.periodo = vPeriodo_1 AND a.calculo= vCalculo_1 AND
                               a.informante = c.informante AND
                               a.producto = c.producto AND a.observacion=c.observacion 
        JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND c.producto=gp.producto                       
     WHERE  b.periodo IS NULL AND a.periodo IS NULL AND
            c.periodo=pPeriodo AND c.calculo=v_pbCalculoBase
   );
   
   
--vTermino:=clock_timestamp();
--raise notice '%','CalObs_ImpPerBase: Empezo '||cast(vEmpezo as text)||' termino '||cast(vTermino as text)||' demoro '||(vTermino - vEmpezo);
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_ImpPerBase', pTipo:='finalizo');

END;
$$;