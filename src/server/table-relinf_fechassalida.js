"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relinf_fechassalida',
        tableName: 'relinf',
        title: 'fechas_salida_relevamiento',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false, allow:{update:false}      },
            {name:'panel'                  , typeName:'integer' , nullable:false, allow:{update:false}      },
            {name:'tarea'                  , typeName:'integer' , nullable:false, allow:{update:false}      },
            {name:'informante'             , typeName:'integer' , nullable:false, allow:{update:false}      },
            {name:'visita'                 , typeName:'integer' , nullable:false, allow:{update:false}      },
            {name:'razones'                , typeName:'text'                    , allow:{update:false}      },
            {name:'direccion'              , typeName:'text'                    , allow:{update:false}      },
            {name:'rubro'                  , typeName:'integer'                 , allow:{update:false}      },
            {name:'nombrerubro'            , typeName:'text'                    , allow:{update:false}      },
            {name:'otropaneltarea'         , typeName:'text'                    , allow:{update:false}      },
            {name:'fechasalidadesde'       , typeName:'date'                    , allow:{update:puedeEditar}},
            {name:'fechasalidahasta'       , typeName:'date'                    , allow:{update:puedeEditar}},
            {name:'contacto'               , typeName:'text'                    , allow:{update:false}      },
            {name:'telcontacto'            , typeName:'text'                    , allow:{update:false}      },
            {name:'web'                    , typeName:'text'                    , allow:{update:false}      },
            {name:'email'                  , typeName:'text'                    , allow:{update:false}      },
            {name:'modalidad'              , typeName:'text'                    , allow:{update:false}      },
            {name:'otramodalidad'          , typeName:'text'                    , allow:{update:false}      },
        ],
        primaryKey:['periodo','informante','visita'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            from:`(select r.periodo, max(CASE WHEN v.pos = 1 THEN v.panel END) AS panel , max(CASE WHEN v.pos = 1 THEN v.tarea END) AS tarea, r.informante, r.visita,
                          max(CASE WHEN v.pos = 1 THEN v.razon END) AS razones, 
                          CASE WHEN min(v.pos) <> max(v.pos) THEN 
                            string_agg (CASE WHEN v.pos> 1 then 'Panel '||v.panel||' , '||'Tarea '||v.tarea||coalesce(' Raz. '||v.razon,'') end, chr(10) ORDER BY 'Panel '||v.panel||' , '||'Tarea '||v.tarea||coalesce(' Raz. '||v.razon,''))  
                          END as otropaneltarea, i.direccion, r.fechasalidadesde, r.fechasalidahasta, i.rubro, ru.nombrerubro, i.contacto, i.telcontacto, i.web, i.email,
                          max(distinct (CASE WHEN v.pos = 1 THEN v.modalidad END)) AS modalidad,
                          CASE WHEN min(v.pos) <> max(v.pos) THEN 
                            string_agg (CASE WHEN v.pos> 1 then 'Panel '||v.panel||' , '||'Tarea '||v.tarea||coalesce(' Mod. '||v.modalidad,'') end, chr(10) ORDER BY 'Panel '||v.panel||' , '||'Tarea '||v.tarea||coalesce(' Mod. '||v.modalidad,''))  
                          END as otramodalidad
                   from relinf r
                   left join informantes i on r.informante = i.informante
                   left join rubros ru on i.rubro = ru.rubro
                   left join (select rv.periodo, informante, visita, rv.panel, rv.tarea, row_number() OVER (PARTITION BY rv.periodo, informante, visita) as pos,
                               CASE WHEN min(razon) <> max(razon) THEN (min(razon) || '~'::text) || max(razon)
                                  ELSE COALESCE(min(razon) || ''::text, NULL::text)
                               END AS razon,
                               CASE WHEN min(modalidad) <> max(modalidad) THEN (min(modalidad) || '~') || max(modalidad)
                                  ELSE COALESCE(min(modalidad) || '', NULL::text)
                               END AS modalidad
                              from relvis rv
                              left join reltar rt on rv.periodo = rt.periodo and rv.panel = rt.panel and rv.tarea = rt.tarea
                              group by rv.periodo, informante, visita, rv.panel, rv.tarea
                              order by rv.periodo, informante, visita, rv.panel, rv.tarea) v 
                 on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita
                 group by r.periodo, r.informante, r.visita, i.direccion, i.rubro, ru.nombrerubro, r.fechasalidadesde, r.fechasalidahasta, i.contacto, i.telcontacto, i.web, i.email	
                 )`,
            },
    },context);
}