CREATE OR REPLACE FUNCTION periodo_minimas_variaciones(pcantidad integer)
  RETURNS SETOF cvp.extvar 
  language sql AS
  $BODY$
  SELECT periodo, producto, nombreproducto, string_agg(variacion::text, '|' order by variacion) as variaciones, string_agg(informantes, ';' order by variacion) as informantes
    FROM (SELECT * FROM 
            (SELECT *,ROW_NUMBER() OVER (PARTITION BY r.periodo, r.producto, r.nombreproducto ORDER BY r.variacion) as nro_variacion 
               FROM (SELECT p.periodo, o.producto, nombreproducto, 
                       round((r.precionormalizado / COALESCE(ro.precionormalizado, co.promobs) * 100::double precision - 100::double precision)::numeric, 1) AS variacion,
                       string_agg(r.informante::text||'('||r.observacion||')p:'||v.panel||' t:'||v.tarea, '|' order by r.informante) AS informantes               
                       FROM ( /*SELECT periodo, periodoanterior FROM cvp.periodos WHERE ingresando = 'S'*/
                             SELECT periodo, periodoanterior FROM cvp.periodos ORDER BY periodo DESC LIMIT 12 /* ÚLTIMOS 12 MESES */) p
                       INNER JOIN cvp.relpre r on r.periodo = p.periodo
                       INNER JOIN cvp.relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
                       LEFT JOIN cvp.relpre ro on ro.periodo = p.periodoanterior and r.informante = ro.informante and r.producto = ro.producto and r.observacion = ro.observacion
                         and r.visita = ro.visita 
                       INNER JOIN cvp.productos o on r.producto = o.producto
                       LEFT JOIN cvp.calobs c on r.periodo = c.periodo and c.calculo = 0 and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion
                       LEFT JOIN cvp.calobs co on co.periodo = p.periodoanterior and co.calculo = 0 and co.producto = r.producto and co.informante = r.informante 
                         and co.observacion = r.observacion
                       WHERE r.precionormalizado is not null and c.antiguedadexcluido is null
                       GROUP BY p.periodo, o.producto, nombreproducto, 
                         round((r.precionormalizado / COALESCE(ro.precionormalizado, co.promobs) * 100::double precision - 100::double precision)::numeric, 1)
                    ) R
            ) as Z
            WHERE nro_variacion <= pcantidad
         ) Q
   GROUP BY periodo, producto, nombreproducto
   ORDER BY periodo, producto, nombreproducto
  $BODY$
  ;
