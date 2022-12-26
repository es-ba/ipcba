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