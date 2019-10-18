CREATE OR REPLACE VIEW estadoinformantes AS
 SELECT periodos.periodo,
    informantes.informante,
    informantes.conjuntomuestral,
    cvp.estadoinformante(periodos.periodo::text, informantes.informante) AS estadoinformante
   FROM cvp.periodos,
    cvp.informantes;

GRANT SELECT ON TABLE estadoinformantes TO cvp_usuarios;
GRANT SELECT ON TABLE estadoinformantes TO cvp_recepcionista;
