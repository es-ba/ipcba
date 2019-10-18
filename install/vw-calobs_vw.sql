CREATE OR REPLACE VIEW calobs_vw AS
  SELECT * FROM CalObs
  WHERE calculo in (0);

GRANT SELECT ON TABLE CalObs_vw TO cvp_administrador;
