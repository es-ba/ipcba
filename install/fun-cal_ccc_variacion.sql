
CREATE OR REPLACE FUNCTION Cal_CCC_Variacion(pPeriodo TEXT, pCalculo INTEGER, pAgrupacion TEXT) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$      
 
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='comenzo');
 
  UPDATE CalGruPer c
    SET variacion=CASE WHEN c0.valorgru=0 THEN null ELSE round((c.valorgru/c0.valorgru*100-100)::decimal,1) END
    FROM CalGruPer c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.perfil = c.perfil; --Pk verificada
  
  UPDATE calhogpargru c
    SET variacion=CASE WHEN c0.valorhoggru=0 THEN null ELSE round((c.valorhoggru/c0.valorhoggru*100-100)::decimal,1) END
    FROM calhogpargru c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.hogar = c.hogar; --Pk verificada

  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='finalizo');
END;  
$$;
