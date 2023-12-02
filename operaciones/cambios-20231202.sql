set search_path = cvp;
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
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and rc.periodo is null and c.impobs in ('R','RA') and co.impobs in ('R','RA') THEN c.PromObs ELSE NULL END))) as promRealesSinCambio 
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and rc.periodo is null and c.impobs in ('R','RA') and co.impobs in ('R','RA') THEN co.PromObs ELSE NULL END))) as promRealesSinCambioAnt
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and n.periodo is null and n0.periodo is null THEN c.PromObs ELSE NULL END))) as promSinAltasBajas 
         , EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and co.antiguedadIncluido>0 and n.periodo is null and n0.periodo is null THEN co.PromObs ELSE NULL END))) as promSinAltasBajasAnt
          --imputados inactivos
         , EXP(AVG(LN(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') 
                              AND (r.periodo is null and ro.periodo is null         --no esta ahora ni el anterior 
                                   or v.periodo = r.periodo                         --está ahora pero negativizada
                                   or vo.periodo = ro.periodo and r.periodo is null --está en el anterior pero negativizada y no volvió a aparecer
                                   )
                      THEN c.PromObs ELSE NULL END))) as promImputadosInactivos
         , SUM(CASE WHEN c.AntiguedadIncluido>0 AND c.PromObs>0 AND c.ImpObs not in ('R','RA') 
                              AND (r.periodo is null and ro.periodo is null         --no esta ahora ni el anterior 
                                   or v.periodo = r.periodo                         --está ahora pero negativizada
                                   or vo.periodo = ro.periodo and r.periodo is null --está en el anterior pero negativizada y no volvió a aparecer
                                   )
                      THEN 1 ELSE NULL END) as cantImputadosInactivos
          --fin imputados inactivos
    FROM CalObs c
    INNER JOIN cvp.calculos ca ON c.periodo=ca.periodo AND c.calculo=ca.calculo --PK verificada
    --inactivos
    left join (select periodo, informante, visita, producto, observacion, formulario 
               from relpre 
               where ultima_visita) r on r.periodo = c.periodo and r.informante = c.informante
                and r.observacion = c.observacion and r.producto = c.producto
    left join periodos per on c.periodo = per.periodo
    left join (select periodo, informante, visita, producto, observacion, formulario 
               from relpre 
               where ultima_visita) ro on ro.periodo = per.periodoanterior and ro.informante = c.informante
                and ro.observacion = c.observacion and ro.producto = c.producto  
    left join (select periodo, informante, visita, formulario, escierredefinitivoinf, escierredefinitivofor
               from relvis v join razones z using(razon)
               where ultima_visita 
               and (escierredefinitivoinf = 'S' or escierredefinitivofor = 'S')) v 
                on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
    left join (select periodo, informante, visita, formulario, escierredefinitivoinf, escierredefinitivofor
               from relvis v join razones z using(razon)
               where ultima_visita 
               and (escierredefinitivoinf = 'S' or escierredefinitivofor = 'S')) vo 
                on ro.periodo = vo.periodo and ro.informante = vo.informante and ro.visita = vo.visita and ro.formulario = vo.formulario
     --fin inactivos
    LEFT JOIN (SELECT DISTINCT periodo, producto, observacion, informante 
                 FROM cvp.relpre 
                 WHERE cambio = 'C' and periodo = pPeriodo) rc ON c.periodo = rc.periodo and c.producto = rc.producto and c.observacion = rc.observacion and c.informante = rc.informante    
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