create or replace view control_relev_telef as
  select periodo, r.panel, r.tarea, r.informante, nombreinformante, 
    coalesce(nombrecalle||' '||altura||' '||piso||' '||departamento, direccion) as direccion,
    visita, r.encuestador||':'||p.nombre||' '||p.apellido as encuestador, i.rubro, nombrerubro, 
    string_agg(r.formulario::text||':'||nombreformulario,'; ') as formularios
    from cvp.relvis r 
      left join cvp.formularios f on r.formulario = f.formulario
      left join cvp.personal p on r.encuestador = p.persona
      left join cvp.informantes i on r.informante = i.informante
      left join cvp.rubros u on i.rubro = u.rubro
    where u.telefonico = 'S'  
    group by 1,2,3,4,5,6,7,8,9,10
    order by periodo, panel, tarea, informante;

GRANT SELECT ON TABLE control_relev_telef TO cvp_usuarios;

