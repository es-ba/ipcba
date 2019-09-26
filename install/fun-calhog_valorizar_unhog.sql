-- UTF8:Sí 
CREATE OR REPLACE FUNCTION CalHog_Valorizar_UnHog(pPeriodo Text, pCalculo Integer, pAgrupacion text, pHogar text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
 vmaxnivel integer;
 vhgru record;
 vhg RECORD;
BEGIN  
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalHog_Valorizar_UnHog', pTipo:='comenzo'); 
--insercion en CalHogGru

INSERT INTO CalHogGru (periodo, calculo,hogar, agrupacion, grupo, CoefHogGru)
  (SELECT pPeriodo as Periodo, pcalculo as Calculo, Hogar, g.Agrupacion, g.Grupo
         , CASE WHEN MIN(COALESCE(ABS(CoefHogPar)))>0 THEN EXP(SUM(LN(NULLIF(CoefHogPar,0)))) ELSE 0 END AS CoefHogGru
     FROM hogpar h JOIN parhoggru g ON h.parametro = g.parametro  AND g.agrupacion=pAgrupacion
          INNER JOIN agrupaciones a ON g.agrupacion=a.agrupacion --PK verificada
     WHERE a.paraVariosHogares AND h.hogar=pHogar
     GROUP BY Hogar, g.Agrupacion, g.Grupo
     ORDER BY Hogar, g.Agrupacion, g.Grupo);
-- inserto los coeficientes que están marcados con AgrupacionOrigen en Grupos.
INSERT INTO CalHogGru (periodo, calculo,hogar, agrupacion, grupo, CoefHogGru)
    (SELECT cg.Periodo, cg.Calculo, cg.Hogar, g.Agrupacion, cg.Grupo, cg.CoefHogGru
       FROM CalHogGru cg 
            INNER JOIN grupos g ON g.grupo=cg.grupo AND cg.agrupacion=g.AgrupacionOrigen --PK verificada
            INNER JOIN agrupaciones a ON g.agrupacion=a.agrupacion --PK verificada
       WHERE a.paraVariosHogares
         AND cg.Periodo=pPeriodo AND cg.Calculo=pCalculo  AND g.Agrupacion=pAgrupacion AND cg.hogar=pHogar
       ORDER BY cg.Hogar, g.Agrupacion, cg.Grupo);
-- sube por niveles
SELECT MAX(g.nivel) INTO vmaxnivel 
  FROM CalHogGru c, Grupos g
  WHERE c.periodo = pperiodo AND c.calculo = pcalculo AND c.agrupacion = g.agrupacion AND c.grupo = g.grupo AND c.agrupacion=pAgrupacion AND c.hogar=pHogar;
FOR i IN REVERSE vmaxnivel..1 LOOP
  INSERT INTO CalHogGru (periodo, calculo, hogar, agrupacion, grupo)
    (SELECT DISTINCT periodo, calculo, hogar, agrupacion, grupopadre
       FROM (SELECT c.*, g.grupopadre, g.nivel
               FROM CalHogGru c, Grupos g
               WHERE c.periodo = pperiodo AND c.calculo = pcalculo AND c.agrupacion = g.agrupacion AND c.grupo = g.grupo AND g.nivel = i AND c.agrupacion=pAgrupacion
                 AND c.hogar=pHogar
            ) AS x);
END LOOP;
  
 FOR vhgru IN --toma los grupos-Hoja de CalHogGru
   SELECT h.periodo, h.calculo, h.Hogar, h.agrupacion, h.grupo, c.valorgru, h.coefhoggru, g.agrupacionOrigen 
     FROM CalHogGru h 
          INNER JOIN Grupos g ON g.grupo = h.grupo AND g.agrupacion=h.agrupacion  --PK verificada
          INNER JOIN CalGru c ON c.grupo=g.grupo AND c.agrupacion = COALESCE(g.agrupacionOrigen,g.agrupacion) 
                              AND c.periodo = h.periodo AND c.calculo = h.calculo --PK verificada
     WHERE h.coefhoggru IS NOT NULL
       AND h.periodo = pperiodo 
       AND h.calculo = pcalculo
       AND h.agrupacion=pAgrupacion
       AND h.hogar=pHogar
 LOOP
   UPDATE CalHogGru x SET valorHogGru = 
        CASE WHEN vhgru.agrupacionOrigen IS NULL THEN vhgru.valorGru * vhgru.coefHogGru 
            ELSE (SELECT valorHogGru 
                    FROM CalHogGru z 
                    WHERE z.periodo=x.periodo AND z.calculo=x.calculo 
                      AND z.agrupacion=vhgru.AgrupacionOrigen AND z.grupo=x.grupo AND z.hogar=x.hogar AND z.hogar=pHogar )
        END
     WHERE periodo = vhgru.periodo 
       AND calculo = vhgru.calculo 
       AND hogar = vhgru.Hogar 
       AND agrupacion = vhgru.agrupacion 
       AND grupo = vhgru.grupo;
 END LOOP;
 SELECT MAX(nivel) INTO vmaxnivel --para los niveles superiores
   FROM Grupos g 
        INNER JOIN CalHogGru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo  --FK verificada
   WHERE h.valorhoggru IS NOT NULL
       AND h.periodo = pperiodo 
       AND h.calculo = pcalculo
       AND h.agrupacion=pAgrupacion
       AND h.hogar=pHogar;
 IF vmaxnivel is not null THEN
     FOR i IN REVERSE vmaxnivel-1..0 LOOP
       FOR vhg IN 
         SELECT h.periodo, h.calculo, h.Hogar, h.agrupacion, h.grupo
           FROM Grupos g 
                INNER JOIN CalHogGru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo --FK verificada
           WHERE g.nivel = i
             AND h.periodo = pperiodo 
             AND h.calculo = pcalculo
             AND h.ValorHogGru IS NULL
             AND h.agrupacion=pAgrupacion
             AND h.hogar=pHogar
       LOOP 
         UPDATE CalHogGru c SET valorhoggru = 
           (SELECT SUM(valorhoggru)
              FROM Grupos g
                  INNER JOIN CalHogGru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo --FK verificada
              WHERE c.grupo = g.grupopadre
                AND c.periodo = h.periodo 
                AND c.calculo = h.calculo
                AND c.hogar = h.hogar
                AND c.agrupacion = h.agrupacion
                AND h.hogar=pHogar)
           WHERE periodo = vhg.periodo
             AND calculo = vhg.calculo
             AND hogar = vhg.hogar
             AND agrupacion = vhg.agrupacion
             AND grupo = vhg.grupo;       
       END LOOP;
     END LOOP;
 END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalHog_Valorizar_UnHog', pTipo:='finalizo');  
END;
$$;