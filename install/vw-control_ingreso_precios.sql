CREATE OR REPLACE VIEW control_ingreso_precios AS
 SELECT p.periodo,
    v.panel,
    v.tarea,
    p.informante,
    p.formulario,
    p.visita,
    v.razon,
    p.producto,
    p.observacion
   FROM cvp.relvis v
     JOIN cvp.razones z ON v.razon = z.razon
     LEFT JOIN cvp.relpre p ON v.periodo::text = p.periodo::text AND v.informante = p.informante AND v.formulario = p.formulario AND v.visita = p.visita
  WHERE p.precio IS NULL AND p.tipoprecio IS NULL AND z.espositivoformulario::text = 'S'::text
  ORDER BY p.periodo, v.panel, v.tarea, p.informante, p.formulario, p.visita, p.producto, p.observacion;

GRANT SELECT ON TABLE control_ingreso_precios TO cvp_usuarios;
GRANT SELECT ON TABLE control_ingreso_precios TO cvp_recepcionista;
