CREATE OR REPLACE VIEW precios_porcentaje_positivos_y_anulados as
select v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario as formulario, count(*) preciospotenciales,
sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivos, sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END) as anulados,
((sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END)+sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END))*100/count(*))::text||'%' as porcentaje,
sum(a.atributospotenciales) atributospotenciales, sum(a.atributospositivos) atributospositivos, 
CASE WHEN sum(a.atributospotenciales)>0 THEN round((sum(a.atributospositivos)/sum(a.atributospotenciales)*100))::text||'%' ELSE '0%' END as porcatributos 
from cvp.relvis v
  inner join cvp.relpre r on v.periodo = r.periodo and v.informante = r.informante and v.formulario = r.formulario and v.visita = r.visita
  left join cvp.tareas ta on v.tarea = ta.tarea
  left join cvp.formularios f on v.formulario = f.formulario   
  left join cvp.tipopre t on r.tipoprecio = t.tipoprecio,
  lateral (select pro.producto, count(distinct pa.atributo) atributospotenciales, CASE WHEN t.espositivo = 'S' THEN count(distinct pa.atributo) ELSE 0 END as atributospositivos
           from cvp.productos pro left join cvp.prodatr pa on pro.producto = pa.producto
           where r.producto = pro.producto
           group by pro.producto) a
group by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario
order by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario;

GRANT SELECT ON TABLE precios_porcentaje_positivos_y_anulados TO cvp_administrador;
