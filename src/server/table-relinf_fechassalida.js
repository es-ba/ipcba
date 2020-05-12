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
            {name:'direccion'              , typeName:'text'                    , allow:{update:false}      },
            {name:'otropaneltarea'         , typeName:'text'                    , allow:{update:false}      },
            {name:'fechasalidadesde'       , typeName:'date'                    , allow:{update:puedeEditar}},
            {name:'fechasalidahasta'       , typeName:'date'                    , allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','informante','visita'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            from:`(select r.periodo, max(CASE WHEN v.pos = 1 THEN v.panel END) AS panel , max(CASE WHEN v.pos = 1 THEN v.tarea END) AS tarea, r.informante, r.visita, 
                          CASE WHEN min(v.pos) <> max(v.pos) THEN 
                            string_agg (CASE WHEN v.pos> 1 then 'Panel '||v.panel||' , '||'Tarea '||v.tarea end, chr(10) ORDER BY 'Panel '||v.panel||' , '||'Tarea '||v.tarea) 
                          END as otropaneltarea, i.direccion, r.fechasalidadesde, r.fechasalidahasta 
                    from relinf r
                    left join informantes i on r.informante = i.informante
                    left join (select periodo, informante, visita, panel, tarea, row_number() OVER (PARTITION BY periodo, informante, visita) as pos 
                               from relvis
                               group by periodo, informante, visita, panel, tarea
                               order by periodo, informante, visita, panel, tarea) v 
                               on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita
                    group by r.periodo, r.informante, r.visita, i.direccion, r.fechasalidadesde, r.fechasalidahasta
                )`,
            },
    },context);
}