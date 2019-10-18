CREATE OR REPLACE VIEW control_anulados_recep as
SELECT r.periodo, r.producto, nombreproducto, r.informante, r.observacion, r.visita,v.panel, v.tarea, v.encuestador||':'||e.apellido as encuestador, v.recepcionista, v.formulario, r.comentariosrelpre
FROM cvp.relpre r 
LEFT JOIN cvp.productos p on r.producto = p.producto
LEFT JOIN cvp.relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
LEFT JOIN cvp.personal e on v.encuestador = e.persona
WHERE tipoprecio = 'A';

GRANT SELECT ON TABLE control_anulados_recep TO cvp_administrador;
