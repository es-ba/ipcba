CREATE OR REPLACE VIEW forobsinf AS 
 SELECT fi.informante, fp.formulario, fp.producto, 
    generate_series.generate_series AS observacion, 1 AS especificacion, fp.orden, fp.ordenimpresion, 
        CASE
            WHEN p.cantobs IS NULL THEN 'S'::text
            ELSE 'N'::text
        END AS dependedeldespacho
   FROM cvp.forinf fi, cvp.forprod fp, cvp.productos p,generate_series(1, 100) generate_series(generate_series)
  WHERE fi.formulario = fp.formulario and fp.producto = p.producto AND generate_series.generate_series <= COALESCE(fi.cantobs,COALESCE(p.cantobs, 2));

GRANT SELECT ON TABLE forobsinf TO cvp_usuarios;
