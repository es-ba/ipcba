-- UTF8:Sí
CREATE OR REPLACE FUNCTION cvp.copiarcalculo(
    p_periodo_origen text,
    p_calculo_origen integer,
    p_periodo_destino text,
    p_calculo_destino integer,
    p_motivocopia text)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$

DECLARE
  -- V081116
  v_abierto_origen text;
BEGIN
  IF p_calculo_destino=0 THEN
    RAISE EXCEPTION 'El cálculo de destino no puede ser 0 para % % -> % %',p_periodo_origen , p_calculo_origen ,p_periodo_destino , p_calculo_destino;
  END IF;
  SELECT abierto INTO v_abierto_origen
    FROM calculos
    WHERE periodo=p_periodo_origen
      AND calculo=p_calculo_origen;
  -- Si el destino existe tiene que fallar 
  -- Inserto
  INSERT INTO calculos(periodo, calculo, 
                esperiodobase, fechacalculo, periodoanterior, calculoanterior, denominadordefinitivosegimp, descartedefinitivosegimp,
                abierto, modi_usu, modi_fec, modi_ope, agrupacionprincipal, 
                valido, pb_calculobase, motivocopia, fechageneracionexternos, estimacion, transmitir_canastas, fechatransmitircanastas)
        SELECT p_periodo_destino, p_calculo_destino, 
                esperiodobase,  fechacalculo, periodoanterior, calculoanterior, denominadordefinitivosegimp, descartedefinitivosegimp,
                abierto, modi_usu, modi_fec, modi_ope, agrupacionprincipal, 
                valido, pb_calculobase, p_motivocopia, fechageneracionexternos, estimacion, transmitir_canastas, fechatransmitircanastas
          FROM calculos
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calgru(periodo, calculo, 
                agrupacion, grupo, variacion, impgru, valorprel, 
                valorgru, grupopadre, nivel, esproducto, ponderador, indice, 
                indiceprel, incidencia, indiceredondeado, incidenciaredondeada, ponderadorimplicito)        
        SELECT p_periodo_destino, p_calculo_destino, 
               agrupacion, grupo, variacion, impgru, valorprel, 
                valorgru, grupopadre, nivel, esproducto, ponderador, indice, 
                indiceprel, incidencia, indiceredondeado, incidenciaredondeada, ponderadorimplicito
          FROM calgru
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calprod(periodo, calculo, 
               producto, promprod, impprod, valorprod, cantincluidos, 
               promprel, valorprel, cantaltas, promaltas, cantbajas, prombajas, 
               cantperaltaauto, cantperbajaauto, esexternohabitual, imputacon, 
               cantporunidcons, unidadmedidaporunidcons, pesovolumenporunidad, 
               cantidad, unidaddemedida, indice, indiceprel)
        SELECT p_periodo_destino, p_calculo_destino, 
               producto, promprod, impprod, valorprod, cantincluidos, 
           promprel, valorprel, cantaltas, promaltas, cantbajas, prombajas, 
           cantperaltaauto, cantperbajaauto, esexternohabitual, imputacon, 
           cantporunidcons, unidadmedidaporunidcons, pesovolumenporunidad, 
           cantidad, unidaddemedida, indice, indiceprel
          FROM calprod
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calProdResp(periodo, calculo, producto, responsable, revisado)
        SELECT p_periodo_destino, p_calculo_destino, producto, responsable, revisado
          FROM calProdResp
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  --para limpiar las revisiones: 
  DELETE FROM calProdResp WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  --
  INSERT INTO calprodAgr(periodo, calculo, agrupacion, 
               producto, cantporunidcons, valorprod, unidadmedidaporunidcons,
               cantidad, unidaddemedida, pesovolumenporunidad, coefajuste)
        SELECT p_periodo_destino, p_calculo_destino, agrupacion, 
               producto, cantporunidcons, valorprod, unidadmedidaporunidcons,
               cantidad, unidaddemedida, pesovolumenporunidad, coefajuste
          FROM calprodAgr
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO caldiv(periodo, calculo,
                   producto, division, prompriimpact, prompriimpant, 
                   cantpriimp, promprel, promdiv, impdiv, cantincluidos, cantrealesincluidos, 
                   cantrealesexcluidos, promvar, cantaltas, promaltas, cantbajas, 
                   prombajas, cantimputados, ponderadordiv, umbralpriimp, umbraldescarte, 
                   umbralbajaauto, cantidadconprecio, profundidad, divisionpadre, 
                   tipo_promedio, raiz, cantexcluidos, promexcluidos, promimputados,
                   promrealesincluidos, promrealesexcluidos, promedioRedondeado, cantrealesdescartados,
                   cantpreciostotales, cantpreciosingresados, CantConPrecioParaCalEstac, promsinimpext, PromRealesSinCambio, PromRealesSinCambioAnt,
                   PromSinAltasBajas, PromSinAltasBajasAnt, promImputadosInactivos, cantImputadosInactivos)
        SELECT p_periodo_destino, p_calculo_destino, 
                producto, division, prompriimpact, prompriimpant, 
               cantpriimp, promprel, promdiv, impdiv, cantincluidos, cantrealesincluidos, 
               cantrealesexcluidos, promvar, cantaltas, promaltas, cantbajas, 
               prombajas, cantimputados, ponderadordiv, umbralpriimp, umbraldescarte, 
               umbralbajaauto, cantidadconprecio, profundidad, divisionpadre, 
               tipo_promedio, raiz, cantexcluidos, promexcluidos, promimputados,
               promrealesincluidos, promrealesexcluidos, promedioRedondeado, cantrealesdescartados,
               cantpreciostotales, cantpreciosingresados, CantConPrecioParaCalEstac, promsinimpext, PromRealesSinCambio, PromRealesSinCambioAnt,
               PromSinAltasBajas,PromSinAltasBajasAnt,promImputadosInactivos,cantImputadosInactivos
          FROM caldiv
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calobs(periodo, calculo,
                producto, informante, observacion, division, 
                promobs, impobs, antiguedadconprecio, antiguedadsinprecio, antiguedadexcluido, 
                antiguedadincluido, sindatosestacional, muestra)
        SELECT p_periodo_destino, p_calculo_destino, 
               producto, informante, observacion, division, 
                promobs, impobs, antiguedadconprecio, antiguedadsinprecio, antiguedadexcluido, 
                antiguedadincluido, sindatosestacional, muestra
          FROM calobs
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calHogGru(periodo, calculo,
                        hogar, agrupacion, grupo, valorhoggru, coefhoggru)
        SELECT p_periodo_destino, p_calculo_destino, 
           hogar, agrupacion, grupo, valorhoggru, coefhoggru
          FROM calHogGru
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;
  INSERT INTO calHogSubtotales(periodo, calculo,
                               hogar, agrupacion, grupo, valorhogsub)
        SELECT p_periodo_destino, p_calculo_destino,
            hogar, agrupacion, grupo, valorhogsub
          FROM calHogSubtotales
          WHERE periodo=p_periodo_origen AND calculo=p_calculo_origen;

  RETURN 'Copia lista';
END;
$BODY$;
