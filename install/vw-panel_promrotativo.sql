CREATE OR REPLACE VIEW panel_promrotativo AS 
    SELECT pa.periodo, v2.producto, avg(v2.precionormalizado) promrotativo, stddev(v2.precionormalizado) desvprot 
      FROM  cvp.relvis vis,cvp.relpre v2, cvp.relpan pa
      WHERE vis.informante = v2.informante AND vis.periodo = v2.periodo AND vis.visita = v2.visita AND vis.formulario=v2.formulario             
           AND (  pa.periodoParaPanelRotativo=v2.periodo  AND vis.panel=pa.panel ) 
      GROUP BY pa.periodo, v2.producto 
      ORDER BY pa.periodo, v2.producto ;

GRANT SELECT ON TABLE cvp.panel_promrotativo TO cvp_usuarios;

