--No usado      presentes en informantes pero no en relvis
--Nuevos        incorporados a relvis en el último periodo abierto, aún sin razon
--Inactivo      con razon escierredefinitivoinf para todos sus formularios, en algún momento en el pasado y no vuelto a incorporar posteriormente
--Activo        con razon escierredefinitivoinf = 'N' para por lo menos uno de sus formularios en el último periodo ingresado
--Discontinuado con con razon escierredefinitivoinf = 'N' para por lo menos uno de sus formularios, pero con desaparición posterior (no sigue las reglas de generación)

DROP VIEW IF EXISTS informantes_estado;

CREATE OR REPLACE view informantes_estado as
select p.ultimoperiodoingresando, pp.periodoanterior, i.informante, 
coalesce(r.periodo, periodo_ant) as periodo,
coalesce(r.informante, informante_ant) as informante_ultimo,
coalesce(cierre, cierre_ant) as cierre,
coalesce(cantform, cantform_ant) as cantform, 
rnulas, rnulas_ant, cantform_inac, periodo_inac, mp.periodo_perdido,
case when coalesce(cierre, cierre_ant) = 'S' or coalesce(cierre, cierre_ant) is null and ii.informante is not null then 'Inactivo'
     when coalesce(cierre, cierre_ant) = 'N' then 'Activo'
     when coalesce(r.informante, informante_ant) is null and ii.informante is null and mp.periodo_perdido is null then 'No usado'
     when coalesce(r.informante, informante_ant) is null and ii.informante is null and mp.periodo_perdido is not null then 'Discontinuado'
     when rnulas > 0 or rnulas_ant > 0 then 'Nuevo'
end as estado
--r.*, ra.* 
from informantes i
cross join (select max(periodo) as ultimoperiodoingresando from periodos) p
join periodos pp on p.ultimoperiodoingresando = pp.periodo
left join (select periodo, informante, 
           min(escierredefinitivoinf) as cierre, 
           count(distinct formulario) as cantform,
           sum (case when v.razon is null then 1 else 0 end) as rnulas
           from relvis v left join razones z on v.razon = z.razon
           where ultima_visita
           group by periodo, informante) r on r.informante = i.informante and r.periodo = p.ultimoperiodoingresando
left join (select periodo periodo_ant, informante informante_ant, 
           min(escierredefinitivoinf) as cierre_ant, 
           count(distinct formulario)as cantform_ant,
           sum (case when v.razon is null then 1 else 0 end) as rnulas_ant
           from relvis v left join razones z on v.razon = z.razon
           where ultima_visita
           group by periodo, informante) ra on ra.informante_ant = i.informante and ra.periodo_ant = pp.periodoanterior
left join (select informante, count(distinct formulario) cantform_inac, max(periodonegativo) periodo_inac
           from informantes_inactivos 
           group by informante) ii on i.informante = ii.informante
left join (select informante, max(periodo) periodo_perdido
           from relvis 
           group by informante) mp on i.informante = mp.informante
order by i.informante; 

GRANT SELECT ON TABLE informantes_estado TO cvp_administrador;