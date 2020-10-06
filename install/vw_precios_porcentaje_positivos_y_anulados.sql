CREATE OR REPLACE VIEW precios_porcentaje_positivos_y_anulados as
select v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario as formulario, count(*) preciospotenciales,
sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivos, sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END) as anulados,
((sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END)+sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END))*100/count(*))::text||'%' as porcentaje,
sum(a.atributospotenciales) atributospotenciales, sum(a.atributospositivos) atributospositivos, 
CASE WHEN sum(a.atributospotenciales)>0 THEN round((sum(a.atributospositivos)/sum(a.atributospotenciales)*100))::text||'%' ELSE '0%' END as porcatributos, 
i.rubro||':'||u.nombrerubro as rubro, v.encuestador, per.nombre||' '||per.apellido as encuestadornombre, coalesce(par.solo_cluster,pp."cluster") as "cluster"
from cvp.relvis v
  inner join cvp.relpre r on v.periodo = r.periodo and v.informante = r.informante and v.formulario = r.formulario and v.visita = r.visita
  inner join cvp.productos pp on r.producto = pp.producto
  inner join cvp.parametros par on unicoregistro
  left join cvp.personal per on v.encuestador = per.persona
  left join cvp.tareas ta on v.tarea = ta.tarea
  left join cvp.formularios f on v.formulario = f.formulario   
  left join cvp.tipopre t on r.tipoprecio = t.tipoprecio
  left join cvp.informantes i on v.informante = i.informante
  left join cvp.rubros u on i.rubro = u.rubro,
  lateral (select pro.producto, count(distinct pa.atributo) atributospotenciales, CASE WHEN t.espositivo = 'S' THEN count(distinct pa.atributo) ELSE 0 END as atributospositivos
           from cvp.productos pro left join cvp.prodatr pa on pro.producto = pa.producto
           where r.producto = pro.producto
           group by pro.producto) a
group by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario, i.rubro||':'||u.nombrerubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(par.solo_cluster,pp."cluster")
order by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario, i.rubro||':'||u.nombrerubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(par.solo_cluster,pp."cluster");

GRANT SELECT ON TABLE precios_porcentaje_positivos_y_anulados TO cvp_administrador;
