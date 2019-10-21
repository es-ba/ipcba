CREATE OR REPLACE VIEW control_precios AS
 SELECT x.periodo,
    x.producto,
    p.nombreproducto,
    x.precio_min,
    p_min.observacion AS observacion_min,
    p_min.informante AS informante_min,
    p_min.formulario AS formulario_min,
    x.precio_max,
    p_max.observacion AS observacion_max,
    p_max.informante AS informante_max,
    p_max.formulario AS formulario_max
   FROM ( SELECT pr.periodo,
            pr.producto,
            max(pr.precio) AS precio_max,
            min(pr.precio) AS precio_min
           FROM cvp.relpre pr
          WHERE pr.precio > 0::double precision
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre p_min,
    cvp.relpre p_max,
    cvp.productos p
  WHERE p_min.periodo::text = x.periodo::text AND p_min.producto::text = x.producto::text AND p_min.precio = x.precio_min AND p_max.periodo::text = x.periodo::text AND p_max.producto::text = x.producto::text AND p_max.precio = x.precio_max AND p.producto::text = x.producto::text;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE control_precios TO cvp_administrador;