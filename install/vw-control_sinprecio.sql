CREATE OR REPLACE view control_sinprecio AS  
SELECT p.periodo, p.informante, i.nombreinformante, i.tipoinformante, p.producto, o.nombreproducto, p.visita, p.observacion, v.panel, v.tarea, v.recepcionista
  FROM cvp.relpre p
   JOIN cvp.relpre p0 on p0.periodo = cvp.moverperiodos(p.periodo, -1) and p.informante = p0.informante and p.visita = p0.visita 
            and p.observacion = p0.observacion and p.producto = p0.producto and (p0.tipoprecio = 'S' or p0.tipoprecio is null)
   JOIN cvp.relpre p1 on p1.periodo = cvp.moverperiodos(p.periodo, -2) and p.informante = p1.informante and p.visita = p1.visita 
            and p.observacion = p1.observacion and p.producto = p1.producto and (p1.tipoprecio = 'S' or p1.tipoprecio is null)
   JOIN cvp.relpre p2 on p2.periodo = cvp.moverperiodos(p.periodo, -3) and p.informante = p2.informante and p.visita = p2.visita 
            and p.observacion = p2.observacion and p.producto = p2.producto and (p2.tipoprecio = 'S' or p2.tipoprecio is null)
   LEFT JOIN cvp.relvis v on p.periodo = v.periodo and p.informante = v.informante and p.visita = v.visita and p.formulario = v.formulario
   LEFT JOIN cvp.informantes i on p.informante = i.informante
   LEFT JOIN cvp.productos o on p.producto = o.producto
WHERE p.tipoprecio = 'S';                                 

GRANT SELECT ON TABLE control_sinprecio TO cvp_recepcionista;  