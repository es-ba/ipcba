CREATE OR REPLACE VIEW control_atributos AS 
 SELECT v.periodo, v.producto, f.nombreproducto, vi.formulario, v.informante, v.observacion, v.visita, vi.panel, vi.tarea, vi.encuestador, vi.recepcionista,
    'Valor Normal '||pa.valornormal||' '||a.nombreatributo::text||' '::text||v.valor::text||' Rango '::text||pa.rangodesde||' a '::text||pa.rangohasta AS fueraderango
   FROM cvp.relatr v
   JOIN cvp.relpre r ON v.periodo = r.periodo AND v.producto = r.producto AND v.informante = r.informante AND v.observacion = r.observacion AND v.visita = r.visita
   JOIN cvp.productos f ON v.producto::text = f.producto::text
   JOIN cvp.relvis vi ON v.informante = vi.informante AND v.periodo::text = vi.periodo::text AND v.visita = vi.visita AND r.formulario = vi.formulario
   LEFT JOIN cvp.prodatr pa ON v.producto::text = pa.producto::text AND v.atributo = pa.atributo
   LEFT JOIN cvp.atributos a ON pa.atributo = a.atributo
   LEFT JOIN cvp.tipopre t ON r.tipoprecio = t.tipoprecio
  WHERE espositivo = 'S' AND comun.es_numero(v.valor::text) AND pa.rangohasta IS NOT NULL AND pa.rangodesde IS NOT NULL AND 
CASE
    WHEN comun.es_numero(v.valor::text) THEN (v.valor::double precision > pa.rangohasta OR v.valor::double precision < pa.rangodesde) AND v.valor::double precision <> pa.valornormal
    ELSE false
END 
  ORDER BY v.periodo, vi.panel, vi.tarea, v.producto, v.informante, vi.formulario, v.observacion;

GRANT SELECT ON TABLE control_atributos TO cvp_usuarios;