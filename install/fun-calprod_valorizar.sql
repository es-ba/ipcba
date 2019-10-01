-- UTF8:Sí 
CREATE or replace FUNCTION calprod_valorizar(pperiodo text, pcalculo integer, pAgrupacionEspecial text default null) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
  vcalprod RECORD;
 
BEGIN  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Valorizar', pTipo:='comenzo');

FOR vcalprod IN
  SELECT d.periodo, d.calculo, d.producto, a.agrupacion, a.cantporunidcons, u1.factor as factorucons, a.cantidad, u2.factor as factor
        , d.promdiv, d.PromedioRedondeado, a.pesovolumenporunidad 
    FROM CalDiv d
        JOIN CalProdAgr a ON d.periodo=a.periodo AND d.calculo=a.calculo AND d.producto=a.producto        
        JOIN Unidades u1 ON a.unidadmedidaporunidcons = u1.unidad 
        JOIN Unidades u2 ON a.unidaddemedida = u2.unidad  --PK verificada 
    WHERE d.periodo=pPeriodo AND d.calculo=pCalculo AND d.division='0'
      AND (a.agrupacion = pAgrupacionEspecial or pAgrupacionEspecial is null)
LOOP  
 UPDATE CalProdAgr SET  ValorProd 
   =(vcalprod.PromedioRedondeado*vcalprod.cantporunidcons*vcalprod.factorucons)/(vcalprod.cantidad*vcalprod.factor*COALESCE(vcalprod.pesovolumenporunidad,1))
   WHERE periodo = vcalprod.periodo AND calculo = vcalprod.calculo AND producto = vcalprod.producto AND agrupacion = vcalprod.agrupacion;  
END LOOP;
 
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Valorizar', pTipo:='finalizo');
END;
$$;