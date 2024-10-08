"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor'|| context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    var puedeEditarAnalisis = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'reltar',
        editable:puedeEditar||puedeEditarMigracion||puedeEditarAnalisis,
        allow:{
            insert:puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion||puedeEditarAnalisis,
        },
        fields:[
            {name:'periodo'                    , typeName:'text'     , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'panel'                      , typeName:'integer'  , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'tarea'                      , typeName:'integer'  , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'supervisor'                 , typeName:'text'                                 , allow:{update:puedeEditarAnalisis||puedeEditarMigracion}},
            {name:'encuestador'                , typeName:'text'                                 , allow:{update:true}},
            {name:'realizada'                  , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'resultado'                  , typeName:'text'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'observaciones'              , typeName:'text'                                 , allow:{update:puedeEditarAnalisis||puedeEditarMigracion}},
            {name:'id_instalacion'             , typeName:'integer'                              , allow:{update:false}},
            {name:'cargado'                    , typeName:'timestamp', title: 'cargado a dm'     , allow:{update:puedeEditarMigracion}},
            {name:'descargado'                 , typeName:'timestamp', title: 'descargado de dm' , allow:{update:puedeEditarMigracion}},
            {name:'vencimiento_sincronizacion' , typeName:'timestamp', allow:{update:puedeEditarMigracion}, visible:false},
            {name:'vencimiento_sincronizacion2', typeName:'timestamp'                            , title:"vencimiento sincro", allow:{update:puedeEditarMigracion}},
            {name:'preparar_dm'                , typeName:'text'     , editable:false            , visible: context.user.usu_rol.programador, clientSide:'prepararDM'},
            {name:'blanquear_dm'               , typeName:'text'     , editable:false                                                       , clientSide:'blanquearDM'},
            {name:'fecha_backup'               , typeName:'timestamp'                            , allow:{update:false}},
            {name:'backup'                     , typeName:'jsonb'                                , allow:{select:false}},
            {name:'puntos'                     , typeName:'integer'  , allow:{update:false}      , visible:false                   },
            {name:'archivo_manifiesto'         , typeName:'text'     , allow:{select:false}                                        },
            {name:'archivo_estructura'         , typeName:'text'     , allow:{select:false}                                        },
            {name:'archivo_cache'              , typeName:'text'     , allow:{select:false}                                        },
            {name:'archivo_hdr'                , typeName:'text'     , allow:{select:false}                                        },
            {name:'fechasalidadesde'           , typeName:'date'     , allow:{update:puedeEditar}                                  },
            {name:'fechasalidahasta'           , typeName:'date'     , allow:{update:puedeEditar}                                  },
            {name:'modalidad'                  , typeName:'text'     , postInput:'upperSpanish', allow:{update:puedeEditar}        },
            {name:'visiblepararelevamiento'    , typeName:'text'     , postInput:'upperSpanish', allow:{update:puedeEditar}        },
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