-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalDiv_Contar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN  
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Contar','comenzo');  
UPDATE CalDiv p SET CantidadConPrecio=
      (SELECT count(*)                  
         FROM CalObs c  
         WHERE c.periodo=p.Periodo AND c.calculo=p.Calculo AND c.producto=p.producto AND c.division=p.division
           AND c.promobs is not null
       )
   WHERE p.periodo=pPeriodo AND p.calculo=pCalculo;   

UPDATE CalDiv p SET CantConPrecioParaCalEstac=
      (SELECT count(*)
         FROM CalObs c
           INNER JOIN calculos cal on c.periodo = cal.periodo and c.calculo = cal.calculo 
           INNER JOIN CalObs c0 on c0.periodo = cal.periodoanterior and c0.calculo = cal.calculoanterior and c.informante = c0.informante and c.producto =c0.producto 
             and c.observacion = c0.observacion
           INNER JOIN CalProd cpr on c.producto = cpr.producto and cpr.calculo=c.calculo and cpr.periodo = c.periodo         
         WHERE c.periodo=p.Periodo AND c.calculo=p.Calculo AND c.producto=p.producto AND c.division=p.division
           AND c.impobs in ('R', 'RA')
           AND (c0.antiguedadIncluido>0 OR c0.antiguedadConPrecio+1>=cpr.CantPerAltaAuto)
       )
   WHERE p.periodo=pPeriodo AND p.calculo=pCalculo;   

UPDATE CalDiv p SET CantPreciosTotales=
      (SELECT count(*)                  
         FROM CalObs c  
         WHERE c.periodo=p.Periodo AND c.calculo=p.Calculo AND c.producto=p.producto AND c.division=p.division
       )
   WHERE p.periodo=pPeriodo AND p.calculo=pCalculo;   
   
UPDATE CalDiv p SET CantPreciosIngresados=
      (SELECT count(*)                  
         FROM CalObs c  
         WHERE c.periodo=p.Periodo AND c.calculo=p.Calculo AND c.producto=p.producto AND c.division=p.division
           AND c.impobs <> 'B'
       )
   WHERE p.periodo=pPeriodo AND p.calculo=pCalculo;   

UPDATE CalDiv p SET CantPreciosTotales = 1, CantPreciosIngresados= 1
   WHERE p.periodo=pPeriodo AND p.calculo=pCalculo AND p.producto IN (SELECT producto FROM productos WHERE tipoexterno = 'D');   
   
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Contar','finalizo');  
END;
$$;