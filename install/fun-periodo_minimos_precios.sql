CREATE OR REPLACE FUNCTION periodo_minimos_precios(pcantidad integer)
  RETURNS SETOF cvp.extpre 
  language sql AS
  $BODY$
  SELECT periodo, producto, nombreproducto, 
         string_agg(precionormalizado::text||marca, '|' order by precionormalizado) as precios, string_agg(informantes, ';' order by precionormalizado) as informantes
    FROM (SELECT * FROM 
            (SELECT *,ROW_NUMBER() OVER (PARTITION BY r.periodo, r.producto, r.nombreproducto /*, r.marca*/ ORDER BY r.precionormalizado) as nro_precio 
               FROM (SELECT p.periodo, e.producto, nombreproducto, CASE WHEN o.controlar_precios_sin_normalizar THEN precio ELSE round(precionormalizado::decimal,2) END as precionormalizado, 
                       CASE WHEN antiguedadexcluido is NOT NULL THEN 'X' ELSE '' END as marca,
                       string_agg(e.informante::text||'('||e.observacion||')'||'('||e.tipoprecio||')p:'||v.panel||' t:'||v.tarea, '|' order by e.informante) AS informantes 
                       FROM (SELECT periodo FROM cvp.periodos ORDER BY periodo DESC LIMIT 12
                             /* ÚLTIMOS 12 MESES */) p
                       INNER JOIN cvp.relpre e on p.periodo = e.periodo
                       INNER JOIN cvp.relvis v on e.periodo = v.periodo and e.informante = v.informante and e.visita = v.visita and e.formulario = v.formulario
                       INNER JOIN cvp.productos o on e.producto = o.producto
                       LEFT JOIN cvp.calculos a on e.periodo = a.periodo and a.calculo = 0
                       LEFT JOIN cvp.calobs c on e.periodo = c.periodo and c.calculo = 0 and e.producto = c.producto and e.informante = c.informante and e.observacion = c.observacion
                       --LEFT JOIN (SELECT producto, MAX(atributo) atributo FROM cvp.prodatr WHERE tiponormalizacion = 'Normal' and rangodesde=rangohasta GROUP BY producto) pa 
                       --on e.producto = pa.producto 
                       WHERE e.precionormalizado is not null and not(c.division is null AND e.modi_fec < a.fechacalculo)
                       GROUP BY p.periodo, e.producto, nombreproducto, precionormalizado, CASE WHEN antiguedadexcluido is NOT NULL THEN 'X' ELSE '' END, precio, o.controlar_precios_sin_normalizar
                    ) R
            ) as Z
            WHERE nro_precio <= pcantidad
         ) Q
   GROUP BY periodo, producto, nombreproducto
   ORDER BY periodo, producto, nombreproducto
  $BODY$
  ;
