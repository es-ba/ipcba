CREATE OR REPLACE VIEW ParaImpresionFormulariosAtributos AS 
  SELECT v.periodo, v.panel, v.tarea, v.informante, v.formulario, f.nombreformulario, v.fechasalida,
        v.razon, v.fechageneracion, v.visita, v.ultimavisita, fo.producto, coalesce(d.nombreparaformulario,d.nombreproducto) nombreproducto, fo.observacion,
        p.precio, p.tipoprecio, t.atributo, a.nombreatributo, ra.valor, t.orden
   FROM cvp.relvis v
      JOIN cvp.periodos per ON per.periodo=v.periodo
      JOIN cvp.formularios f ON v.formulario = f.formulario
      JOIN cvp.informantes i ON v.informante = i.informante
      JOIN cvp.rubros rub ON rub.rubro=i.rubro
      JOIN cvp.forobsinf fo ON fo.formulario=v.formulario and i.informante = fo.informante
      JOIN cvp.productos d ON fo.producto = d.producto
      JOIN cvp.especificaciones e ON fo.producto = e.producto AND fo.especificacion = e.especificacion
      LEFT JOIN cvp.relpre p
       ON 1=p.visita 
         AND per.periodoanterior = p.periodo -- debería decir AND v.periodo_1 = p.periodo
         AND v.informante = p.informante 
         AND fo.producto = p.producto
         AND fo.observacion = p.observacion
       LEFT JOIN cvp.prodatr t ON fo.producto = t.producto 
       LEFT JOIN cvp.atributos a ON a.atributo = t.atributo
       LEFT JOIN cvp.relatr ra
         ON p.periodo = ra.periodo AND p.producto = ra.producto AND p.observacion = ra.observacion 
           AND p.informante = ra.informante AND p.visita = ra.visita AND t.atributo=ra.atributo
       WHERE (fo.dependedeldespacho = 'N' or rub.despacho = 'A' OR fo.observacion = 1)
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario, fo.producto, fo.observacion, t.orden;
 
GRANT SELECT ON TABLE ParaImpresionFormulariosAtributos TO cvp_usuarios;
