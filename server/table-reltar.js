"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'reltar',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                    , typeName:'text'     , nullable:false            , allow:{update:false}},
            {name:'panel'                      , typeName:'integer'  , nullable:false            , allow:{update:false}},
            {name:'tarea'                      , typeName:'integer'  , nullable:false            , allow:{update:false}},
            {name:'supervisor'                 , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'encuestador'                , typeName:'text'                                 , allow:{update:false}},
            {name:'realizada'                  , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'resultado'                  , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'observaciones'              , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'token_instalacion'          , typeName:'text'                                 , allow:{update:false}},
            {name:'cargado'                    , typeName:'timestamp', title: 'cargado a dm'     , allow:{update:false}},
            {name:'descargado'                 , typeName:'timestamp', title: 'descargado de dm' , allow:{update:false}},
            {name:'vencimiento_sincronizacion' , typeName:'timestamp'                            , allow:{update:false}},
            {name:'habilitar_sincronizacion'   , typeName:'text'     , editable:false            , clientSide:'habilitarSincronizacion'},
        ],
        primaryKey:['periodo','panel','tarea'],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'encuestador'    , target:'persona'     },
            ]},
            {references:'personal', fields:[
                {source:'supervisor'     , target:'persona'     },
            ], alias: 'pers'},
            {references:'relpan', fields:['periodo', 'panel']},
            {references:'tareas', fields:['tarea']},
            {references:'instalaciones', fields:['token_instalacion']},
        ]
    },context);
}