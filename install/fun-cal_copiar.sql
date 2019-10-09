CREATE or replace FUNCTION cal_copiar(pperiodo text, pcalculo integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE 
  vAgrupPrincipal character varying(10) ;
  vParaVariosHogares boolean;
  vmaxnivel integer;
  pGrupo text; 
  
BEGIN 

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Copiar', pTipo:='comenzo');
--CalProdResp
INSERT INTO CalProdResp 
SELECT pperiodo, pcalculo, p.producto, gpr.responsable, 'N' as revisado
  FROM Productos p CROSS JOIN calculos c 
  --los responsables de cada producto
  LEFT JOIN grupos ghr ON ghr.agrupacion = 'F' and ghr.grupo = p.Producto
  LEFT JOIN grupos gpr ON ghr.agrupacion = gpr.agrupacion and ghr.grupopadre = gpr.grupo
  LEFT JOIN CalProdResp pe ON c.calculo = pe.calculo AND c.periodo = pe.periodo AND p.producto = pe.producto
WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND pe.periodo IS NULL AND p.nombreproducto NOT LIKE '%orrar%';

--CalProd
INSERT INTO CalProd(periodo, calculo, producto, 
                    CantPerAltaAuto, CantPerBajaAuto,
                    esExternoHabitual,ImputaCon)
  (SELECT           pPeriodo, pCalculo, p.producto, 
                    CantPerAltaAuto, CantPerBajaAuto,
                    esExternoHabitual, COALESCE(ImputaCon,g.GrupoPadre)                     
     FROM Productos p INNER JOIN Especificaciones e ON p.producto=e.producto AND e.especificacion=1
        INNER JOIN Calculos c ON pCalculo=c.calculo AND pPeriodo=c.Periodo
        INNER JOIN Calculos_def d ON pCalculo = d.calculo  
        INNER JOIN Grupos g ON g.Agrupacion=d.AgrupacionPrincipal AND g.Grupo=p.Producto
        INNER JOIN Gru_Prod gp ON g.agrupacion = gp.agrupacion AND d.grupo_raiz = gp.grupo_padre AND p.producto = gp.producto
  ); 
--CalProdAgr
EXECUTE cal_copiar_CalProdAgr(pPeriodo, pCalculo, null);
/*  
SELECT AgrupacionPrincipal INTO vAgrupPrincipal
  FROM calculos c inner join agrupaciones a on c.agrupacionprincipal=a.agrupacion
  WHERE periodo=pPeriodo AND calculo=pCalculo;  
*/
SELECT AgrupacionPrincipal, grupo_raiz INTO vAgrupPrincipal, pGrupo
  FROM calculos_def
  WHERE calculo=pCalculo;  

-- Para los comunes pone sus divisiones declaradas en ProdDiv  
INSERT INTO CalDiv(periodo , calculo , producto, Division, 
                   PonderadorDiv, UmbralPriImp, UmbralDescarte, UmbralBajaAuto,
                   profundidad, DivisionPadre, 
                   tipo_Promedio, raiz)
  (SELECT          pPeriodo, pCalculo, p.producto, CASE WHEN d.sindividir THEN '0' ELSE p.division END as Division, 
                   CASE WHEN d.sindividir THEN null ELSE p.PonderadorDiv END, 
                   CASE WHEN c.estimacion = 0 THEN p.UmbralPriImp ELSE e.UmbralPriImp END, 
                   CASE WHEN c.estimacion = 0 THEN p.UmbralDescarte ELSE e.UmbralDescarte END, 
                   CASE WHEN c.estimacion = 0 THEN p.UmbralBajaAuto ELSE e.UmbralBajaAuto END,
                   CASE WHEN d.sindividir THEN 0 ELSE 1 END, CASE WHEN d.sindividir THEN null ELSE '0' END AS DivisionPadre, 
                   null AS tipo_Promedio, d.sindividir
     FROM ProdDiv p
     JOIN Calculos c ON c.periodo = pPeriodo AND c.calculo = pCalculo --pk verificada
     JOIN Gru_Prod g ON p.producto = g.producto AND g.agrupacion = vAgrupPrincipal AND g.grupo_padre = pGrupo
     JOIN Divisiones d ON d.division=p.division
     LEFT JOIN ProdAtr pa ON pa.producto=p.producto AND pa.orden_calculo_especial is not null
     LEFT JOIN ProdDivEstimac e ON p.producto = e.producto and p.division = e.division and c.estimacion = e.estimacion --pk verificada
     WHERE pa.producto IS NULL
  ); 

  -- Para los comunes divididos pone la división 0 
INSERT INTO CalDiv(periodo , calculo , producto, Division, 
                   PonderadorDiv, UmbralPriImp, UmbralDescarte, UmbralBajaAuto,
                   profundidad, DivisionPadre, 
                   tipo_Promedio, raiz)
  (SELECT          pPeriodo, pCalculo, p.producto, '0', 
                   sum(PonderadorDiv), null, null, null,
                   0 , null AS DivisionPadre, 
                   'GeoPond', true
     FROM ProdDiv p
     JOIN Gru_Prod g ON p.producto = g.producto AND g.agrupacion = vAgrupPrincipal AND g.grupo_padre = pGrupo
     JOIN Divisiones d ON d.division=p.division
     LEFT JOIN ProdAtr pa ON pa.producto=p.producto AND pa.orden_calculo_especial is not null
     WHERE pa.producto IS NULL 
       AND d.sindividir IS NOT TRUE
     GROUP BY p.producto
  ); 

--CalGru
INSERT INTO CalGru(periodo, calculo, agrupacion, grupo, grupopadre, nivel, esproducto, ponderador)
  (SELECT         pPeriodo, pCalculo, g.agrupacion, g.grupo, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
     FROM Grupos g
     JOIN Gru_Grupos gg ON g.grupo = gg.grupo AND g.agrupacion = gg.agrupacion AND g.agrupacion = vAgrupPrincipal AND gg.grupo_padre = pGrupo
--     WHERE agrupacion=vAgrupPrincipal
  );

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Copiar', pTipo:='finalizo');

 END;
$$;
