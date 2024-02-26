import * as sqlTools from 'sql-tools';

export const getSqlPlanificacion= (params:{encuestador?:string,periodo?:string,usuario:string,url_plan:string})=>`(SELECT periodo, fechasalida, panel, tarea, encuestador_titular, titular, encuestador, suplente, fechasalidadesde, fechasalidahasta, 
    modalidad, string_agg(compartido, chr(10)) compartido, string_agg(submodalidad_informantes, ';') submodalidad, string_agg(direcciones, chr(10)) direcciones, consulta, visible,
    minfechaplanificada, maxfechaplanificada, concat(${sqlTools.quoteLiteral(params.url_plan)},
    '/planificacion'||'?encuestador='||encuestador) as url_plan,
    sobrecargado, supervisor, observaciones, puedevertodos
   FROM (SELECT t.periodo, p.fechasalida, t.panel, t.tarea, a.encuestador encuestador_titular, r.nombre||' '||r.apellido as titular, t.encuestador, 
         case when t.encuestador=a.encuestador then null else nullif(concat_ws(' ', e.nombre, e.apellido),'') end as suplente,
         coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) fechasalidadesde,
         coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida) fechasalidahasta,t.modalidad, 
         CASE WHEN l.persona is not null THEN 'No disponible' ELSE 'Disponible' END AS consulta,   
         i.tipoinformante||':'||count(distinct i.informante) as submodalidad_informantes,
         string_agg(distinct (CASE WHEN modalidad LIKE '%PRESENCIAL%' THEN direccion ELSE NULL END),chr(10)) direcciones,
         string_agg(distinct i.direccion||': '||chr(10)||o.compartido,' ') compartido, fv.visible_planificacion visible, f.minfechaplanificada, f.maxfechaplanificada,
         nullif(nullif((select count(*) 
         from reltar x join relpan y using(periodo,panel) 
         where x.periodo=t.periodo and ( 
         coalesce(x.fechasalidadesde, y.fechasalidadesde, y.fechasalida)=coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) 
         or 
         coalesce(x.fechasalidahasta, y.fechasalidahasta, y.fechasalida)=coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida)
         )
         and x.encuestador=t.encuestador),1),0) as sobrecargado,
         t.supervisor, t.observaciones, t.encuestador is distinct from per.persona puedevertodos
           FROM 
           (select * from personal per where per.username = ${sqlTools.quoteLiteral(params.usuario)}) per
           JOIN reltar t on t.encuestador = per.persona or per.labor not in ('E','S') --pk:periodo, panel, tarea
           JOIN tareas a on t.tarea = a.tarea --pk: tarea, pk verificada
           JOIN personal e on t.encuestador = e.persona --pk: persona, pk verificada, encuestador suplente
           JOIN personal r on a.encuestador = r.persona --pk: persona, pk verificada, encuestador titular
           JOIN relpan p using (periodo,panel) --pk: periodo, panel, pk verificada
           JOIN relvis v on t.periodo= v.periodo and t.panel= v.panel and t.tarea = v.tarea --pk:periodo,informante,visita,formulario, pk verificada
           JOIN informantes i using(informante) --pk:informante, pk verificada
           LEFT JOIN 
            (SELECT periodo, informante, visita, string_agg (distinct 'Panel '||panel||' , '||'Tarea '||tarea, chr(10) order by 'Panel '||panel||' , '||'Tarea '||tarea) compartido
              FROM relvis
              GROUP BY periodo, informante, visita
              HAVING COUNT(distinct 'Panel '||panel||' , '||'Tarea '||tarea) > 1) o 
           ON v.periodo = o.periodo and v.informante = o.informante and v.visita = o.visita
           LEFT JOIN
             (SELECT persona, fechadesde, fechahasta, motivo, concat('a', date_part('year', fechadesde), 'm', 
                case when date_part('month', fechadesde) < 10 THEN '0' END, date_part('month', fechadesde)) periododesde,
                concat('a', date_part('year', fechahasta), 'm', 
                case when date_part('month', fechahasta) < 10 THEN '0' END, date_part('month', fechahasta)) periodohasta
                FROM licencias) l
           ON l.persona = t.encuestador and (t.periodo = l.periododesde OR t.periodo = l.periodohasta) and p.fechasalida between l.fechadesde and l.fechahasta
           LEFT JOIN fechas fv ON coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) = fv.fecha 
           JOIN (SELECT MIN(fecha) minfechaplanificada, MAX(fecha) maxfechaplanificada 
                        FROM fechas
                        WHERE seleccionada_planificacion = 'S') f ON coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) between minfechaplanificada and maxfechaplanificada
          WHERE CASE WHEN t.encuestador = per.persona THEN fv.visible_planificacion = 'S' ELSE true END and a.operativo = 'C'
       GROUP BY 
       t.periodo, p.fechasalida, t.panel, t.tarea, a.encuestador, r.nombre||' '||r.apellido, t.encuestador, 
       case when t.encuestador=a.encuestador then null else nullif(concat_ws(' ', e.nombre, e.apellido),'') end,
       coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida),
       coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida),i.tipoinformante,
       t.modalidad, CASE WHEN l.persona is not null THEN 'No disponible' ELSE 'Disponible' END, fv.visible_planificacion,
       f.minfechaplanificada, f.maxfechaplanificada,
       nullif(nullif((select count(*) 
       from reltar x join relpan y using(periodo,panel) 
       where x.periodo=t.periodo and ( 
       coalesce(x.fechasalidadesde, y.fechasalidadesde, y.fechasalida)=coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) 
       or 
       coalesce(x.fechasalidahasta, y.fechasalidahasta, y.fechasalida)=coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida)
       )
       and x.encuestador=t.encuestador),1),0),
       t.supervisor, t.observaciones, t.encuestador is distinct from per.persona) q
       where true ${params.periodo? ` and periodo = ${sqlTools.quoteLiteral(params.periodo)} `:' '}
       ${params.encuestador? ` and encuestador = ${sqlTools.quoteLiteral(params.encuestador)} `:' '}
   GROUP BY periodo, fechasalida, panel, tarea, encuestador_titular, titular, encuestador, suplente, fechasalidadesde, fechasalidahasta, modalidad, 
     consulta, visible, minfechaplanificada, maxfechaplanificada, 
     concat(${sqlTools.quoteLiteral(params.url_plan)}, 
     '/planificacion'||'?encuestador='||encuestador),
     sobrecargado, supervisor, observaciones, puedevertodos
   ORDER BY fechasalidadesde, fechasalidahasta, periodo, panel, tarea
)`