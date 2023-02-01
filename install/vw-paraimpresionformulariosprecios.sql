CREATE OR REPLACE VIEW ParaImpresionFormulariosPrecios AS 
 SELECT v.periodo, v.panel, v.tarea, i.direccion, i.ordenhdr, v.informante, v.formulario, f.nombreformulario, v.fechasalida, v.razon, 
        v.fechageneracion, v.visita, v.ultimavisita, fo.producto, fo.ordenimpresion as orden, 
        coalesce(d.nombreparaformulario,d.nombreproducto) nombreproducto, fo.observacion, p.precio, p.tipoprecio, e.nombreespecificacion, 
        substr(fo.producto, 2) AS codigo_producto, i.tipoinformante, NULLIF(v.razon, 1) AS razonimpresa, f.orden as ordenFormulario,  
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
        COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
        ||COALESCE(
            NULLIF(TRIM(
                COALESCE(trim(e.envase)||' ','')||
                CASE WHEN e.mostrar_cant_um='N' THEN ''
                     ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') 
                     END),'')|| '. '
        , '') 
        ||string_agg(
           CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
              CASE WHEN t.visiblenombreatributo = 'S' THEN 
                   concat(a.separador,a.nombreatributo)||' ' 
                   ELSE '' 
                   END||'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')||
              CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN 
                   ' ó '||t.valornormal||' '||a.unidaddemedida 
                   ELSE '' 
                   END||
              CASE WHEN t.otraunidaddemedida IS NOT NULL THEN
                   '/'||t.otraunidaddemedida||'.'
                   ELSE ''
                   END||' '
              ELSE ''
              END,'' ORDER BY t.orden)
        ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '') AS EspecificacionCompleta,
        CASE WHEN prP.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaP,
        CASE WHEN prPmas1.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas1,
        CASE WHEN prPmas2.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas2,
        CASE WHEN prPmas3.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas3,
        e.destacada,
        rub.rubro
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
   FROM cvp.relvis v
      JOIN cvp.periodos per ON per.periodo=v.periodo
      JOIN cvp.formularios f ON v.formulario = f.formulario
      JOIN cvp.informantes i ON v.informante = i.informante
      JOIN cvp.rubros rub ON rub.rubro=i.rubro
      JOIN cvp.forobsinf fo ON fo.formulario=v.formulario and fo.informante = i.informante
      JOIN cvp.productos d ON fo.producto = d.producto
      JOIN cvp.especificaciones e ON fo.producto = e.producto AND fo.especificacion = e.especificacion
      LEFT JOIN cvp.relpre p
       ON 1=p.visita 
        AND per.periodoanterior = p.periodo
        AND v.informante = p.informante 
        AND fo.producto = p.producto
        AND fo.observacion = p.observacion
      LEFT JOIN cvp.prodatr t ON fo.producto = t.producto 
      LEFT JOIN cvp.atributos a ON a.atributo = t.atributo
      LEFT JOIN cvp.prerep prP ON per.periodo = prP.periodo 
        AND d.producto = prP.producto 
        AND i.informante = prP.informante
      LEFT JOIN cvp.prerep prPmas1 ON cvp.MoverPeriodos(per.periodo,1) = prPmas1.periodo 
        AND d.producto = prPmas1.producto 
        AND i.informante = prPmas1.informante
      LEFT JOIN cvp.prerep prPmas2 ON cvp.MoverPeriodos(per.periodo,2) = prPmas2.periodo 
        AND d.producto = prPmas2.producto 
        AND i.informante = prPmas2.informante
      LEFT JOIN cvp.prerep prPmas3 ON cvp.MoverPeriodos(per.periodo,3) = prPmas3.periodo 
        AND d.producto = prPmas3.producto 
        AND i.informante = prPmas3.informante
      WHERE (fo.dependedeldespacho = 'N' or rub.despacho = 'A' OR fo.observacion = 1)
  GROUP BY v.periodo, v.panel, v.tarea, i.direccion, i.ordenhdr, v.informante, v.formulario, f.nombreformulario, v.fechasalida, v.razon, 
        v.fechageneracion, v.visita, v.ultimavisita, fo.producto, fo.ordenimpresion, coalesce(d.nombreparaformulario,d.nombreproducto), fo.observacion, p.precio, p.tipoprecio, 
        e.nombreespecificacion, i.tipoinformante, e.envase, e.excluir, e.cantidad, e.unidaddemedida, prP.periodo
        , prPmas1.periodo, prPmas2.periodo, prPmas3.periodo, f.orden, e.destacada, rub.rubro, e.mostrar_cant_um
  ORDER BY v.periodo, v.panel, v.tarea, i.ordenhdr, i.direccion, v.informante, f.orden, fo.ordenimpresion, fo.observacion;

GRANT SELECT ON TABLE ParaImpresionFormulariosPrecios TO cvp_usuarios;