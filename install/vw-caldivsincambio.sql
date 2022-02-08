CREATE OR REPLACE VIEW caldivsincambio AS 
SELECT periodo, calculo, producto, division, promdivsincambio, promdivant,
       CASE
        WHEN promdivant > 0 AND promdivsincambio > 0 THEN round((promdivsincambio / promdivant * 100 - 100)::numeric, 1)
         ELSE NULL::numeric
       END AS varSinCambio
FROM (SELECT c.periodo, c.calculo, c.producto, c.division, 
        EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and c0.antiguedadIncluido>0 and r.periodo is null THEN c.PromObs ELSE NULL END))) as promdivsincambio, 
        EXP(AVG(LN(CASE WHEN c.promobs> 0 and c.antiguedadIncluido>0 and c0.antiguedadIncluido>0 and r.periodo is null THEN c0.PromObs ELSE NULL END))) as promdivant
           FROM cvp.calobs c
           LEFT JOIN 
           (SELECT DISTINCT periodo, producto, observacion, informante 
               FROM cvp.relpre 
               WHERE cambio = 'C') r 
           ON c.periodo = r.periodo and c.producto = r.producto and c.observacion = r.observacion and c.informante = r.informante
           LEFT JOIN cvp.calculos ca on c.periodo = ca.periodo and c.calculo = ca.calculo 
           LEFT JOIN cvp.calobs c0 on ca.periodoanterior = c0.periodo and ca.calculoanterior = c0.calculo and c.producto = c0.producto 
               and c.informante = c0.informante and c.observacion = c0.observacion
           LEFT JOIN cvp.caldiv d ON c.periodo = d.periodo and c.calculo = d.calculo and c.producto = d.producto and c.division = d.division
           LEFT JOIN cvp.calculos_def cf on c.calculo = cf.calculo
        WHERE cf.principal and c.impobs in ('R','RA') and c0.impobs in ('R','RA') --reales en ambos meses
        GROUP BY c.periodo, c.calculo, c.producto, c.division
     ) AS X;

GRANT SELECT ON TABLE caldivsincambio TO cvp_administrador;