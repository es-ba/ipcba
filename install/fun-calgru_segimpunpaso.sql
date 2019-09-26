-- UTF8:Sí

CREATE OR REPLACE FUNCTION CalGru_SegImpUnPaso(pPeriodo TEXT, pCalculo INTEGER, pEtapa CHARACTER VARYING, pNivel INTEGER, 
                                               pAgrupacion CHARACTER VARYING, pNivelProducto INTEGER,
                                               pPeriodo_1 TEXT, pCalculo_1 INTEGER) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$  
DECLARE     
   vrec RECORD;
   vsumaHijos double precision;
   vimpMarca VARCHAR(10);
   vCantHijosConDato INTEGER;
   vSumaHijosAnt DOUBLE PRECISION;
   vValorPrel DOUBLE PRECISION;
   vMarca VARCHAR(10);
   vgrupoPadreAct VARCHAR(9);
   vvalorPadreAct DOUBLE PRECISION;
   vimpPadreAct VARCHAR(10);
   vgrupoPadreAnt VARCHAR(9);
   vvalorPadreAnt DOUBLE PRECISION;
   vimpPadreAnt VARCHAR(10);
   vImputaCon   VARCHAR(9);
   vSumaEncadenados double precision;
   vSumaEncadenadosAnt double precision;
   vIndicePrel double precision;
   vSumaPonderadores double precision;
   vIndicePadreAct double precision;
   vIndicePadreAnt double precision;
   vDenominadorDefinitivoSegImp boolean;
BEGIN   
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImpUnPaso', pTipo:='comenzo');
  select denominadorDefinitivoSegImp into vDenominadorDefinitivoSegImp
    from calculos 
    where calculo=pCalculo and periodo=pPeriodo;
CASE pEtapa
WHEN 's' THEN
    IF pnivel= pnivelproducto THEN
      UPDATE calgru g
        SET valorPrel= p.valorPrel,
            IndicePrel=p.IndicePrel,
            impGru = CASE WHEN p.IndicePrel IS NULL THEN 'IG'
                          ELSE p.impProd
                     END 
        FROM calprod p
        WHERE g.periodo=pPeriodo and g.calculo=pCalculo
            AND p.periodo=g.periodo AND p.calculo=g.calculo AND p.producto=g.grupo
            AND g.agrupacion=pAgrupacion AND g.nivel=pnivel AND g.esproducto='S';
    ELSE
      for vrec in  
        SELECT a.periodo, a.calculo, a.agrupacion, a.grupo,  COUNT(*) as CantHijos,
               b.valorGru as valorGruAnt, b.indice as indiceAnt, a.ponderador
          FROM   Calgru a
            JOIN CalGru b ON a.periodo= pPeriodo AND a.calculo= pCalculo
                             AND a.agrupacion= pAgrupacion AND a.nivel= pNivel
                             AND b.periodo= pPeriodo_1 AND b.calculo= pCalculo_1                                   
                             AND b.agrupacion= a.agrupacion AND b.grupo= a.grupo AND b.nivel= a.nivel
                             AND a.indicePrel IS NULL
                            -- AND a.valorPrel IS NULL  -- ESTA CONDICION estaría de mas, no?
            JOIN CalGru h ON h.periodo= a.Periodo AND h.calculo= a.calculo 
                                 AND h.agrupacion=a.agrupacion AND h.grupopadre=a.grupo                     
          GROUP BY a.periodo, a.calculo, a.agrupacion, a.grupo, b.ValorGru, b.indice, a.ponderador
      Loop  
        SELECT SUM(g.ValorPrel) as sumaHijos, MIN(g.impGru) as impMarca, COUNT(*) as CantHijosConDato, SUM(g0.ValorGru) as SumaHijosAnt,
               SUM(g.IndicePrel*g.ponderador) as sumaEncadenados, SUM(CASE WHEN vDenominadorDefinitivoSegImp THEN g0.Indice ELSE g0.IndicePrel END*g.ponderador) as sumaEncadenadosAnt, sum(g.ponderador) as sumaPonderadores
          INTO vsumaHijos, vimpMarca, vCantHijosConDato, vSumaHijosAnt, vSumaEncadenados, vSumaEncadenadosAnt, vSumaPonderadores
          FROM  Calgru g JOIN CalGru g0 ON g.periodo= pPeriodo AND g.calculo=pCalculo
                                          AND g.agrupacion=vrec.agrupacion AND g.grupopadre=vrec.grupo
                                          AND g0.periodo= pPeriodo_1 AND g0.calculo= pCalculo_1 
                                          AND g0.agrupacion=g.agrupacion AND g0.grupo=g.grupo 
                                          AND g.indicePrel>0 AND g0.indice>0 ;
        IF vcanthijosConDato>0 THEN
          IF vcantHijosConDato=vrec.cantHijos THEN
              vIndicePrel=vSumaEncadenados/vSumaPonderadores; 
              vvalorprel=vsumaHijos;
              vmarca=vimpMarca;
          ELSE
              vIndicePrel=vrec.indiceAnt*vSumaEncadenados/vSumaEncadenadosAnt;
              vvalorprel=vsumaHijos*vrec.valorGruAnt/vsumaHijosAnt;
              vmarca='IG'||pnivel;
          END IF;    
          UPDATE CalGru 
            SET valorPrel=vvalorPrel, impGru=vmarca, indicePrel=vIndicePrel
            WHERE periodo=vrec.periodo AND calculo=vrec.calculo AND agrupacion=vrec.agrupacion AND grupo=vrec.grupo;         
        END IF;
      end loop;  
    END IF;
WHEN 'b' THEN  
   -- Graciela
      FOR vrec in  
        SELECT g.agrupacion, g.grupo ,g.grupopadre
          FROM  Calgru g
          WHERE g.periodo=pPeriodo AND g.calculo=pCalculo AND g.IndicePrel IS null AND g.nivel=pnivel    
      LOOP
        IF pnivel IS DISTINCT FROM pnivelproducto THEN 
          SELECT g.grupo,  g.valorprel, g.ImpGru ,  g.IndicePrel,
                 g0.grupo, g0.valorGru, g0.ImpGru, g0.Indice
            INTO vgrupopadreact, vvalorpadreact, vimppadreact, vIndicePadreAct,
                 vgrupopadreant, vvalorpadreant, vimppadreant, vIndicePadreAnt
            FROM  Calgru g, Calgru g0
            WHERE g.periodo=pPeriodo AND g.calculo=pCalculo AND g.agrupacion=vrec.agrupacion 
              AND g.grupo=vrec.grupopadre 
              AND g0.periodo=pPeriodo_1 AND g0.calculo=pCalculo_1 AND g0.agrupacion=vrec.agrupacion 
              AND g0.grupo=vrec.grupopadre AND g0.nivel=g.nivel;
        ELSE --pnivel=vnivelproducto entonces usar imputacon
          --ImputaCon está en CalProd
           SELECT  ImputaCon  INTO vimputacon
             FROM Calprod 
             WHERE periodo=pPeriodo AND calculo=pCalculo 
               AND producto=vrec.grupo ; 
             --El select a continuación es similar al anterior se puede ver despues si se juntan optimizan 
           SELECT g.grupo,  g.valorprel, g.ImpGru,  g.IndicePrel,
                 g0.grupo, g0.valorGru, g0.ImpGru, g0.Indice
             INTO vgrupopadreact, vvalorpadreact , vimppadreact, vIndicePadreAct,
                  vgrupopadreant, vvalorpadreant , vimppadreant, vIndicePadreAnt
             FROM  Calgru g, Calgru g0
             WHERE g.periodo=pPeriodo AND g.calculo=pCalculo AND g.agrupacion=vrec.agrupacion 
               AND g.grupo=vimputacon 
               AND g0.periodo=pPeriodo_1 AND g0.calculo=pCalculo_1 AND g0.agrupacion=vrec.agrupacion 
               AND g0.grupo=vimputacon   AND g0.nivel=g.nivel;    
            --raise notice 'Paso dir % nivel %  grupo % grupopadreact %  valorpadreact %, grupopadreant % , valorpadreant %', pEtapa, pnivel, vrec.grupo, vgrupopadreact,vvalorpadreact, vgrupopadreant, vvalorpadreant; 
        END IF;
        UPDATE Calgru g
          SET ValorPrel=g0.valorgru*CASE WHEN vvalorpadreant=0 THEN 0 ELSE vvalorpadreact/vvalorpadreant END,
              IndicePrel=g0.Indice*CASE WHEN vIndicePadreAnt>0 THEN vIndicePadreAct/vIndicePadreAnt ELSE null END,
              ImpGru=CASE WHEN g0.Indice IS NULL THEN 'AGN' ELSE vimppadreact END
          FROM Calgru g0 
          WHERE g.periodo=pPeriodo AND g.calculo=pCalculo AND g.IndicePrel IS null AND g.nivel=pnivel
            AND g0.periodo=pPeriodo_1 AND g0.calculo=pCalculo_1 AND g0.grupo=g.grupo AND g0.agrupacion=g.agrupacion 
            AND g0.nivel=g.nivel AND g.grupo=vrec.grupo;
      END LOOP;   
ELSE
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImpUnPaso', pTipo:='error', pMensaje:='CalGru_SegImpUnPaso: Valor de etapa invalido: ' || pEtapa);
END CASE;  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_SegImpUnPaso', pTipo:='finalizo');
    
END;  
$$;