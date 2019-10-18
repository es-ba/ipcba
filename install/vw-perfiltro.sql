CREATE OR REPLACE VIEW perfiltro AS
 SELECT p.periodo
   FROM cvp.periodos p
  ORDER BY p.periodo DESC
 LIMIT 26;

GRANT SELECT ON TABLE perfiltro TO cvp_recepcionista;
GRANT SELECT ON TABLE perfiltro TO cvp_administrador;
