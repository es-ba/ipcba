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
            //{name:'otropaneltarea'         , typeName:'text'                    , allow:{update:false}      },
            {name:'fechasalidadesde'       , typeName:'date'                    , allow:{update:puedeEditar}, table:'relinf'},
            {name:'fechasalidahasta'       , typeName:'date'                    , allow:{update:puedeEditar}, table:'relinf'},
            {name:'codobservaciones'       , typeName:'text'                    , allow:{update:puedeEditar}, table:'relinf', title:'cod', postInput:'upperSpanish', inTable:true},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}, table:'relinf', inTable:true},
            {name:'observaciones_campo'    , typeName:'text'                    , allow:{update:puedeEditar}, table:'relinf', inTable:true},
            {name:'contacto'               , typeName:'text'                    , allow:{update:false}      },
            {name:'telcontacto'            , typeName:'text'                    , allow:{update:false}      },
            {name:'web'                    , typeName:'text'                    , allow:{update:false}      },
            {name:'email'                  , typeName:'text'                    , allow:{update:false}      },
            {name:'modalidad'              , typeName:'text'                    , allow:{update:false}      },
            //{name:'otramodalidad'          , typeName:'text'                    , allow:{update:false}      },
        ],
        primaryKey:['periodo','informante','visita','panel','tarea'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            from:`(select r.periodo, v.panel, v.tarea, r.informante, r.visita,
                    CASE WHEN min(razon) <> max(razon) THEN (min(razon) || '~'::text) || max(razon)
                         ELSE COALESCE(min(razon) || ''::text, NULL::text)
                    END AS razones,
                    i.direccion, r.fechasalidadesde, r.fechasalidahasta, i.rubro, ru.nombrerubro, i.contacto, i.telcontacto, i.web, i.email,
                    rt.modalidad, r.observaciones, r.observaciones_campo, r.codobservaciones
                   from relinf r
                   left join informantes i on r.informante = i.informante
                   left join rubros ru on i.rubro = ru.rubro
                   left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita 
                   left join reltar rt on v.periodo = rt.periodo and v.panel = rt.panel and v.tarea = rt.tarea
                  group by r.periodo, r.informante, v.panel, v.tarea, r.visita, i.direccion, r.fechasalidadesde, r.fechasalidahasta, 
                   i.rubro, ru.nombrerubro, i.contacto, i.telcontacto, i.web, i.email,
                   rt.modalidad, r.observaciones, r.observaciones_campo, r.codobservaciones
                 )`,
            },
    },context);
}