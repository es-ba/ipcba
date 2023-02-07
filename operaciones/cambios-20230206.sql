set search_path = cvp;
ALTER TABLE calculos_def ALTER COLUMN agrupacionprincipal drop default; 
ALTER TABLE calculos_def ALTER COLUMN para_rellenado_de_base drop default;

CREATE OR REPLACE VIEW caldiv_vw AS 
 SELECT c.periodo, c.calculo, c.producto, p.nombreproducto, c.division, c.prompriimpact, c.prompriimpant,
         CASE
            WHEN c.prompriimpact > 0 AND c.prompriimpant > 0 THEN round((c.prompriimpact / c.prompriimpant * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp, c.promprel, c.promdiv, c0.promdiv AS promdivant, c.promedioredondeado, c.impdiv,
    --cantincluidos y cantrealesincluidos    
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantincluidos END AS cantincluidos, 
    CASE WHEN c.division = '0' and p.tipoexterno = 'D' THEN 1 ELSE c.cantrealesincluidos END AS cantrealesincluidos, 
    c.cantrealesexcluidos, c.promvar, c.cantaltas, 
    c.promaltas, c.cantbajas, c.prombajas, c.cantimputados, c.ponderadordiv, 
    c.umbralpriimp, c.umbraldescarte, c.umbralbajaauto, c.cantidadconprecio, 
    c.profundidad, c.divisionpadre, c.tipo_promedio, c.raiz, c.cantexcluidos, 
    c.promexcluidos, c.promimputados, c.promrealesincluidos, 
    c.promrealesexcluidos, c.cantrealesdescartados, c.cantpreciostotales, 
    c.cantpreciosingresados, c.cantconprecioparacalestac, 
        CASE
            WHEN c.promdiv > 0 AND c0.promdiv > 0 THEN round((c.promdiv / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promSinImpExt,
        CASE
            WHEN c.promSinImpExt > 0 AND c0.promdiv > 0 THEN round((c.promSinImpExt / c0.promdiv * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinImpExt,
    --cs.varSinCambio
        CASE
            WHEN c.promrealessincambio > 0 AND c.promrealessincambioAnt > 0 THEN round((c.promrealessincambio / c.promrealessincambioAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinCambio,
    --cs.varSinAltasBajas
        CASE
            WHEN c.promsinaltasbajas > 0 AND c.promsinaltasbajasAnt > 0 THEN round((c.promsinaltasbajas / c.promsinaltasbajasAnt * 100 - 100)::numeric, 1)
            ELSE NULL::numeric
        END AS varSinAltasBajas,
    CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, r.responsable, p."cluster", c.promImputadosInactivos, c.cantimputadosinactivos,
    CASE WHEN c.division = '0' THEN cg.variacion_indice ELSE NULL END as variacion_indice
   FROM cvp.caldiv c
   LEFT JOIN cvp.productos p on c.producto = p.producto
   LEFT JOIN cvp.calculos l ON c.periodo = l.periodo and c.calculo = l.calculo  
   LEFT JOIN cvp.caldiv c0 ON c0.periodo = l.periodoanterior AND 
       c0.calculo = l.calculoanterior AND --((c.calculo = 0 and c0.calculo = c.calculo) or (c.calculo > 0 and c0.calculo = 0)) AND 
       c.producto = c0.producto AND c.division = c0.division
   LEFT JOIN (SELECT grupo FROM cvp.gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.producto = gg.grupo     
   LEFT JOIN cvp.CalProdResp r on c.periodo = r.periodo and c.calculo = r.calculo and c.producto = r.producto
   LEFT JOIN (SELECT periodo, c.calculo, grupo as producto, variacion as variacion_indice
                FROM calgru c 
                JOIN calculos_def d on c.calculo = d.calculo 
                WHERE c.agrupacion = d.agrupacionprincipal and c.esproducto = 'S'
            ) cg ON c.periodo = cg.periodo AND c.calculo = cg.calculo AND  c.producto = cg.producto;
--------------------------------------------------------------------
CREATE OR REPLACE VIEW hdrexportarcierretemporal AS  ----informantes/hoja de ruta/cierre temporal
SELECT c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, 
  CASE
    WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
    ELSE COALESCE(min(c.razon) || ''::text, ''::text)
  END as razon, c.visita, c.nombreinformante, c.direccion, string_agg(formulario::text||':'||nombreformulario, '|') as formularios, 
  i.contacto::text, 
  c.conjuntomuestral, c.ordenhdr, distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado,
  c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant, c.telcontacto, c.web, c.email
FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.razones z on c.razon = z.razon 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE razon = 1
                GROUP BY informante,visita) a ON c.informante = a.informante AND c.visita = a.visita
   WHERE z.escierretemporalfor = 'S'
   GROUP BY c.periodo, panel, tarea, fechasalida, c.informante, encuestador, nombreencuestador, recepcionista, nombrerecepcionista, c.visita, c.nombreinformante, c.direccion, 
   i.contacto, c.conjuntomuestral, c.ordenhdr, 
   distrito, fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, nombrerubro, maxperiodoinformado,
   c.observaciones, c.observaciones_campo, c.fechasalidahasta, c.modalidad, c.modalidad_ant, c.telcontacto, c.web, c.email;