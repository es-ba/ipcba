CREATE OR REPLACE VIEW panel_promrotativo_mod AS
 SELECT pa.periodo,
    v2.producto,
    avg(v2.precionormalizado) AS promrotativo,
    stddev(v2.precionormalizado) AS desvprot
   FROM cvp.relvis vis,
    cvp.relpre v2,
    cvp.relpan pa
  WHERE vis.informante = v2.informante AND vis.periodo::text = v2.periodo::text AND vis.visita = v2.visita AND vis.formulario = v2.formulario AND pa.periodoparapanelrotativo::text = v2.periodo::text AND vis.panel = pa.panel
  GROUP BY pa.periodo, v2.producto
  ORDER BY pa.periodo, v2.producto;

GRANT SELECT ON TABLE panel_promrotativo_mod TO cvp_usuarios;
GRANT SELECT ON TABLE panel_promrotativo_mod TO cvp_recepcionista;
