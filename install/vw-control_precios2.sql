CREATE OR REPLACE VIEW control_precios2 AS
 SELECT x.periodo,
    x.producto,
    p.nombreproducto,
    rp.observacion,
    rp.informante,
    rp.formulario,
        CASE
            WHEN rp.precio = x.precio_min THEN 'precio min'::text
            WHEN rp.precio = x.precio_max THEN 'PRECIO MAX'::text
            ELSE ''::text
        END AS categoria,
    rp.precio,
    rp.tipoprecio
   FROM ( SELECT pr.periodo,
            pr.producto,
            max(pr.precio) AS precio_max,
            min(pr.precio) AS precio_min
           FROM cvp.relpre pr
          WHERE pr.precio > 0::double precision
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre rp,
    cvp.productos p
  WHERE rp.periodo::text = x.periodo::text AND rp.producto::text = x.producto::text AND (rp.precio = x.precio_min OR rp.precio = x.precio_max) AND p.producto::text = x.producto::text
  ORDER BY x.periodo, x.producto, rp.observacion, rp.precio;

