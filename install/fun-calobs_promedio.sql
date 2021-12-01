--UTF8: Sí
-- Function: CalObs_promedio(text, integer)
CREATE OR REPLACE FUNCTION CalObs_promedio(pperiodo text, pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vpr_AtrAgrpV1 RECORD;
hayDistintas INTEGER;
vmaxpanel INTEGER;
   
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_promedio', pTipo:='comenzo');
  SELECT MAX(panel) INTO vmaxpanel FROM relpan WHERE periodo = pperiodo;
  INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, 
                   PromObs, ImpObs, muestra)
    (SELECT        r.periodo, pcalculo, r.producto, r.informante, r.observacion, 
                   COALESCE(max(de.divisionespecial), case when pd.sindividir then '0' else pd.division end), 
                   CASE WHEN v.es_vigencia is null THEN 
                          AVG(r.precionormalizado) 
                        WHEN v.es_vigencia THEN 
                          SUM(r.precionormalizado*v.nvalor)/SUM(v.nvalor) 
                   END,
                   CASE WHEN max(de.divisionespecial)<>min(de.divisionespecial) -- <> implica not null para ambos. 
                            THEN 'ERROR' -- ESTO NO APARECE SE FILTRA EN EL HAVING y se inserta el error ahí.
                        WHEN COUNT(case when r.tipoprecio = 'I' then 1 else null end) = 1 THEN 'IRM' --Imputacion Registrada Manualmente
                        WHEN max(de.divisionespecial) IS NOT NULL THEN 'RA' 
                        ELSE 'R' 
                   END, 
                   i.muestra
       FROM RelPre r
         LEFT JOIN 
           (SELECT ra.periodo,ra.producto,ra.observacion,ra.informante,ra.visita,ra.valor::decimal as nvalor,a.es_vigencia 
              FROM RelAtr ra 
              JOIN Atributos a ON ra.atributo = a.atributo
              WHERE a.es_vigencia = true) v -- busca, si existe, el único atributo vigencia
            ON r.periodo = v.periodo AND r.producto = v.producto AND r.observacion = v.observacion 
                AND r.informante = v.informante AND r.visita = v.visita
         LEFT JOIN
             (SELECT rla.periodo, rla.producto, rla.observacion, rla.informante, rla.visita, string_agg(rla.valor,'~' order by pa.orden_calculo_especial) divisionEspecial
                 FROM RelAtr rla JOIN ProdAtr pa ON rla.producto = pa.producto AND rla.atributo = pa.atributo 
                 WHERE pa.orden_calculo_especial IS NOT NULL 
                 GROUP BY rla.periodo, rla.producto, rla.observacion, rla.informante, rla.visita) de
               ON r.periodo = de.periodo AND r.producto = de.producto AND r.observacion = de.observacion AND r.informante = de.informante AND r.visita=de.visita
       JOIN Informantes i ON r.informante=i.informante 
       inner join (select producto, division, tipoinformante, sindividir 
                    from proddiv
                   union
                   select producto, divisionhibrido as division, tipoinformante, null as sindividir  
                    from productos, tipoinf 
                   where divisionhibrido is not null and otrotipoinformante is null) pd on pd.producto=r.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
       inner join Calculos c on c.periodo=r.Periodo and c.calculo=pCalculo 
       inner join Calculos_def cd on cd.calculo=c.calculo
       INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto 
       --LEFT JOIN CalBase_Prod cbp ON cbp.calculo=c.calculo AND cbp.producto=r.producto  --Pk verificada
       LEFT JOIN CalBase_Obs  cbo ON cbo.calculo=COALESCE(cd.rellenante_de,cd.calculo) AND cbo.producto=r.producto AND cbo.informante=r.informante AND cbo.observacion=r.observacion, --Pk verificada
       LATERAL (SELECT * FROM relvis WHERE panel <= COALESCE(c.hasta_panel,vmaxpanel) AND periodo = r.periodo AND informante = r.informante AND visita = r.visita AND formulario = r.formulario) vis  
       WHERE (r.periodo=pperiodo AND r.PrecioNormalizado is not null )  
         AND ( c.esperiodobase='N'
             --OR  ( c.esperiodobase='S' AND cbo.incluido AND c.periodo<c.periodoanterior)
             OR  ( c.esperiodobase='S' AND cbo.incluido AND cbo.periodo_aparicion is not null AND c.periodo >= cbo.periodo_aparicion 
                  AND (c.periodo <=cbo.periodo_anterior_baja or cbo.periodo_anterior_baja is null)
                  ) 
              )
       GROUP BY r.periodo, pcalculo, r.producto, r.informante, r.observacion, v.es_vigencia, pd.division, i.muestra, pd.sindividir
       HAVING
            CASE WHEN max(de.divisionespecial)<>min(de.divisionespecial) 
               THEN Cal_Mensajes(r.Periodo, pCalculo, 'CalObs_promedio', pTipo:='error', 
                    pmensaje:= 'ERROR: No coinciden los valores de los atributos en las visitas de '||r.periodo||' c'||pCalculo||' '||r.producto||' obs '||r.observacion||' inf '||r.informante,
                    pProducto:=r.producto, pdivision:=min(de.divisionespecial), pinformante:=r.informante,
                    pobservacion:= r.observacion)
               ELSE 'OK' 
            END='OK'
    );
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_promedio', pTipo:='finalizo');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;