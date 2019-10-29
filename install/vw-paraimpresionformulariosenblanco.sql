CREATE OR REPLACE VIEW ParaImpresionFormulariosEnBlanco AS
  SELECT f.formulario, fo.producto, fo.ordenimpresion as orden, fo.observacion, 
        f.nombreformulario,
        e.tamannonormal, coalesce(p.nombreparaformulario,p.nombreproducto) nombreproducto, 
        substr(fo.producto,2)::varchar(8) AS codigo_producto, p.cantobs, f.soloparatipo, f.despacho,
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
            COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
            ||COALESCE(
                NULLIF(TRIM(
                    COALESCE(trim(e.envase)||' ','')||
                    CASE WHEN e.mostrar_cant_um='N' THEN ''
                    ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '. '
            , '') 
            ||string_agg(
               CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
                  CASE WHEN t.visiblenombreatributo = 'S' THEN a.nombreatributo||' ' ELSE '' END||
                  'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')
                  ||CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN ' ó '||t.valornormal||' '||a.unidaddemedida ELSE '' END||'. '
                ELSE ''
               END,'' ORDER BY t.orden)
            ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '') AS EspecificacionCompleta
            , fo.dependedeldespacho
            , e.destacada 
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
    FROM cvp.formularios f 
      INNER JOIN cvp.forobs fo ON f.formulario=fo.formulario
      INNER JOIN cvp.forprod fp ON fo.formulario = fp.formulario AND fo.producto = fp.producto
      INNER JOIN cvp.especificaciones e ON fo.producto=e.producto AND fo.especificacion=e.especificacion
      INNER JOIN cvp.productos p ON e.producto=p.producto
      LEFT JOIN cvp.prodatr t ON fo.producto = t.producto
      LEFT JOIN cvp.atributos a ON a.atributo = t.atributo
    GROUP BY f.formulario, fo.producto, fo.ordenimpresion, fo.observacion, 
        f.nombreformulario, e.nombreespecificacion, 
        e.tamannonormal, coalesce(p.nombreparaformulario,p.nombreproducto), 
        p.cantobs, f.soloparatipo, f.despacho,
        e.envase, e.cantidad, e.unidaddemedida, e.excluir, fo.dependedeldespacho, e.destacada, e.mostrar_cant_um
    ORDER BY f.formulario, fo.ordenimpresion, fo.observacion;

GRANT SELECT ON TABLE ParaImpresionFormulariosEnBlanco TO cvp_usuarios;