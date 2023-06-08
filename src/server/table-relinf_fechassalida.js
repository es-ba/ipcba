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
            //{name:'nombrerubro'            , typeName:'text'                    , allow:{update:false}      },
            {name:'otropaneltarea'         , typeName:'text'                    , allow:{update:false}      },
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
            {references:'rubros'     , fields:['rubro']},
        ],
        sql:{
            from:`(select v.periodo, v.informante, v.panel, v.tarea, v.visita,  string_agg(distinct z.razones,' ') as razones,
            i.direccion, i.rubro, case when cant>1 then otropaneltarea else null end as otropaneltarea,
            r.fechasalidadesde, r.fechasalidahasta, i.contacto, i.telcontacto, i.web, i.email, z.modalidad,
            r.observaciones, r.observaciones_campo, r.codobservaciones
            from relvis v 
            join relinf r on v.periodo = r.periodo and v.informante = r.informante and v.visita = r.visita
            left join informantes i on r.informante = i.informante
            left join
               (select periodo, informante, visita, count(*) cant,
               string_agg ('Panel '||panel||' , '||'Tarea '||tarea||coalesce(' Raz. '||razon,''), chr(10)
                         ORDER BY 'Panel '||panel||' , '||'Tarea '||tarea||coalesce(' Raz. '||razon,'')) otropaneltarea,
               string_agg(q.razon,' ') as razones,
               CASE WHEN min(modalidad) <> max(modalidad) THEN (min(modalidad) || '~') || max(modalidad)
               ELSE COALESCE(min(modalidad) || '', NULL)
               END AS modalidad
               from
                    (select v.periodo, informante, visita, v.panel, v.tarea, t.modalidad, 
                        CASE WHEN min(razon) <> max(razon) THEN (min(razon) || '~') || max(razon)
                           ELSE COALESCE(min(razon) || '', NULL)
                        END AS razon
                       from relvis v join reltar t on v.periodo = t.periodo and v.panel = t.panel and v.tarea = t.tarea
                       group by v.periodo, informante, visita, v.panel, v.tarea, modalidad) q
               group by periodo, informante, visita) z
            on r.periodo = z.periodo and r.informante = Z.informante and r.visita = z.visita
            group by v.periodo, v.informante, v.panel, v.tarea, v.visita,
            i.direccion, i.rubro, case when cant>1 then otropaneltarea else null end,
            r.fechasalidadesde, r.fechasalidahasta, i.contacto, i.telcontacto, i.web, i.email, z.modalidad,
            r.observaciones, r.observaciones_campo, r.codobservaciones)`,
            },
    },context);
}