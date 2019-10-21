CREATE OR REPLACE VIEW control_calobs AS 
    SELECT c.producto ,c.informante, c.observacion, c.periodo, r.visita, 
           CASE WHEN visita>1 THEN null ELSE ROUND(c.promobs::DECIMAL,2) END AS promobs, CASE WHEN visita>1 THEN null ELSE c.impobs END, 
           CASE WHEN visita>1 THEN null ELSE ROUND(c_1.promobs::DECIMAL,2) END AS promobs_1, 
           CASE WHEN (visita>1 OR c_1.promobs = 0) THEN NULL ELSE ROUND((c.promobs / c_1.promobs * 100 - 100)::DECIMAL, 1) END AS variacion, 
           r.cambio, r.precionormalizado, r.precio, r.tipoprecio
      FROM cvp.relpre r
      FULL OUTER JOIN cvp.calobs c ON c.periodo=r.periodo  AND c.producto=r.producto AND c.observacion=r.observacion AND c.informante=r.informante 
      JOIN cvp.calculos ca ON ca.periodo=c.periodo AND ca.calculo=c.calculo
      LEFT JOIN cvp.calobs c_1 ON c_1.producto=c.producto AND c_1.calculo=ca.calculoanterior AND c_1.informante=c.informante AND c_1.observacion=c.observacion
                                  AND c_1.periodo=ca.periodoanterior
      WHERE c.calculo=0 ; 

GRANT SELECT ON TABLE control_calobs TO cvp_administrador; 