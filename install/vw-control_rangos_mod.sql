CREATE OR REPLACE VIEW control_rangos_mod AS 
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    v.informante,
    i.tipoinformante,
    v.observacion,
    v.visita,
    vi.panel,
    vi.tarea,
    v.precionormalizado,
    v.tipoprecio,
    v.cambio,
    c2.impobs,
    COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
    sum(v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    co.impobs AS impobs_1
   FROM cvp.relpre_1 v
     JOIN cvp.productos f ON v.producto::text = f.producto::text
     JOIN cvp.relvis vi ON v.informante = vi.informante AND v.periodo::text = vi.periodo::text AND v.visita = vi.visita AND v.formulario = vi.formulario
     LEFT JOIN (select c_0.* from cvp.calobs c_0 JOIN calculos_def cd on c_0.calculo = cd.calculo where cd.principal) co ON co.periodo::text = v.periodo_1::text AND co.producto::text = v.producto::text AND co.informante = v.informante AND co.observacion = v.observacion
     LEFT JOIN (select c_2.* from cvp.calobs c_2 JOIN calculos_def cd on c_2.calculo = cd.calculo where cd.principal) c2 ON c2.periodo::text = v.periodo::text AND c2.producto::text = v.producto::text AND c2.informante = v.informante AND c2.observacion = v.observacion
     JOIN ( SELECT avg(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100::double precision - 100::double precision) AS promvar,
            stddev(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100::double precision - 100::double precision) AS desvvar,
            va2.periodo,
            va2.producto
           FROM cvp.relpre_1 va2
             LEFT JOIN (select co_2.* from cvp.calobs co_2 JOIN calculos_def cd on co_2.calculo = cd.calculo where cd.principal) co2 ON co2.periodo::text = va2.periodo_1::text AND co2.producto::text = va2.producto::text AND co2.informante = va2.informante AND co2.observacion = va2.observacion
          GROUP BY va2.periodo, va2.producto) avgvar ON v.periodo::text = avgvar.periodo::text AND v.producto::text = avgvar.producto::text
     JOIN cvp.panel_promrotativo_mod avgprot ON v.periodo::text = avgprot.periodo::text AND v.producto::text = avgprot.producto::text
     JOIN cvp.parametros ON parametros.unicoregistro = true
     JOIN cvp.informantes i ON v.informante = i.informante
  WHERE (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) > (avgvar.promvar + parametros.tamannodesvvar * avgvar.desvvar) OR (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) IS DISTINCT FROM 0::double precision AND (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100::double precision - 100::double precision) < (avgvar.promvar - parametros.tamannodesvvar * avgvar.desvvar) OR v.precionormalizado > (avgprot.promrotativo + parametros.tamannodesvpre * avgprot.desvprot) OR v.precionormalizado < (avgprot.promrotativo - parametros.tamannodesvpre * avgprot.desvprot)
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, vi.tarea, v.precionormalizado, v.tipoprecio, v.cambio, c2.impobs, v.precionormalizado_1, co.promobs, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, avgprot.desvprot, co.impobs
  ORDER BY v.periodo, v.producto, vi.panel, vi.tarea, v.informante;

GRANT SELECT ON TABLE control_rangos_mod TO cvp_usuarios;
GRANT SELECT ON TABLE control_rangos_mod TO cvp_recepcionista;
