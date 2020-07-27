-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_SegImp(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vEmpezo  time:=clock_timestamp();
  vTermino time; 
  vPeriodo_1 Text;
  vCalculo_1 integer;
  v_agrupacion varchar(10);
  vPromPriImpAct double precision;
  vrec record;
  vCantIncluidosTipo integer;
  vumbraldescartetipo integer;
  vproducto varchar(11);
  vstrproductos   varchar(1000);
  vImpDiv varchar(100);
  vDescartedefinitivoSegImp boolean;
BEGIN
execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','comenzo');

SELECT periodoanterior, calculoanterior, cd.agrupacionprincipal, descarteDefinitivoSegImp INTO vPeriodo_1, vCalculo_1, v_agrupacion, vDescarteDefinitivoSegImp
  FROM Calculos c INNER JOIN Calculos_def cd ON c.calculo=cd.calculo
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo;

FOR vrec IN
  SELECT c.periodo,c.calculo,c.producto, c.observacion, c.informante, c.division, c.promobs, c0.promobs as promobsant,
         p.CantIncluidos , p.imputacon, p.ImpProd
    FROM CalObs c JOIN CalObs c0 ON c.periodo=pPeriodo AND c.calculo=pCalculo
                            AND c0.periodo=vPeriodo_1 AND c0.calculo=vCalculo_1
                            AND c.producto=c0.producto
                            AND c.informante=c0.informante
                            AND c.observacion=c0.observacion
                            AND c.division=c0.division
                           --AND c.antiguedadincluido >0
                            AND (c.AntiguedadIncluido >0 OR c.AntiguedadExcluido=1)
                   JOIN CalProd p  ON  c.periodo=p.periodo AND c.calculo=p.calculo 
                                   AND c.producto=p.producto 
  LOOP
    SELECT CASE WHEN vDescarteDefinitivoSegImp THEN t.CantRealesIncluidos ELSE t.CantIncluidos END, t.umbraldescarte, t.ImpDiv, t.PromPriImpAct
       INTO vCantIncluidosTipo, vumbraldescartetipo, vImpDiv, vPromPriImpAct
      FROM CalDiv t
      WHERE vrec.periodo=t.periodo AND vrec.calculo=t.calculo 
        AND vrec.producto=t.producto AND vrec.division=t.division;
    
    IF (vrec.promObs is null OR vCantIncluidosTipo <vumbraldescartetipo AND vPromPriImpAct is null OR vImpDiv='BII') AND vrec.promobsant>0 THEN
          UPDATE CalObs c 
            SET PromObs=CASE WHEN g0.Indice=0 THEN 0 ELSE vrec.promobsant*g.IndicePrel/g0.Indice END,
                 ImpObs=CASE WHEN vImpDiv='BII' THEN vImpDiv||'-'||g.ImpGru WHEN g0.Indice=0 THEN 'A0' ELSE COALESCE(g.ImpGru,'AGV') END
            FROM  CalGru g ,
                  CalGru g0  
            WHERE  c.periodo=pPeriodo AND c.calculo=pCalculo
              AND c.producto=vrec.producto
              AND c.informante=vrec.informante
              AND c.observacion=vrec.observacion
              AND c.division=vrec.division
              AND g.agrupacion=v_agrupacion AND g.grupo=vrec.imputacon 
              AND c.periodo=g.periodo AND c.calculo=g.calculo
              AND g0.agrupacion=v_agrupacion AND g0.grupo=vrec.imputacon 
              AND g0.periodo=vPeriodo_1 AND g0.calculo= vCalculo_1 ;
    END IF;
    IF vCantIncluidosTipo <vumbraldescartetipo THEN
      UPDATE Caldiv 
        SET cantrealesdescartados= vCantIncluidosTipo,
            cantrealesincluidos= 0
        WHERE vrec.periodo=periodo AND vrec.calculo=calculo 
          AND vrec.producto=producto AND vrec.division=division;
    END IF;
  END LOOP;
  
  vstrproductos='';  
  FOR vproducto IN
    SELECT DISTINCT producto 
       FROM CalObs
       WHERE periodo= pPeriodo AND impObs='A0'
       ORDER BY producto
  LOOP
     vstrproductos= comun.concato_add(vstrproductos, vproducto); 
  END LOOP;     
  vstrproductos= comun.concato_fin(vstrproductos);
  IF LENGTH(vstrproductos) >0 THEN
     execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','error'
             ,pmensaje:='Productos a imputar con informacion insuficiente del grupo con el que se imputa, reveer imputacon de : '||vstrproductos); 
  END IF;

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','finalizo');
  
END;
$$;