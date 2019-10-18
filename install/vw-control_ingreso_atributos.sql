CREATE OR REPLACE VIEW control_ingreso_atributos AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.informante,
    v.formulario,
    v.visita,
    p.producto,
    p.observacion,
    a.atributo,
    atr.nombreatributo,
    a.valor,
    atr.tipodato
   FROM cvp.relvis v
     JOIN cvp.relpre p ON v.periodo::text = p.periodo::text AND v.informante = p.informante AND v.formulario = p.formulario AND v.visita = p.visita
     LEFT JOIN cvp.relatr a ON a.periodo::text = p.periodo::text AND a.visita = p.visita AND a.informante = p.informante AND a.producto::text = p.producto::text AND a.observacion = p.observacion
     LEFT JOIN cvp.atributos atr ON atr.atributo = a.atributo
  WHERE p.precio > 0.0::double precision AND a.atributo IS NOT NULL AND v.periodo::text >= 'a2009m05'::text AND (a.valor IS NULL OR atr.tipodato::text = 'N'::text AND NOT comun.es_numero(a.valor::text))
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario, p.producto, p.observacion;

GRANT SELECT ON TABLE control_ingreso_atributos TO cvp_usuarios;
GRANT SELECT ON TABLE control_ingreso_atributos TO cvp_recepcionista;
