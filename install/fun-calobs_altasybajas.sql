-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_AltasYBajas(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vPeriodo_1 Text;
  vCalculo_1 INTEGER;
  vAgrupacionPrincipal text;
  vrec record;
  vGrupo text;
BEGIN  
execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_AltasyBajas','comenzo');  

SELECT periodoAnterior, CalculoAnterior, grupo_Raiz, cd.AgrupacionPrincipal
  INTO vPeriodo_1, vCalculo_1, vGrupo, vAgrupacionPrincipal
  FROM Calculos c inner join calculos_def cd on c.calculo=cd.calculo
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo;

-- Cuando registro de CalObs no tiene anterior en CalObs
execute Cal_Mensajes(pPeriodo, pCalculo,'Update 1','log','Cuando registro de CalObs no tiene anterior en CalObs');  
UPDATE CalObs AS c 
  SET AntiguedadConPrecio= CASE WHEN c.promObs IS NULL THEN NULL
                                ELSE 1
                           END,
      AntiguedadsinPrecio= CASE WHEN c.promObs IS NOT NULL THEN NULL
                                ELSE 1
                           END,
      SinDatosEstacional=CASE WHEN c.promObs IS NOT NULL THEN NULL
                              ELSE CASE WHEN p.CantidadConPrecio<p.umbralBajaAuto THEN 1 ELSE 0 END
                         END,
      AntiguedadExcluido= CASE WHEN c.promObs is not null and (
                                        c.periodo <= coalesce(m.alta_inmediata_hasta_periodo,'a0000m00')
                                     or cp.CantPerAltaAuto = 1
                             ) THEN NULL
                             ELSE 1
                          END,   
      AntiguedadIncluido= CASE WHEN c.promObs is not null and (
                                        c.periodo <= coalesce(m.alta_inmediata_hasta_periodo,'a0000m00')
                                     or cp.CantPerAltaAuto = 1
                              ) THEN 1
                              ELSE NULL 
                          END    
      
  FROM CalDiv p, Muestras m, CalProd cp
  WHERE c.periodo=pPeriodo
    AND c.calculo=pCalculo
    AND p.periodo= pPeriodo
    AND p.calculo= pCalculo
    AND p.producto= c.producto
    AND p.division=c.division
    AND c.muestra= m.muestra
    AND cp.periodo=pPeriodo
    AND cp.calculo=pCalculo
    AND cp.producto=c.producto -- pk, verificada calProd
    AND NOT EXISTS ( SELECT 1 
                       FROM CalObs c_1 
                       WHERE c_1.Periodo=vPeriodo_1
                          AND c_1.Calculo=vCalculo_1
                          AND c_1.producto=c.producto  
                          AND c_1.informante=c.informante
                          AND c_1.observacion=c.observacion
                    );


-- Cuando tiene correspondencia en periodo anterior 
execute Cal_Mensajes(pPeriodo, pCalculo,'Update 2','log','Cuando registro de CalObs tiene correspondencia en el periodo anterior, seteo de Antiguedad con/sin precio y sinDatosEstacional');  
UPDATE CalObs AS c
  SET AntiguedadConPrecio= CASE WHEN c.promObs IS NULL THEN NULL
                                ELSE COALESCE(c0.AntiguedadconPrecio,0) + 1
                           END, 
      AntiguedadsinPrecio= CASE WHEN c.promObs IS NOT NULL THEN NULL
                                ELSE COALESCE(c0.AntiguedadsinPrecio,0) + 1
                           END,
      SinDatosEstacional=CASE WHEN c.promObs IS NULL THEN COALESCE(c0.SinDatosEstacional,0) + CASE WHEN p.CantConPrecioParaCalEstac<p.umbralBajaAuto THEN 1 ELSE 0 END
                            ELSE NULL
                           END
  FROM CalObs c0, calDiv p
  WHERE c.periodo=pPeriodo
    AND c.calculo=pCalculo
    AND vPeriodo_1=c0.periodo
    AND vCalculo_1=c0.calculo
    AND c.producto=c0.producto  
    AND c.informante=c0.informante
    AND c.observacion=c0.observacion
    AND p.periodo=c.periodo
    AND p.calculo=c.calculo
    AND p.producto=c.producto
    AND p.division=c.division;
    
--Alta, Baja Automatica
execute Cal_Mensajes(pPeriodo, pCalculo,'Update 3','log','Cuando registro de CalObs tiene correspondencia en el periodo anterior, seteo de Antiguedad Excluido/Incluido');  
UPDATE CalObs c
  SET AntiguedadExcluido= 
        CASE WHEN a.esPeriodoBase='S' THEN 
                    CASE WHEN c.periodo> coalesce(cb.periodo_anterior_baja,c.periodo) THEN COALESCE(c0.AntiguedadExcluido,0)+1
                         ELSE null--c0.antiguedadexcluido
                    END
             ELSE
                CASE WHEN p.CantPerAltaAuto = 1  AND c0.antiguedadIncluido is null AND c.AntiguedadconPrecio>=p.CantPerAltaAuto  THEN NULL
                     WHEN c.AntiguedadSinPrecio - c.SinDatosEstacional>=p.CantPerBajaAuto AND c0.antiguedadIncluido>0 THEN  1
                     WHEN c0.antiguedadExcluido IS NULL THEN NULL
                     WHEN c0.PromObs is not null AND c0.antiguedadExcluido>0 AND c.AntiguedadconPrecio>=p.CantPerAltaAuto  THEN NULL
                     ELSE c0.AntiguedadExcluido + 1                                       
                END
             END,
      AntiguedadIncluido=
        CASE WHEN a.esPeriodoBase='S' THEN
                    CASE WHEN c.periodo> coalesce(cb.periodo_anterior_baja,c.periodo)  THEN NULL
                         ELSE coalesce(c0.antiguedadIncluido,0) + 1
                    END
             ELSE
                CASE WHEN p.CantPerAltaAuto = 1  AND c0.antiguedadIncluido is null AND c.AntiguedadconPrecio>=p.CantPerAltaAuto  THEN 1
                     WHEN c0.PromObs is not null AND c0.antiguedadIncluido is null AND c.AntiguedadconPrecio>=p.CantPerAltaAuto  THEN 1
                     WHEN c0.antiguedadIncluido IS NULL THEN NULL
                     WHEN c.AntiguedadSinPrecio - c.SinDatosEstacional>=p.CantPerBajaAuto AND c0.antiguedadIncluido>0 THEN  NULL
                     ELSE c0.AntiguedadIncluido + 1                                   
                END 
             END   
  FROM CalObs c0, CalProd p,
       calculos a, 
       (SELECT c1.periodo, c1.calculo, c1.producto, c1.observacion, c1.informante, b.periodo_anterior_baja
            FROM calobs c1 LEFT JOIN calbase_obs b ON c1.calculo=b.Calculo AND c1.producto=b.producto
                                 AND c1.informante =b.informante AND c1.observacion=b.observacion --PK verificada
          ) AS cb-- , CalDiv pd
  WHERE c.periodo=pPeriodo
    AND c.calculo=pCalculo
    AND vPeriodo_1=c0.periodo
    AND vCalculo_1=c0.calculo
    AND c.producto=c0.producto  
    AND c.informante=c0.informante
    AND c.observacion=c0.observacion -- c, c0 calObs PK verificada 
    AND p.periodo=c.periodo
    AND p.calculo=c.calculo          -- p calProd PK verificada
    AND p.producto=c.producto
    AND a.periodo=c.periodo
    AND a.calculo=c.calculo          -- a calculos PK verificada
    AND cb.periodo= c.periodo 
    AND cb.calculo=c.Calculo 
    AND cb.producto=c.producto  
    AND cb.informante=c.informante 
    AND cb.observacion=c.observacion -- c, cb calObs PK verificada                                 
    /*
    AND pd.periodo=c.periodo
    AND pd.calculo=c.calculo
    AND pd.producto=c.producto
    AND pd.division=c.division*/;
  
-- CASO REEMPLAZADO => Baja 
execute Cal_Mensajes(pPeriodo, pCalculo,'Update 4','log','Dando de baja a los registros del reemplazado');   
UPDATE CalObs c
  SET AntiguedadIncluido= NULL, AntiguedadExcluido= 1
  FROM  RelVis v 
  WHERE c.periodo=pPeriodo
    AND c.calculo=pCalculo
    AND v.periodo= c.Periodo
    AND v.informante= c.informante 
    AND v.informantereemplazante IS NOT NULL ;  

-- altas y bajas manuales

-- casos erroneos: estan en novobs y no en calobs
execute Cal_Mensajes(pPeriodo, pCalculo,'For Select 5','log','revisando casos erroneos: estan en novobs y no en calobs');   
For vRec in 
  SELECT x.periodo, x.calculo, x.informante, x.producto, x.observacion, x.estado
    FROM NovObs x LEFT JOIN CalObs y
      ON x.periodo=y.periodo
       AND x.calculo=y.calculo
       AND x.producto=y.producto
       AND x.observacion=y.observacion
       AND x.informante=y.informante
    INNER JOIN Gru_Prod gp ON vGrupo = gp.grupo_padre AND x.producto = gp.producto 
    WHERE y.periodo IS NULL
      AND x.periodo=pPeriodo
      AND x.calculo=pCalculo
Loop
 
  execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_AltasYBajas','error',pmensaje:='ERROR, No existe registro en CalObs, sí en NovObs per '||vrec.periodo||', cal '|| vrec.calculo ||', inf '||vrec.informante||', prod ' ||vrec.producto ||', obs ' || vrec.observacion||', estado ' ||vrec.estado, pInformante:=vrec.informante,pProducto:=vrec.producto, pObservacion:=vrec.observacion);      
END LOOP; 
--casos erroneos alta en NovObs y promObs is null VER ****
/*
For vRec in 
  SELECT x.periodo, x.calculo, x.informante, x.producto, x.observacion, x.estado 
    FROM NovObs x JOIN CalObs y
      ON x.periodo=y.periodo
       AND x.calculo=y.calculo
       AND x.producto=y.producto
       AND x.observacion=y.observacion
       AND x.informante=y.informante
    WHERE x.periodo=pPeriodo
      AND x.calculo=pCalculo
      AND X.estado='Alta' and y.promObs IS NULL
Loop
  raise exception 'CalObs_AltasYBajas: ERROR,  NovObs indica Alta y promObs es nulo. per % , cal %, inf % , prod %, obs %, estado %'
                  ,vrec.periodo, vrec.calculo, vrec.informante, vrec.producto, vrec.observacion, vrec.estado;
    
END LOOP;     
--*/
-- Altas y Bajas Manuales, testear condicion prom>0 en el caso de Alta
execute Cal_Mensajes(pPeriodo, pCalculo,'Update 6','log','Altas/Bajas Manuales');   
UPDATE CalObs c
  SET AntiguedadExcluido= CASE WHEN n.estado='Alta' THEN NULL
                               WHEN n.estado='Baja' THEN COALESCE(c0.AntiguedadExcluido,0)+1
                               ELSE c.antiguedadexcluido
                          END,
      AntiguedadIncluido= CASE WHEN n.estado='Alta'  THEN COALESCE(c0.AntiguedadIncluido,0)+1
                               WHEN n.estado='Baja' THEN NULL
                               ELSE c.antiguedadincluido
                          END,
      SinDatosEstacional=CASE WHEN n.estado='Alta' and c.AntiguedadSinPrecio>0 THEN COALESCE(c.AntiguedadSinPrecio,0) ELSE c.SinDatosEstacional END
  FROM Gru_Prod gp, NovObs n left join calObs c0 on c0.periodo=vPeriodo_1
    AND c0.calculo=vCalculo_1
    AND c0.producto=n.producto
    AND c0.informante=n.informante
    AND c0.observacion=n.observacion
  WHERE c.periodo=n.periodo
    AND c.calculo=n.calculo
    AND c.producto=n.producto
    AND c.informante=n.informante
    AND c.observacion=n.observacion
    AND c.periodo=pPeriodo
    AND c.calculo=pCalculo
    AND gp.grupo_padre=vGrupo 
    AND gp.agrupacion=vAgrupacionPrincipal
    AND gp.producto=c.producto;

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_AltasyBajas','finalizo');  
END;
$$;