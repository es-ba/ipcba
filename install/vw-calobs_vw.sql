CREATE OR REPLACE VIEW calobs_vw AS
SELECT c.* 
  FROM CalObs c JOIN calculos_def cd on c.calculo = cd.calculo 
  WHERE cd.principal;

GRANT SELECT ON TABLE CalObs_vw TO cvp_administrador;
