set search_path = cvp;
drop view control_sinvariacion;
CREATE OR REPLACE view control_sinvariacion AS  
SELECT periodo, informante, nombreinformante, tipoinformante, producto, visita, observacion, panel, tarea, 
recepcionista, precionormalizado, SUM(cantprecio) as cantprecios, tipoprecio, comentariosrelpre, formulario, direccion, telcontacto, web
FROM (SELECT p.periodo, p.informante, i.nombreinformante, i.tipoinformante, p.producto, p.visita, p.observacion, 
        v.panel, v.tarea, v.recepcionista, p.precionormalizado, pant.periodo as periodo_ant,
        CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado END AS precioparacontar, 
        CASE WHEN pant.precionormalizado = (CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado end)
                  and pant.periodo <= p.periodo
        THEN 1 ELSE 0 END AS cantprecio, p.tipoprecio, p.comentariosrelpre, p.formulario, i.direccion, i.telcontacto, i.web
      FROM cvp.relpre p
      JOIN (SELECT periodo, cvp.moverperiodos(periodo, -5) as perreferencia
              FROM cvp.periodos 
              WHERE ingresando = 'S' OR periodo = (SELECT MAX(periodo) FROM cvp.periodos WHERE ingresando = 'N')) per ON p.periodo = per.periodo
      JOIN cvp.relpre pant ON p.informante =pant.informante AND p.producto = pant.producto AND p.visita = pant.visita AND p.observacion = pant.observacion
                           AND (p.precionormalizado = pant.precionormalizado OR pant.precionormalizado is null OR
                           (pant.precionormalizado <> p.precionormalizado AND pant.periodo between per.perreferencia AND p.periodo))
      JOIN cvp.relvis v ON p.periodo = v.periodo AND p.informante = v.informante AND p.visita = v.visita AND p.formulario = v.formulario
      JOIN cvp.informantes i ON p.informante = i.informante
      WHERE p.precionormalizado is not null) q 
GROUP BY periodo, informante, nombreinformante, direccion, telcontacto, web, tipoinformante, formulario, producto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre
HAVING MIN(precioparacontar)=MAX(precioparacontar) AND SUM(cantprecio) >= 6
ORDER BY periodo, informante, nombreinformante, direccion, telcontacto, web, tipoinformante, formulario, producto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre;

GRANT SELECT ON TABLE control_sinvariacion TO cvp_administrador;
GRANT SELECT ON TABLE control_sinvariacion TO cvp_recepcionista;
