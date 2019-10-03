DROP view IF EXISTS cvp.control_sinvariacion;

CREATE OR REPLACE view cvp.control_sinvariacion AS
SELECT r.periodo, r.informante, i.nombreinformante, i.tipoinformante, r.producto, t.nombreproducto, r.visita, r.observacion, v.panel, v.tarea, v.recepcionista,
       r.precionormalizado, cantprecios
FROM cvp.relpre r
JOIN (select p.* from cvp.periodos p left join cvp.periodos p_sig on p_sig.periodoanterior = p.periodo where p.ingresando = 'S' or p_sig.ingresando='S') p on r.periodo = p.periodo
LEFT JOIN cvp.relvis v on
	r.periodo = v.periodo and
	r.informante = v.informante and
	r.formulario = v.formulario and
	r.visita = v.visita
LEFT JOIN cvp.relpre r_1 on
	r_1.periodo = cvp.moverperiodos(r.periodo, -1) and
	r.informante = r_1.informante and
	r.visita = r_1.visita and
	r.observacion = r_1.observacion and
	r.producto = r_1.producto
LEFT JOIN cvp.relpre r_2 on
	r_2.periodo = cvp.moverperiodos(r.periodo, -2) and
	r.informante = r_2.informante and
	r.visita = r_2.visita and
	r.observacion = r_2.observacion and
	r.producto = r_2.producto
LEFT JOIN cvp.relpre r_3 on
	r_3.periodo = cvp.moverperiodos(r.periodo, -3) and
	r.informante = r_3.informante and
	r.visita = r_3.visita and
	r.observacion = r_3.observacion and
	r.producto = r_3.producto
LEFT JOIN cvp.relpre r_4 on
	r_4.periodo = cvp.moverperiodos(r.periodo, -4) and
	r.informante = r_4.informante and
	r.visita = r_4.visita and
	r.observacion = r_4.observacion and
	r.producto = r_4.producto
LEFT JOIN cvp.relpre r_5 on
	r_5.periodo = cvp.moverperiodos(r.periodo, -5) and
	r.informante = r_5.informante and
	r.visita = r_5.visita and
	r.observacion = r_5.observacion and
	r.producto = r_5.producto
LEFT JOIN cvp.informantes i on r.informante = i.informante
LEFT JOIN cvp.productos t on r.producto = t.producto,
LATERAL (SELECT COUNT(*) cantprecios FROM cvp.relpre
          WHERE	informante = r.informante and
			producto = r.producto and
			visita = r.visita and
			observacion = r.observacion and
			precionormalizado = r.precionormalizado) pre
WHERE 	r.precionormalizado > 0 and
	r_1.precionormalizado > 0 and
	r_2.precionormalizado > 0 and
	r_3.precionormalizado > 0 and
	r_4.precionormalizado > 0 and
	r_5.precionormalizado > 0 and
	r.precionormalizado = r_1.precionormalizado and
	r_1.precionormalizado = r_2.precionormalizado and
	r_2.precionormalizado = r_3.precionormalizado and
	r_3.precionormalizado = r_4.precionormalizado and
	r_4.precionormalizado = r_5.precionormalizado;

ALTER TABLE cvp.control_sinvariacion
  OWNER TO cvpowner;
GRANT ALL ON TABLE cvp.control_sinvariacion TO cvpowner;
GRANT SELECT ON TABLE cvp.control_sinvariacion TO cvp_administrador;