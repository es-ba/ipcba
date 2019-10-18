CREATE OR REPLACE VIEW foresp AS
 SELECT forobs.formulario,
    forobs.producto,
    forobs.observacion AS especificacion,
    forobs.orden
   FROM cvp.forobs;

GRANT SELECT ON TABLE foresp TO cvp_usuarios;
GRANT SELECT ON TABLE foresp TO cvp_recepcionista;
