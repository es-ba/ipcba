-- UTF8:Sí

CREATE OR REPLACE FUNCTION CalObs_Extraer(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vEmpezo  time:=clock_timestamp();
  vTermino time; 
  v_basado_en_extraccion_calculo integer;
  v_basado_en_extraccion_muestra integer;
BEGIN
  perform VoyPor('CalObs_Extraer');  
  SELECT basado_en_extraccion_calculo,
         basado_en_extraccion_muestra
    INTO v_basado_en_extraccion_calculo,
         v_basado_en_extraccion_muestra
    FROM Calculos_def
    WHERE calculo=pCalculo;
  INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, PromObs, 
                     ImpObs, AntiguedadConPrecio, AntiguedadSinPrecio, AntiguedadIncluido, muestra)
    (SELECT          pPeriodo, pCalculo, a.producto, a.informante, a.observacion, a.division, a.PromObs,
                     a.ImpObs,a.AntiguedadConPrecio, a.AntiguedadSinPrecio, a.AntiguedadIncluido, a.muestra
       FROM CalObs a
       WHERE a.periodo=pPeriodo AND a.calculo=v_basado_en_extraccion_calculo
          AND a.muestra=v_basado_en_extraccion_muestra
     );
  
  vTermino:=clock_timestamp();
  raise notice '%','Empezo '||cast(vEmpezo as text)||' termino '||cast(vTermino as text)||' demoro '||(vTermino - vEmpezo);
END;
$$;