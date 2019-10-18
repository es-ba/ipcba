CREATE OR REPLACE VIEW control_tipoprecio as
SELECT p.periodo, p.producto, nombreproducto, i.tipoinformante, i.rubro, nombrerubro, p.tipoprecio, t.nombretipoprecio, count(*)::integer cantidad
FROM (SELECT x.* FROM cvp.perfiltro p left join cvp.relvis x on p.periodo = x.periodo WHERE razon = 1) v 
  LEFT JOIN cvp.relpre p on v.periodo = p.periodo and v.informante = p.informante and v.formulario = p.formulario and v.visita = p.visita
  LEFT JOIN cvp.informantes i on v.informante = i.informante
  LEFT JOIN cvp.rubros r on i.rubro = r.rubro
  LEFT JOIN cvp.productos o on p.producto = o.producto
  LEFT JOIN cvp.tipopre t on p.tipoprecio = t.tipoprecio  
  WHERE v.razon = 1
  GROUP BY p.periodo, p.producto, nombreproducto, i.tipoinformante, i.rubro, nombrerubro, p.tipoprecio, t.nombretipoprecio
  ORDER BY p.periodo, p.producto, i.tipoinformante, i.rubro, p.tipoprecio;

GRANT SELECT ON TABLE control_tipoprecio TO cvp_administrador;