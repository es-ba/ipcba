-- Dar permisos de lectura al rol cvp_usuarios sobre tablas cambiopantar
GRANT SELECT ON TABLE cvp.cambiopantar_lote TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.cambiopantar_det TO cvp_usuarios;