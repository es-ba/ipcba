-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_SegImp_PerBase(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vPeriodo_1 Text;
  vCalculo_1 integer;
  v_agrupacion varchar(10);
  vrec RECORD;
    
BEGIN
execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp_PerBase','comenzo');

SELECT periodoanterior, calculoanterior, cd.agrupacionprincipal INTO vPeriodo_1, vCalculo_1, v_agrupacion
  FROM Calculos c INNER JOIN Calculos_def cd ON c.calculo=cd.calculo
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.EsPeriodoBase = 'S';
  
FOR vrec IN
  SELECT c.periodo,c.calculo,c.producto, c.observacion, c.informante, c.division, c.promobs, c0.promobs as promobsant,
           x.indice, x_1.indice indiceant, n.promedioExt, n_1.promedioExt promedioExtant
    FROM CalObs c JOIN CalObs c0 ON c.periodo=pPeriodo AND c.calculo=pCalculo
                            AND c0.periodo=vPeriodo_1 AND c0.calculo=vCalculo_1
                            AND c.producto=c0.producto
                            AND c.informante=c0.informante
                            AND c.observacion=c0.observacion
                            AND c.division=c0.division
                            AND c.antiguedadincluido >0                  
          LEFT JOIN pb_externos x   ON x.producto=c.producto and x.periodo=c.periodo --PK verificada
          LEFT JOIN pb_externos x_1 ON x_1.producto=c.producto and x_1.periodo=vPeriodo_1  --PK verificada
          LEFT JOIN NovProd n   ON n.producto=c.producto and n.periodo=c.periodo AND n.calculo = pCalculo  --PK verificada
          LEFT JOIN NovProd n_1 ON n_1.producto=c.producto and n_1.periodo=vPeriodo_1 AND n_1.calculo = vCalculo_1   --PK verificada
     WHERE (x.indice is not null and x_1.indice is not null) or (n.promedioExt is not null and n_1.promedioExt is not null)
  LOOP
    IF (vrec.promObs is null AND vrec.promobsant>0 ) OR (vrec.Indice is not null AND vrec.Indiceant is not null) THEN
          UPDATE CalObs c 
            SET PromObs=CASE WHEN vrec.Indice is not null and vrec.Indiceant is not null 
                          THEN vrec.promobsant/vrec.Indiceant*vrec.Indice
                          ELSE CASE WHEN vrec.promedioExt is not null and vrec.promedioExtant is not null 
                                 THEN vrec.promobsant*vrec.promedioExt/vrec.promedioExtAnt 
                               END
                        END,
                 ImpObs='BIE'
            WHERE  c.periodo=pPeriodo AND c.calculo=pCalculo
              AND c.producto=vrec.producto
              AND c.informante=vrec.informante
              AND c.observacion=vrec.observacion
              AND c.division=vrec.division;
    END IF;
  END LOOP;  
  
execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp_PerBase','finalizo');
END;
$$;