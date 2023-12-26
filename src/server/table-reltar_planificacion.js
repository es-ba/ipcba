"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'reltar_planificacion',
        tableName:'reltar',
        title:'reltar_planificacion',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },        
        fields:[ 
            {name:'periodo'               , typeName:'text'       , allow:{update:false}},
            {name:'fechasalida'           , typeName:'date'       , allow:{update:false}},
            {name:'panel'                 , typeName:'integer'    , allow:{update:false}},
            {name:'tarea'                 , typeName:'integer'    , allow:{update:false}},
            {name:'encuestador_titular'   , typeName:'text'       , allow:{update:false}, title:'enc.t'},
            {name:'titular'               , typeName:'text'       , allow:{update:false}},
            {name:'encuestador'           , typeName:'text'       , allow:{update:puedeEditar}, title:'enc.r'},
            {name:'suplente'              , typeName:'text'       , allow:{update:false}},
            {name:'fechasalidadesde'      , typeName:'date'       , allow:{update:false}},
            {name:'fechasalidahasta'      , typeName:'date'       , allow:{update:false}},
            {name:'modalidad'             , typeName:'text'       , allow:{update:false}},
            {name:'consulta'              , typeName:'text'       , allow:{update:false}},
            {name:'submodalidad'          , typeName:'text'       , allow:{update:false}},
            {name:'direcciones'           , typeName:'text'       , allow:{update:false}},
            {name:'compartido'            , typeName:'text'       , allow:{update:false}},
            {name:'visible'               , typeName:'text'       , allow:{update:false}},
            {name:'minfechaplanificada'   , typeName:'date'       , allow:{update:false}},
            {name:'maxfechaplanificada'   , typeName:'date'       , allow:{update:false}},
            {name:'url_plan'              , typeName:'text'       , allow:{update:false}},
            {name:'sobrecargado'          , typeName:'integer'    , allow:{update:false}},
            {name:'supervisor'            , typeName:'text'       , allow:{update:false}},
            {name:'observaciones'         , typeName:'text'       , allow:{update:false}},
        ],
        primaryKey:['periodo','panel','tarea'],
        /*
        detailTables:[
            {table:'relvis', abr:'VIS', label:'visitas', fields:['periodo','panel','tarea']},
            {table:'relinf_fechassalida', abr:'INF', label:'informantes', fields:['periodo','panel','tarea']},
        ],
        */        
        sql:{
            from:`(SELECT periodo, fechasalida, panel, tarea, encuestador_titular, titular, encuestador, suplente, fechasalidadesde, fechasalidahasta, 
                     modalidad, compartido, string_agg(submodalidad_informantes, ';') submodalidad, string_agg(direcciones, chr(10)) direcciones, consulta, visible,
                     minfechaplanificada, maxfechaplanificada, concat(s.planificacion_url,
                     '/planificacion'||'?periodo='||periodo||'&encuestador='||encuestador||'&minfechaplanificada='||minfechaplanificada||'&maxfechaplanificada='||maxfechaplanificada) as url_plan,
                     sobrecargado, supervisor, observaciones
                    FROM (SELECT t.periodo, p.fechasalida, t.panel, t.tarea, a.encuestador encuestador_titular, r.nombre||' '||r.apellido as titular, t.encuestador, 
                          case when t.encuestador=a.encuestador then null else nullif(concat_ws(' ', e.nombre, e.apellido),'') end as suplente,
                          coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida) fechasalidadesde,
                          coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida) fechasalidahasta,t.modalidad, 
                          CASE WHEN l.persona is not null THEN 'No disponible' ELSE 'Disponible' END AS consulta,   
                          i.tipoinformante||':'||count(distinct i.informante) as submodalidad_informantes,
                          string_agg(distinct (CASE WHEN modalidad LIKE '%PRESENCIAL%' THEN direccion ELSE NULL END),chr(10)) direcciones,
                          o.compartido, fv.visible_planificacion visible, f.minfechaplanificada, f.maxfechaplanificada,
                          nullif(nullif((select count(*) from reltar x where x.periodo=t.periodo and x.panel=t.panel and x.encuestador=t.encuestador),1),0) as sobrecargado,
                          t.supervisor, t.observaciones
                            FROM reltar t --pk:periodo, panel, tarea
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
                            LEFT JOIN fechas fv ON p.fechasalida = fv.fecha 
                            JOIN (SELECT MIN(fecha) minfechaplanificada, MAX(fecha) maxfechaplanificada 
                                         FROM fechas
                                         WHERE seleccionada_planificacion = 'S') f ON p.fechasalida between minfechaplanificada and maxfechaplanificada
                        GROUP BY 
                        t.periodo, p.fechasalida, t.panel, t.tarea, a.encuestador, r.nombre||' '||r.apellido, t.encuestador, 
                        case when t.encuestador=a.encuestador then null else nullif(concat_ws(' ', e.nombre, e.apellido),'') end,
                        coalesce(t.fechasalidadesde, p.fechasalidadesde, p.fechasalida),
                        coalesce(t.fechasalidahasta, p.fechasalidahasta, p.fechasalida),i.tipoinformante,
                        t.modalidad, o.compartido, CASE WHEN l.persona is not null THEN 'No disponible' ELSE 'Disponible' END, fv.visible_planificacion,
                        f.minfechaplanificada, f.maxfechaplanificada,
                        nullif(nullif((select count(*) from reltar x where x.periodo=t.periodo and x.panel=t.panel and x.encuestador=t.encuestador),1),0),
                        t.supervisor, t.observaciones) q
                        JOIN parametros s ON unicoregistro
                    GROUP BY periodo, fechasalida, panel, tarea, encuestador_titular, titular, encuestador, suplente, fechasalidadesde, fechasalidahasta, modalidad, 
                      compartido, consulta, visible, minfechaplanificada, maxfechaplanificada, 
                      concat(planificacion_url, 
                      '/planificacion'||'?periodo='||periodo||'&encuestador='||encuestador||'&minfechaplanificada='||minfechaplanificada||'&maxfechaplanificada='||maxfechaplanificada),
                      sobrecargado, supervisor, observaciones
                )`
        }
    },context);
}