CREATE or replace FUNCTION cal_copiar_CalProdAgr(pperiodo text, pcalculo integer, pAgrupacion text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vr_prod RECORD; 
  vr_prodAtr RECORD;
  vvalor DOUBLE PRECISION;
  vunidad CHARACTER VARYING(41); 
BEGIN
  INSERT INTO CalProdAgr(periodo, calculo, producto, agrupacion, CantPorUnidCons,
                       Cantidad, UnidadDeMedida, PesoVolumenPorUnidad, UnidadMedidaPorUnidCons)
  (SELECT           pPeriodo, pCalculo, pa.producto, pa.agrupacion, pa.CantPorUnidCons,
                    e.Cantidad, e.UnidadDeMedida, PesoVolumenPorUnidad, UnidadMedidaPorUnidCons                     
     FROM Productos p INNER JOIN Especificaciones e ON p.producto=e.producto AND e.especificacion=1                    
        INNER JOIN ProdAgr pa on p.producto = pa.producto
        INNER JOIN agrupaciones a ON pa.agrupacion = a.agrupacion 
        INNER JOIN Calculos c ON pCalculo=c.calculo AND pPeriodo=c.Periodo
        INNER JOIN Calculos_def d ON pCalculo = d.calculo  
        INNER JOIN Grupos g ON g.Agrupacion=d.AgrupacionPrincipal AND g.Grupo=pa.Producto 
        INNER JOIN Gru_Prod gp ON g.agrupacion = gp.agrupacion AND d.grupo_raiz = gp.grupo_padre AND pa.producto = gp.producto
     WHERE a.valoriza
       AND (pAgrupacion is null or pAgrupacion=pa.agrupacion)
  ); 
  FOR vr_prod IN
    SELECT g.agrupacion, p.producto, count(pa.producto) AS cantnormalizables,
           min(a.unidaddemedida) AS minUnidad,max(a.unidaddemedida) as MaxUnidad, sum(pa.valorNormal) as sumValorNormal
      FROM Productos p 
         JOIN ProdAtr pa ON  pa.producto=p.producto and pa.normalizable='S' and pa.tiponormalizacion in ('Normal')
         JOIN atributos a ON a.atributo=pa.atributo
         INNER JOIN Calculos c ON pCalculo=c.calculo AND pPeriodo=c.Periodo
         INNER JOIN Calculos_def d ON pCalculo = d.calculo  
         INNER JOIN Grupos g ON g.Grupo=p.Producto
         INNER JOIN Gru_Prod gp ON g.agrupacion = gp.agrupacion AND coalesce(pAgrupacion, d.agrupacionprincipal)= gp.grupo_padre AND p.producto = gp.producto 
      WHERE (pAgrupacion is null or pAgrupacion=g.agrupacion)
      GROUP BY g.agrupacion, p.producto
  LOOP 
    IF vr_prod.cantNormalizables=1 THEN 
        UPDATE calprodAgr
           set Cantidad= vr_prod.sumValorNormal, UnidaddeMedida= vr_prod.minUnidad
           WHERE periodo=pPeriodo AND calculo= pCalculo AND producto= vr_prod.producto AND (pAgrupacion is null or pAgrupacion=agrupacion);     
    ELSE
        vvalor=1;
        vUnidad:=NULL;
        FOR vr_prodatr IN 
          SELECT pa.valorNormal, a.UnidadDeMedida
            FROM ProdAtr pa INNER JOIN Atributos a ON pa.atributo=a.atributo
            WHERE pa.producto= vr_prod.producto and pa.normalizable='S' and pa.tiponormalizacion in ('Normal')
        ORDER BY a.UnidadDeMedida, pa.prioridad, pa.atributo
        LOOP  
          vvalor:=vvalor * vr_prodatr.valorNormal;
          IF vr_prodatr.UnidadDeMedida<>'u' THEN
            IF vUnidad IS NULL THEN
                vUnidad:='';
            ELSE
                vUnidad:=vUnidad||'.';
            END IF;
            vUnidad:=vUnidad||vr_prodatr.UnidadDeMedida;
          END IF;
        END LOOP;
        IF vUnidad IS NULL THEN
        vUnidad:='u';
        END IF;
        UPDATE calprodAgr
           set Cantidad= vvalor, UnidaddeMedida= vunidad
           WHERE periodo=pPeriodo AND calculo= pCalculo AND producto= vr_prod.producto AND (pAgrupacion is null or pAgrupacion=agrupacion);
    END IF;           
  END LOOP;
END;
$$;
