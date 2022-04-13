CREATE OR REPLACE VIEW control_rangos as
select periodo, producto, nombreproducto, informante, tipoinformante, observacion, visita, panel, tarea, encuestador, recepcionista, nombrerecep, 
   formulario, precionormalizado, comentariosrelpre, observaciones, tipoprecio, cambio, impobs, precioant, tipoprecioant, antiguedadsinprecioant, 
   variac, promvar, desvvar, promrotativo, desvprot, razon_impobs_ant, repregunta
   from (select v.periodo,
           v.producto,
           p.nombreproducto,
           v.informante,
           i.tipoinformante,
           v.observacion,
           v.visita,
           vi.panel,
           vi.tarea,
           (vi.encuestador || ':') || pe.apellido AS encuestador,
           vi.recepcionista,
           pc.apellido AS nombrerecep,
           v.formulario,
           v.precionormalizado,
           v.comentariosrelpre,
           v.observaciones,
           v.tipoprecio,
           v.cambio,
           c2.impobs,
           COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
           v.tipoprecio_1 AS tipoprecioant,
           co.antiguedadsinprecio AS antiguedadsinprecioant,
           v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100 AS variac,
           avg   (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as promvar,
           stddev(v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as desvvar,
           avgprot.promrotativo,
           avgprot.desvprot,
           (vi2.razon::text || ':'::text) || COALESCE(co.impobs, ' '::character varying)::text AS razon_impobs_ant,
           CASE WHEN pr.periodo IS NOT NULL THEN 'R'
           ELSE NULL
           END AS repregunta,
           tamannodesvvar,
           tamannodesvpre
           FROM cvp.relpre_1 v
           LEFT JOIN (select c_0.* from cvp.calobs c_0 JOIN calculos_def cd on c_0.calculo = cd.calculo where cd.principal) co ON co.periodo = v.periodo_1 AND co.producto = v.producto AND co.informante = v.informante AND co.observacion = v.observacion
                JOIN cvp.productos p on v.producto = p.producto
                JOIN cvp.informantes i on v.informante = i.informante
                JOIN cvp.relvis vi on v.periodo = vi.periodo and v.informante = vi.informante and v.visita = vi.visita and v.formulario = vi.formulario 
                LEFT JOIN cvp.personal pe on vi.encuestador = pe.persona
                LEFT JOIN cvp.personal pc on vi.recepcionista = pc.persona
                LEFT JOIN (select c_2.* from cvp.calobs c_2 JOIN calculos_def cd on c_2.calculo = cd.calculo where cd.principal) c2 ON c2.periodo::text = v.periodo::text AND c2.producto::text = v.producto::text AND c2.informante = v.informante AND c2.observacion = v.observacion
                JOIN cvp.panel_promrotativo avgprot ON v.periodo = avgprot.periodo AND v.producto = avgprot.producto
                JOIN cvp.parametros ON parametros.unicoregistro = true
                LEFT JOIN cvp.prerep pr ON v.periodo = pr.periodo AND v.informante = pr.informante AND v.producto = pr.producto
                LEFT JOIN cvp.relvis vi2 ON v.informante = vi2.informante AND v.periodo_1 = vi2.periodo AND v.visita = vi2.visita AND v.formulario = vi2.formulario
        ) Q
WHERE ((precionormalizado / precioant * 100 - 100) > (promvar + tamannodesvvar * desvvar) OR 
       (precionormalizado / precioant * 100 - 100) IS DISTINCT FROM 0 AND 
       (precionormalizado / precioant * 100 - 100) < (promvar - tamannodesvvar * desvvar) OR 
       precionormalizado > (promrotativo + tamannodesvpre * desvprot) OR 
       precionormalizado < (promrotativo - tamannodesvpre * desvprot)
      );

GRANT SELECT ON TABLE cvp.control_rangos TO cvp_usuarios;
