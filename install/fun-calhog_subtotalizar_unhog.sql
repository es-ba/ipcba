-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalHog_Subtotalizar_UnHog(pPeriodo Text, pCalculo Integer, pAgrupacion text, pHogar text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
 vhsub record;
BEGIN  
 EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalHog_Subtotalizar_UnHog', pTipo:='comenzo');

 INSERT INTO CalHogSubtotales (periodo, calculo, hogar, agrupacion, grupo)
  (SELECT g.periodo, g.calculo, g.hogar, g.agrupacion, g.grupo
     FROM Grupos c 
       JOIN CalHogGru g ON c.agrupacion = g.agrupacion
                           AND c.grupo = g.grupo         -- FK verificada
                           AND g.periodo = pperiodo 
                           AND g.calculo = pcalculo
                           AND c.nivel = 1
                           AND c.agrupacion= pAgrupacion
                           AND g.hogar=pHogar); 
 
 FOR vhsub IN
     SELECT s.periodo, s.calculo, s.hogar, s.agrupacion, s.grupo
       FROM CalHogSubtotales s 
       WHERE s.periodo = pperiodo 
         AND s.calculo = pcalculo
         AND s.agrupacion = pAgrupacion
         AND s.hogar=pHogar
 LOOP
   UPDATE CalHogSubtotales 
      SET ValorHogSub =
         (SELECT SUM(ValorHogGru)
            FROM CalHogGru c 
               JOIN CalGru g
                 ON c.periodo = g.periodo AND c.calculo = g.calculo AND c.agrupacion = g.agrupacion AND c.grupo = g.grupo --PK verificada
            WHERE c.periodo = vhsub.periodo
              AND c.calculo = vhsub.calculo
              AND c.hogar = vhsub.hogar
              AND c.agrupacion = vhsub.agrupacion
              AND g.grupo <= vhsub.grupo
              AND g.nivel = 1)
     WHERE periodo = vhsub.periodo
        AND calculo = vhsub.calculo
        AND hogar = vhsub.hogar
        AND agrupacion = vhsub.agrupacion
        AND grupo = vhsub.grupo;
 END LOOP;
   
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalHog_Subtotalizar_UnHog', pTipo:='finalizo');

END;
$$;