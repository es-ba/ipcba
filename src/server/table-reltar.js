"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor'|| context.user.usu_rol ==='recepcionista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'reltar',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'periodo'                    , typeName:'text'     , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'panel'                      , typeName:'integer'  , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'tarea'                      , typeName:'integer'  , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'supervisor'                 , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'encuestador'                , typeName:'text'                                 , allow:{update:true}},
            {name:'realizada'                  , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'resultado'                  , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'observaciones'              , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'id_instalacion'             , typeName:'integer'                              , allow:{update:false}},
            {name:'cargado'                    , typeName:'timestamp', title: 'cargado a dm'     , allow:{update:puedeEditarMigracion}},
            {name:'descargado'                 , typeName:'timestamp', title: 'descargado de dm' , allow:{update:puedeEditarMigracion}},
            {name:'vencimiento_sincronizacion' , typeName:'timestamp'                            , allow:{update:puedeEditarMigracion}},
            {name:'habilitar_sincronizacion'   , typeName:'text'     , editable:false            , clientSide:'habilitarSincronizacion'},
            {name:'preparar_dm'                , typeName:'text'     , editable:false            , visible: context.user.usu_rol.programador, clientSide:'prepararDM'},
            {name:'puntos'                     , typeName:'integer', allow:{update:false}        , visible:false                 },
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
            {references:'instalaciones', fields:['id_instalacion']},
        ]
    },context);
}