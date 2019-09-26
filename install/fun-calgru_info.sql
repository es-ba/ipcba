-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalGru_Info_Otro(pPeriodo TEXT, pCalculo INTEGER, pAgrupacion TEXT) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$  
DECLARE     
  vAgrupacion text; 
  
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Info_Otro', pTipo:='comenzo');

  IF pAgrupacion IS NULL THEN  --agrupacion principal
    SELECT AgrupacionPrincipal INTO vAgrupacion
        FROM Calculos_def
        WHERE calculo=pCalculo;
  ELSE
    vAgrupacion:=pAgrupacion;
  END IF; 
  
  UPDATE CalGru c
    SET /*
        variacion = CASE WHEN c0.Indice=0 THEN null ELSE round((c.Indice/c0.Indice*100-100)::decimal,1) END
        ,incidencia = (c.indice - c0.indice) * c.ponderador / p0.indice * 100::double precision
        */
    --variacion: basada en indiceRedondeado, almacenada a 1 decimal
    variacion = CASE WHEN c0.Indice=0 THEN null ELSE round((round(c.Indice::decimal,2)/round(c0.Indice::decimal,2)*100-100)::decimal,1) END
    --incidencia: basada en indice, almacenada con todos los decimales
    ,incidencia = (c.indice - c0.indice) * c.ponderador / p0.indice * 100::double precision
    --incidenciaRedondeada: basada en indiceRedondeado, almacenada a 2 decimales
    ,incidenciaRedondeada =
       CASE 
         WHEN c.nivel = 0 THEN
           CASE WHEN c0.Indice=0 THEN null ELSE round((round(c.Indice::decimal,2)/round(c0.Indice::decimal,2)*100-100)::decimal,1) END
         WHEN c.nivel = 1 THEN
           round(((round(c.indice::decimal,2) - round(c0.indice::decimal,2)) * c.ponderador / round(p0.indice::decimal,2) * 100)::decimal,2)
         ELSE NULL
         END
    --indiceRedondeado: indice almacenado a 2 decimales
    ,indiceRedondeado = round(c.indice::decimal,2)
    FROM CalGru c0,
         Calculos p,
         Gru_Grupos gp,
         CalGru p0   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=vAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo --pk verificada
      AND p0.periodo=p.periodoanterior AND p0.calculo=p.calculoAnterior AND p0.agrupacion=c.agrupacion AND p0.nivel = 0
      AND gp.agrupacion=c.agrupacion AND gp.grupo_padre=vAgrupacion AND c.grupo=gp.grupo;
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_Info_Otro', pTipo:='finalizo');

END;  
$$;  
CREATE OR REPLACE FUNCTION CalGru_Info(pPeriodo TEXT, pCalculo INTEGER) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$  
DECLARE     
  vEmpezo     time;  
  vTermino    time;  
BEGIN   
  execute CalGru_Info_Otro(pPeriodo, pCalculo,null);
END;  
$$;