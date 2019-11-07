"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'reltar_candidatas',
        tableName:'reltar',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'panel'                  , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'tarea'                  , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'supervisor'             , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'encuestador'            , typeName:'text'                    , allow:{update:false}},
            {name:'realizada'              , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'resultado'              , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'cargado'                , typeName:'timestamp'               , allow:{update:false}},
            {name:'descargado'             , typeName:'timestamp'               , allow:{update:false}},
        ],
        primaryKey:['periodo','panel','tarea'],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'encuestador'    , target:'persona'     },
            ]},
            {references:'personal', fields:[
                {source:'supervisor'     , target:'persona'     },
            ], alias: 'pers'},
            {references:'relpan', fields:[
                {source:'periodo'       , target:'periodo'     },
                {source:'panel'         , target:'panel'       },
            ]},
            {references:'tareas', fields:[
                {source:'tarea'       , target:'tarea'     },
            ]},
        ],
        sql:{
            from:`(SELECT p.*
                    FROM reltar p
                    INNER JOIN pantar t ON p.panel = t.panel AND p.tarea = t.tarea
                    INNER JOIN tareas a ON a.tarea = t.tarea,
                    lateral (SELECT periodo, panel, tarea, count(*) as cantvisitas
                                    FROM relvis re 
                                    LEFT JOIN razones ra on re.razon = ra.razon
                                    WHERE periodo = p.periodo and panel = p.panel and tarea = p.tarea and coalesce(ra.espositivoformulario, 'S') = 'S'
                                    GROUP BY periodo, panel, tarea) vis 
                    WHERE t.tamannosupervision IS NOT NULL AND a.operativo = 'C' and a.activa = 'S' and cantvisitas >0
                   )`
        }
    },context);
}