-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_PromFinal(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vcaltpinf record; 
  vProductosConPromObsCero text;
  vCantidadProductosConPromObsCero integer;
BEGIN  
 EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_PromFinal', pTipo:='comenzo');

SELECT string_agg(distinct producto, ',' order by producto), count(*)
    INTO vProductosConPromObsCero,vCantidadProductosConPromObsCero
    FROM CalObs 
    WHERE periodo=pPeriodo AND calculo=pCalculo 
      AND PromObs=0;
IF vCantidadProductosConPromObsCero>0 THEN
    --RAISE NOTICE 'Hay % observaciones con precio=0 para los productos %',vCantidadProductosConPromObsCero,vProductosConPromObsCero;
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_PromFinal', pTipo:='log',
    pMensaje :='Hay ' || vCantidadProductosConPromObsCero || ' observaciones con precio=0 para los productos ' || vProductosConPromObsCero);
    
END IF;
FOR vcaltpinf IN
  SELECT c.periodo, c.calculo, c.producto, c.division
         , EXP(AVG(LN(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs<>0 THEN c.PromObs ELSE NULL END))) as promobscal
         , MIN(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs IS NOT NULL THEN c.ImpObs ELSE NULL END) as impobscal
         , SUM(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs IS NOT NULL THEN 1 ELSE NULL END) as CantIncluidos
         , SUM(CASE WHEN c.AntiguedadIncluido=1 AND (co.antiguedadexcluido >0 OR co.periodo is null) THEN 1 ELSE NULL END) as CantAltas
         , SUM(CASE WHEN c.AntiguedadExcluido=1 AND co.antiguedadincluido >0 THEN 1 ELSE NULL END) as CantBajas
         , SUM(CASE WHEN c.AntiguedadExcluido>0 THEN 1 ELSE NULL END) as CantExcluidos
         , EXP(AVG(LN(CASE WHEN c.AntiguedadIncluido=1 AND (co.antiguedadexcluido >0 OR co.periodo is null) AND c.PromObs<>0 THEN c.PromObs ELSE NULL END))) as PromAltas
         , EXP(AVG(LN(CASE WHEN c.AntiguedadExcluido=1 AND co.antiguedadincluido >0 AND c.PromObs<>0 THEN c.PromObs ELSE NULL END))) as PromBajas
         , EXP(AVG(LN(CASE WHEN c.AntiguedadExcluido>0 AND c.PromObs<>0 THEN c.PromObs ELSE NULL END))) as PromExcluidos
         , SUM(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') THEN 1 ELSE NULL END) as CantImputados
         , EXP(AVG(LN(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') THEN c.promobs ELSE NULL END))) as PromImputados
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and r.periodo is null and c.impobs in ('R','RA') and co.impobs in ('R','RA') THEN c.PromObs ELSE NULL END))) as promRealesSinCambio 
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and r.periodo is null and c.impobs in ('R','RA') and co.impobs in ('R','RA') THEN co.PromObs ELSE NULL END))) as promRealesSinCambioAnt
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and n.periodo is null and n0.periodo is null THEN c.PromObs ELSE NULL END))) as promSinAltasBajas 
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and n.periodo is null and n0.periodo is null THEN co.PromObs ELSE NULL END))) as promSinAltasBajasAnt
         , EXP(AVG(LN(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') AND ii.informante is not null THEN c.PromObs ELSE NULL END))) as promImputadosInactivos
         , SUM(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') AND ii.informante is not null THEN 1 ELSE NULL END) as cantImputadosInactivos
    FROM CalObs c
    INNER JOIN cvp.calculos ca ON c.periodo=ca.periodo AND c.calculo=ca.calculo --PK verificada

    LEFT JOIN (SELECT p.producto, fi.informante, fi.formulario
                FROM productos p
                JOIN forprod fp on p.producto = fp.producto
                JOIN forinf fi on fi.formulario = fp.formulario
                JOIN formularios o on fi.formulario = o.formulario
                JOIN informantes_inactivos i on fi.formulario = i.formulario and fi.informante = i.informante
                WHERE o.activo = 'S') ii on c.producto = ii.producto and c.informante = ii.informante

    LEFT JOIN (SELECT DISTINCT periodo, producto, observacion, informante 
                 FROM cvp.relpre 
                 WHERE cambio = 'C' and periodo = pPeriodo) r ON c.periodo = r.periodo and c.producto = r.producto and c.observacion = r.observacion and c.informante = r.informante    
    LEFT JOIN cvp.calobs co ON  c.producto=co.producto AND c.observacion=co.observacion AND c.informante=co.informante AND co.periodo=ca.periodoanterior AND co.calculo=ca.calculoanterior --PK verificada
    LEFT JOIN cvp.novobs n ON c.periodo = n.periodo and c.calculo = n.calculo and c.producto = n.producto and c.informante = n.informante and c.observacion = n.observacion
    LEFT JOIN cvp.novobs n0 ON co.periodo = n0.periodo and co.calculo = n0.calculo and co.producto = n0.producto and co.informante = n0.informante and co.observacion = n0.observacion
    WHERE c.periodo=pPeriodo AND c.calculo=pCalculo
    GROUP BY c.periodo, c.Calculo, c.producto, c.division
LOOP
  UPDATE CalDiv p
    SET PromDiv=vcaltpinf.promobscal,
        ImpDiv=vcaltpinf.impobscal,
        CantIncluidos=vcaltpinf.CantIncluidos,
        CantAltas=vcaltpinf.CantAltas,
        CantBajas=vcaltpinf.CantBajas,
        PromAltas=vcaltpinf.PromAltas,
        PromBajas=vcaltpinf.PromBajas,
        CantImputados=vcaltpinf.CantImputados,
        CantExcluidos=vcaltpinf.CantExcluidos,
        PromExcluidos=vcaltpinf.PromExcluidos,
        PromImputados=vcaltpinf.PromImputados,
        PromedioRedondeado=round(vcaltpinf.promobscal::decimal,2),
        PromRealesSinCambio=vcaltpinf.promRealesSinCambio,
        PromRealesSinCambioAnt=vcaltpinf.promRealesSinCambioAnt,
        PromSinAltasBajas=vcaltpinf.promsinAltasBajas,
        PromsinAltasBajasAnt=vcaltpinf.promsinAltasBajasAnt,
        promImputadosInactivos = vcaltpinf.promImputadosInactivos,
        cantImputadosInactivos = vcaltpinf.cantImputadosInactivos
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo 
      AND p.producto=vcaltpinf.producto AND p.division=vcaltpinf.division;
END LOOP;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalDiv_PromFinal', pTipo:='finalizo');   
 
END;
$$;