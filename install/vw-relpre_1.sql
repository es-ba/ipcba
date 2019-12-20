CREATE OR REPLACE VIEW cvp.relpre_1 AS 
 SELECT r.periodo,
    r.producto,
    r.observacion,
    r.informante,
    r.formulario,
    r.visita,
    r.precio,
    r.tipoprecio,
    r.cambio,
    r.comentariosrelpre,
    r.observaciones,
    r_1.precio AS precio_1,
    r_1.tipoprecio AS tipoprecio_1,
    r_1.cambio AS cambio_1,
    r_1.periodo AS periodo_1,
    r_1.visita AS visita_1,
    r.precionormalizado,
    r_1.precionormalizado AS precionormalizado_1,
    r_1.comentariosrelpre AS comentariosrelpre_1,
    r_1.esvisiblecomentarioendm AS esvisiblecomentarioendm_1
   FROM cvp.relpre r
     LEFT JOIN cvp.periodos p ON r.periodo::text = p.periodo::text
     LEFT JOIN cvp.relpre r_1 ON r_1.periodo::text =
        CASE
            WHEN r.visita > 1 THEN r.periodo
            ELSE p.periodoanterior
        END::text AND (r_1.ultima_visita = true AND r.visita = 1 OR r.visita > 1 AND r_1.visita = (r.visita - 1)) AND r_1.informante = r.informante AND r_1.producto::text = r.producto::text AND r_1.observacion = r.observacion;
            
GRANT SELECT ON TABLE relpre_1 TO cvp_usuarios;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE relpre_1 TO cvp_administrador;