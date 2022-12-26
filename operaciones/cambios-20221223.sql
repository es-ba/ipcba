-- UTF8:Sí
set search_path = cvp;
ALTER TABLE caldiv ADD COLUMN promImputadosInactivos double precision;
ALTER TABLE caldiv ADD COLUMN cantImputadosInactivos integer;

CREATE OR REPLACE VIEW informantes_inactivos AS
SELECT a.informante, a.visita, a.formulario, periodoNegativo FROM 
      (SELECT r.informante, r.visita, r.formulario, max(periodo) periodoNegativo
         FROM relvis r 
         JOIN razones z on r.razon = z.razon
         JOIN formularios f on r.formulario = f.formulario
         WHERE z.escierredefinitivoinf = 'S' and f.activo ='S' and r.ultima_visita
         GROUP BY r.informante, r.visita, r.formulario
         ORDER BY r.informante, r.visita, r.formulario
      ) a
LEFT JOIN
      (SELECT r.informante, r.visita, r.formulario, max(periodo) periodoPositivo
         FROM relvis r 
         JOIN razones z on r.razon = z.razon
         JOIN formularios f on r.formulario = f.formulario
         WHERE z.escierredefinitivoinf = 'N' and f.activo ='S' and r.ultima_visita
         GROUP BY r.informante, r.visita, r.formulario
         ORDER BY r.informante, r.visita, r.formulario
       ) b
ON a.informante = b.informante and a.formulario = b.formulario and a.visita = b.visita
WHERE coalesce(b.periodoPositivo,'a0000m00') < PeriodoNegativo; 

GRANT SELECT ON TABLE informantes_inactivos TO cvp_administrador;

------------------------------------------------------------------------------------------------
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
      --case when (z.escierredefinitivoinf = 'S' or v.informante is null and c.promobs is not null and vv.informante is null) then ' '||'| Inactivo ' else ''::text end
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

-------------------------------------------------------------------------------------------
-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_Subir(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vr RECORD; 
  vtipo_promedio text;  
  v_promedio NUMERIC;
BEGIN  
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Subir','comenzo');

for vr in
  SELECT DISTINCT d.periodo, d.calculo, d.producto, d.profundidad, d.division, d.tipo_promedio
      FROM  CalDiv c join  CalDiv d ON c.periodo=d.periodo AND c.calculo=d.calculo AND c.producto=d.producto AND c.divisionpadre=d.division
      WHERE c.periodo=pperiodo 
        AND c.calculo=pcalculo
      ORDER BY d.periodo, d.calculo, d.producto, d.profundidad DESC, d.division
Loop
    vtipo_promedio= vr.tipo_promedio;
    UPDATE CalDiv t
        SET  PromPriImpAct= pr_priImpAct,
           PromPriImpAnt= pr_priImpAnt,
           PromPrel     = pr_prel,
           PromDiv      = pr_Div,
           PromAltas    = pr_Altas,
           PromBajas    = pr_Bajas,
           ImpDiv       = mimp,
           CantIncluidos= n_incluidos,
           CantAltas    = n_Altas, 
           CantBajas    = n_Bajas,
           CantImputados= n_Imputados,
           CantExcluidos= n_excluidos,
           PromExcluidos= pr_excluidos,
           PromImputados= pr_Imputados,
           CantRealesIncluidos= n_realesincluidos,
           CantRealesExcluidos= n_realesexcluidos,
           CantRealesDescartados= n_realesdescartados,
           PromRealesIncluidos= pr_realesincluidos,
           PromRealesExcluidos= pr_realesexcluidos,
           CantPriImp         = n_priimp,
           PromedioRedondeado = round(pr_Div::decimal,2),
           CantPreciosTotales = n_preciostotales,
           CantPreciosIngresados = n_preciosingresados,
           CantConPrecioParaCalEstac= n_ConPrecioParaCalEstac,
           PromRealesSinCambio=pr_sincambio,
           PromRealesSinCambioAnt=pr_sincambioant,
           PromSinAltasBajas=pr_sinAltasBajas,
           PromSinAltasBajasAnt=pr_sinAltasBajasAnt,
           promImputadosInactivos=pr_imputadosInactivos,
           cantImputadosInactivos=n_imputadosInactivos
        FROM (  
            SELECT AVG(a.PromPriImpAct) pr_priImpAct,
                   AVG(a.PromPriImpAnt) pr_priImpAnt,
                   AVG(a.PromPrel     ) pr_prel     ,
                   AVG(a.PromDiv      ) pr_Div      ,
                   AVG(a.PromAltas    ) pr_Altas    ,
                   AVG(a.PromBajas    ) pr_Bajas    ,
                   AVG(a.PromExcluidos) pr_Excluidos,
                   MIN(a.impDiv) mimp,
                   SUM(a.CantIncluidos) n_incluidos,
                   SUM(a.CantAltas) n_altas,
                   SUM(a.CantBajas) n_bajas,
                   SUM(a.CantImputados) n_imputados,
                   SUM(a.CantExcluidos) n_excluidos, 
                   AVG(a.PromImputados) pr_imputados,
                   SUM(a.CantRealesIncluidos) n_realesincluidos,
                   SUM(a.CantRealesExcluidos) n_realesexcluidos,
                   SUM(a.CantRealesDescartados) n_realesdescartados,
                   AVG(a.PromRealesIncluidos) pr_realesincluidos,
                   AVG(a.PromRealesExcluidos) pr_realesExcluidos,
                   SUM(a.CantPriImp) n_priimp,
                   SUM(a.CantPreciosTotales) n_preciostotales,
                   SUM(a.CantPreciosIngresados) n_preciosingresados,
                   SUM(a.CantConPrecioParaCalEstac) n_ConPrecioParaCalEstac,
                   AVG(a.PromRealesSinCambio) pr_sincambio,
                   AVG(a.PromRealesSinCambioAnt) pr_sincambioant,
                   AVG(a.PromSinAltasBajas) pr_sinAltasBajas,
                   AVG(a.PromSinAltasBajasAnt) pr_sinAltasBajasant,
                   AVG(a.promImputadosInactivos) pr_ImputadosInactivos,
                   SUM(a.cantImputadosInactivos) n_ImputadosInactivos,
                   'AriAuto' tipo_promedio
                FROM  caldiv a  
                  WHERE a.periodo=pperiodo AND a.calculo=pcalculo AND a.producto=vr.producto AND a.divisionpadre=vr.division
                    and vtipo_promedio='AriAuto' 
            UNION        
              SELECT SUM(a.PromPriImpAct*a.ponderadorDiv)/sum(case when a.PromPriImpAct is null then null else a.ponderadorDiv end) pr_priImpAct,
                     SUM(a.PromPriImpAnt*a.ponderadorDiv)/sum(case when a.PromPriImpAnt is null then null else a.ponderadorDiv end) pr_priImpAnt,
                     SUM(a.PromPrel     *a.ponderadorDiv)/sum(case when a.PromPrel      is null then null else a.ponderadorDiv end) pr_prel     ,
                     SUM(a.PromDiv      *a.ponderadorDiv)/sum(case when a.PromDiv       is null then null else a.ponderadorDiv end) pr_Div      ,
                     SUM(a.PromAltas    *a.ponderadorDiv)/sum(case when a.PromAltas     is null then null else a.ponderadorDiv end) pr_Altas    ,
                     SUM(a.PromBajas    *a.ponderadorDiv)/sum(case when a.PromBajas     is null then null else a.ponderadorDiv end) pr_Bajas    ,
                     SUM(a.PromExcluidos*a.ponderadorDiv)/sum(case when a.PromExcluidos is null then null else a.ponderadorDiv end) pr_Excluidos,
                     MIN(a.impDiv) mimp,
                     SUM(a.CantIncluidos) n_incluidos,
                     SUM(a.CantAltas) n_altas,
                     SUM(a.CantBajas) n_bajas,
                     SUM(a.CantImputados) n_imputados,                   
                     SUM(a.CantExcluidos) n_excluidos, 
                     SUM(a.PromImputados*a.ponderadorDiv)/sum(case when a.PromImputados is null then null else a.ponderadorDiv end) pr_imputados,
                     SUM(a.CantRealesIncluidos) n_realesincluidos,
                     SUM(a.CantRealesExcluidos) n_realesexcluidos,
                     SUM(a.CantRealesDescartados) n_realesdescartados,
                     SUM(a.PromRealesIncluidos*a.ponderadorDiv)/sum(case when a.PromRealesIncluidos is null then null else a.ponderadorDiv end) pr_realesincluidos,
                     SUM(a.PromRealesExcluidos*a.ponderadorDiv)/sum(case when a.PromRealesExcluidos is null then null else a.ponderadorDiv end) pr_realesexcluidos,
                     SUM(a.CantPriImp) n_priimp,
                     SUM(a.CantPreciosTotales) n_preciostotales,
                     SUM(a.CantPreciosIngresados) n_preciosingresados,
                     SUM(a.CantConPrecioParaCalEstac) n_ConPrecioParaCalEstac,
                     SUM(a.PromRealesSinCambio    *a.ponderadorDiv)/sum(case when a.PromRealesSinCambio     is null then null else a.ponderadorDiv end) pr_sincambio,
                     SUM(a.PromRealesSinCambioAnt *a.ponderadorDiv)/sum(case when a.PromRealesSinCambioAnt  is null then null else a.ponderadorDiv end) pr_sincambioant,
                     SUM(a.PromSinAltasBajas      *a.ponderadorDiv)/sum(case when a.PromSinAltasBajas       is null then null else a.ponderadorDiv end) pr_sinAltasBajas,
                     SUM(a.PromSinAltasBajasAnt   *a.ponderadorDiv)/sum(case when a.PromSinAltasBajasAnt    is null then null else a.ponderadorDiv end) pr_sinAltasBajasant,
                     SUM(a.PromimputadosInactivos *a.ponderadorDiv)/sum(case when a.PromImputadosInactivos  is null then null else a.ponderadorDiv end) pr_ImputadosInactivos,
                     SUM(a.CantImputadosInactivos) n_ImputadosInactivos,
                     'AriPond' tipo_promedio
                FROM  caldiv a  
                  WHERE a.periodo=pperiodo AND a.calculo=pcalculo AND a.producto=vr.producto AND a.divisionpadre=vr.division
                   and vtipo_promedio='AriPond'
            UNION        
              SELECT EXP(AVG(LN(a.PromPriImpAct))) pr_priImpAct,
                     EXP(AVG(LN(a.PromPriImpAnt))) pr_priImpAnt,
                     EXP(AVG(LN(a.PromPrel     ))) pr_prel     ,
                     EXP(AVG(LN(a.PromDiv      ))) pr_Div      ,
                     EXP(AVG(LN(a.PromAltas    ))) pr_Altas    ,
                     EXP(AVG(LN(a.PromBajas    ))) pr_Bajas    ,
                     EXP(AVG(LN(a.PromExcluidos))) pr_Excluidos,
                     MIN(a.impDiv) mimp,
                     SUM(a.CantIncluidos) n_incluidos,
                     SUM(a.CantAltas) n_altas,
                     SUM(a.CantBajas) n_bajas,
                     SUM(a.CantImputados) n_imputados,                   
                     SUM(a.CantExcluidos) n_excluidos,                   
                     EXP(AVG(LN(a.PromImputados))) pr_imputados,
                     SUM(a.CantRealesIncluidos) n_realesincluidos,
                     SUM(a.CantRealesExcluidos) n_realesexcluidos,
                     SUM(a.CantRealesDescartados) n_realesdescartados,
                     EXP(AVG(LN(a.PromRealesIncluidos))) pr_realesincluidos,
                     EXP(AVG(LN(a.PromRealesExcluidos))) pr_realesexcluidos,
                     SUM(a.CantPriImp) n_priimp,
                     SUM(a.CantPreciosTotales) n_preciostotales,
                     SUM(a.CantPreciosIngresados) n_preciosingresados,
                     SUM(a.CantConPrecioParaCalEstac) n_ConPrecioParaCalEstac,
                     EXP(AVG(LN(a.PromRealesSinCambio      ))) pr_sincambio   ,
                     EXP(AVG(LN(a.PromRealesSinCambioAnt   ))) pr_sincambioAnt,
                     EXP(AVG(LN(a.PromSinAltasBajas      ))) pr_sinAltasBajas   ,
                     EXP(AVG(LN(a.PromSinAltasBajasAnt   ))) pr_sinAltasBajasAnt,
                     EXP(AVG(LN(a.PromImputadosInactivos ))) pr_ImputadosInactivos,
                     SUM(a.CantImputadosInactivos) n_ImputadosInactivos,
                     'GeoAuto' tipo_promedio
                FROM  caldiv a  
                  WHERE a.periodo=pperiodo AND a.calculo=pcalculo AND a.producto=vr.producto AND a.divisionpadre=vr.division
                   and vtipo_promedio='GeoAuto'
            UNION        
              SELECT EXP(SUM(LN(a.PromPriImpAct)*a.ponderadorDiv)/SUM(case when a.PromPriImpAct is null then null else a.ponderadorDiv end)) pr_priImpAct,
                     EXP(SUM(LN(a.PromPriImpAnt)*a.ponderadorDiv)/SUM(case when a.PromPriImpAnt is null then null else a.ponderadorDiv end)) pr_priImpAnt,
                     EXP(SUM(LN(a.PromPrel     )*a.ponderadorDiv)/SUM(case when a.PromPrel      is null then null else a.ponderadorDiv end)) pr_prel     ,
                     EXP(SUM(LN(a.PromDiv      )*a.ponderadorDiv)/SUM(case when a.PromDiv       is null then null else a.ponderadorDiv end)) pr_Div      ,
                     EXP(SUM(LN(a.PromAltas    )*a.ponderadorDiv)/SUM(case when a.PromAltas     is null then null else a.ponderadorDiv end)) pr_Altas    ,
                     EXP(SUM(LN(a.PromBajas    )*a.ponderadorDiv)/SUM(case when a.PromBajas     is null then null else a.ponderadorDiv end)) pr_Bajas    ,
                     EXP(SUM(LN(a.PromExcluidos)*a.ponderadorDiv)/SUM(case when a.PromExcluidos is null then null else a.ponderadorDiv end)) pr_Excluidos,
                     MIN(a.impDiv) mimp,
                     SUM(a.CantIncluidos) n_incluidos,
                     SUM(a.CantAltas) n_altas,
                     SUM(a.CantBajas) n_bajas,
                     SUM(a.CantImputados) n_imputados,                   
                     SUM(a.CantExcluidos) n_excluidos,                   
                     EXP(SUM(LN(a.PromImputados)*a.ponderadorDiv)/SUM(case when a.PromImputados is null then null else a.ponderadorDiv end)) pr_imputados,
                     SUM(a.CantRealesIncluidos) n_realesincluidos,
                     SUM(a.CantRealesExcluidos) n_realesexcluidos,
                     SUM(a.CantRealesDescartados) n_realesdescartados,
                     EXP(SUM(LN(a.PromRealesIncluidos)*a.ponderadorDiv)/SUM(case when a.PromRealesIncluidos is null then null else a.ponderadorDiv end)) pr_realesincluidos,
                     EXP(SUM(LN(a.PromRealesExcluidos)*a.ponderadorDiv)/SUM(case when a.PromRealesExcluidos is null then null else a.ponderadorDiv end)) pr_realesexcluidos,
                     SUM(a.CantPriImp) n_priimp,
                     SUM(a.CantPreciosTotales) n_preciostotales,
                     SUM(a.CantPreciosIngresados) n_preciosingresados,
                     SUM(a.CantConPrecioParaCalEstac) n_ConPrecioParaCalEstac,
                     EXP(SUM(LN(a.PromRealesSinCambio    )*a.ponderadorDiv)/SUM(case when a.PromRealesSinCambio    is null then null else a.ponderadorDiv end)) pr_sincambio   ,
                     EXP(SUM(LN(a.PromRealesSinCambioAnt )*a.ponderadorDiv)/SUM(case when a.PromRealesSinCambioAnt is null then null else a.ponderadorDiv end)) pr_sincambioant,
                     EXP(SUM(LN(a.PromsinAltasBajas      )*a.ponderadorDiv)/SUM(case when a.PromsinAltasBajas      is null then null else a.ponderadorDiv end)) pr_sinAltasBajas   ,
                     EXP(SUM(LN(a.PromsinAltasBajasAnt   )*a.ponderadorDiv)/SUM(case when a.PromsinAltasBajasAnt   is null then null else a.ponderadorDiv end)) pr_sinAltasBajasant,
                     EXP(SUM(LN(a.PromImputadosInactivos )*a.ponderadorDiv)/SUM(case when a.PromImputadosInactivos is null then null else a.ponderadorDiv end)) pr_imputadosInactivos,
                     SUM(a.CantImputadosInactivos) n_imputadosInactivos,
                     'GeoPond' tipo_promedio
                FROM  caldiv a  
                  WHERE a.periodo=pperiodo AND a.calculo=pcalculo AND a.producto=vr.producto AND a.divisionpadre=vr.division
                   and vtipo_promedio='GeoPond'
            UNION        
              SELECT SUM(case when a.PromPriImpAct is null or a.PromPriImpAnt is null then null else a.PromPriImpAct end) pr_priImpAct,
                     SUM(case when a.PromPriImpAct is null or a.PromPriImpAnt is null then null else a.PromPriImpAnt end) pr_priImpAnt,
                     SUM(a.PromPrel) pr_prel     ,
                     SUM(a.PromDiv ) pr_Div      ,
                     null pr_Altas    ,
                     null pr_Bajas    ,
                     null pr_Excluidos,
                     MIN(a.impDiv) mimp,
                     SUM(a.CantIncluidos) n_incluidos,
                     SUM(a.CantAltas) n_altas,
                     SUM(a.CantBajas) n_bajas,
                     SUM(a.CantImputados) n_imputados,
                     SUM(a.CantExcluidos) n_excluidos,                     
                     null pr_imputados,
                     SUM(a.CantRealesIncluidos) n_realesincluidos,
                     SUM(a.CantRealesExcluidos) n_realesexcluidos,
                     SUM(a.CantRealesDescartados) n_realesdescartados,
                     null pr_realesincluidos,
                     null pr_realesexcluidos,
                     SUM(a.CantPriImp) n_priimp,
                     SUM(a.CantPreciosTotales) n_preciostotales,
                     SUM(a.CantPreciosIngresados) n_preciosingresados,
                     SUM(a.CantConPrecioParaCalEstac) n_ConPrecioParaCalEstac,
                     SUM(a.PromRealesSinCambio ) pr_sincambio,
                     SUM(a.PromRealesSinCambioAnt ) pr_sincambioant,
                     SUM(a.PromsinAltasBajas ) pr_sinAltasBajas,
                     SUM(a.PromsinAltasBajasAnt ) pr_sinAltasBajasant,
                     SUM(a.PromImputadosInactivos ) pr_ImputadosInactivos,
                     SUM(a.CantImputadosInactivos) n_ImputadosInactivos,
                     'Suma' tipo_promedio
                FROM  caldiv a  
                  WHERE a.periodo=pperiodo AND a.calculo=pcalculo AND a.producto=vr.producto AND a.divisionpadre=vr.division
                   and vtipo_promedio='Suma'
           ) as p           
        WHERE t.periodo=pperiodo AND t.calculo=pcalculo AND t.producto=vr.producto AND t.division=vr.division
              AND p.tipo_promedio= vr.tipo_promedio 
           ;
end loop;
execute CalDiv_ImpExt(pPeriodo, pCalculo );
execute Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Subir','finalizo');   
END;
$$;

-----------------------------------------------------------------------------------
-- FUNCTION: cvp.copiarcalculo(text, integer, text, integer, text)

-- DROP FUNCTION IF EXISTS cvp.copiarcalculo(text, integer, text, integer, text);

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

-----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW caldiv_vw AS 
 SELECT c.periodo, c.calculo, c.producto, p.nombreproducto, c.division, c.prompriimpact, c.prompriimpant,
         CASE
            WHEN c.prompriimpact > 0 AND c.prompriimpant > 0 THEN round((c.prompriimpact / c.prompriimpant * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp, c.promprel, c.promdiv, c0.promdiv AS promdivant, c.promedioredondeado, c.impdiv,
    --cantincluidos y cantrealesincluidos    
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantincluidos END AS cantincluidos, 
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantrealesincluidos END AS cantrealesincluidos, 
    c.cantrealesexcluidos, c.promvar, c.cantaltas, 
    c.promaltas, c.cantbajas, c.prombajas, c.cantimputados, c.ponderadordiv, 
    c.umbralpriimp, c.umbraldescarte, c.umbralbajaauto, c.cantidadconprecio, 
    c.profundidad, c.divisionpadre, c.tipo_promedio, c.raiz, c.cantexcluidos, 
    c.promexcluidos, c.promimputados, c.promrealesincluidos, 
    c.promrealesexcluidos, c.cantrealesdescartados, c.cantpreciostotales, 
    c.cantpreciosingresados, c.cantconprecioparacalestac, 
        CASE
            WHEN c.promdiv > 0 AND c0.promdiv > 0 THEN round((c.promdiv / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promSinImpExt,
        CASE
            WHEN c.promSinImpExt > 0 AND c0.promdiv > 0 THEN round((c.promSinImpExt / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinImpExt,
    --cs.varSinCambio
        CASE
            WHEN c.promrealessincambio > 0 AND c.promrealessincambioAnt > 0 THEN round((c.promrealessincambio / c.promrealessincambioAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinCambio,
    --cs.varSinAltasBajas
        CASE
            WHEN c.promsinaltasbajas > 0 AND c.promsinaltasbajasAnt > 0 THEN round((c.promsinaltasbajas / c.promsinaltasbajasAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinAltasBajas,
    CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, r.responsable, p."cluster", c.promImputadosInactivos, c.cantimputadosinactivos
   FROM cvp.caldiv c
   LEFT JOIN cvp.productos p on c.producto = p.producto
   LEFT JOIN cvp.calculos l ON c.periodo = l.periodo and c.calculo = l.calculo  
   LEFT JOIN cvp.caldiv c0 ON c0.periodo = l.periodoanterior AND 
       c0.calculo = l.calculoanterior AND --((c.calculo = 0 and c0.calculo = c.calculo) or (c.calculo > 0 and c0.calculo = 0)) AND 
       c.producto = c0.producto AND c.division = c0.division
   LEFT JOIN (SELECT grupo FROM cvp.gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.producto = gg.grupo     
   LEFT JOIN cvp.CalProdResp r on c.periodo = r.periodo and c.calculo = r.calculo and c.producto = r.producto;
   