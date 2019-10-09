CREATE OR REPLACE FUNCTION Cal_Mensaje(pMensaje Text, pTipo text) RETURNS Text IMMUTABLE STRICT LANGUAGE sql AS
$$ SELECT $1; $$;

CREATE OR REPLACE FUNCTION Cal_Mensajes(pPeriodo Text, pCalculo Integer, pPaso Text, pTipo Text, pMensaje Text DEFAULT null, pProducto Text DEFAULT null,
                                        pDivision Text DEFAULT null, pInformante Integer DEFAULT null, pObservacion Integer DEFAULT null, pFormulario Integer DEFAULT null, 
                                        pGrupo Text DEFAULT null, pAgrupacion Text DEFAULT null) RETURNS TEXT
  LANGUAGE plpgsql SECURITY DEFINER
  AS $$
DECLARE 
  vpaso Text;
  vfechahora timestamp without time zone;
  vtermino  timestamp without time zone:=clock_timestamp();
  vtipo Text;
  vMensaje text:=Cal_Mensaje(pMensaje,pTipo);
BEGIN 
  IF ptipo='finalizo' THEN
    SELECT tipo, fechahora INTO vtipo, vfechahora
      FROM cal_mensajes
      WHERE periodo=pPeriodo AND calculo=pCalculo AND paso=pPaso AND corrida=current_timestamp AND tipo='comenzo'
      ORDER BY fechaHora desc;  
    vMensaje:=pPaso||': '||vtipo||' '||cast(vfechahora as text)||' '||ptipo||' '||cast(vtermino as text)||' demoro '||(vtermino - vfechahora);
  END IF;  
  INSERT INTO Cal_Mensajes(periodo, calculo, paso, tipo, mensaje, producto,
                           division, informante, observacion, formulario, Grupo, Agrupacion, fechahora)
    VALUES                (pPeriodo, pCalculo, pPaso, pTipo, vMensaje, pProducto,
                           pDivision, pInformante, pObservacion, pFormulario, pGrupo, pAgrupacion, vtermino); 
  IF ptipo in ('log','finalizo') THEN
    Raise notice '%',vMensaje;
  END IF;  
  RETURN '';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'ERROR EN Cal_mensajes con pPeriodo %, pCalculo %, pPaso %, pTipo %, pMensaje %, pProducto %, pDivision %, pInformante %, pObservacion %, pFormulario %, pGrupo %, pAgrupacion %,',pPeriodo, pCalculo, pPaso, pTipo, pMensaje, pProducto, pDivision, pInformante, pObservacion, pFormulario, pGrupo, pAgrupacion;
    RAISE;
END;
$$;
