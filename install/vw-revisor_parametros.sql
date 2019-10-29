CREATE OR REPLACE VIEW revisor_parametros AS 
 SELECT 'V181010' AS versionExigida, 'V130417' AS versionBase;

GRANT SELECT ON TABLE revisor_parametros TO cvp_administrador;
