"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    var puedeEditarMigracion = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'informantes',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditar||puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion,
        },
        
        fields:[
            {name:'informante'           , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , nullable:false                                            },
            {name:'nombreinformante'     , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion} , isName:true                                               },
            {name:'estado'               , typeName:'text'       , allow:{import:false, update:false}               , inTable: false                                            },
            {name:'tipoinformante'       , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion} , nullable:false                , isName:true, title:'TI'   },
            {name:'rubroclanae'          , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'cadena'               , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'calle'                , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , title: 'código calle'                                     },
            {name:'direccion'            , typeName:'text'       , allow:{import:false, update:false}               , inTable: false                , allowEmptyText:true       },
            {name:'provincia'            , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion} , title: 'código provincia'                                 },
            {name:'altamanualperiodo'    , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'altamanualpanel'      , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'altamanualtarea'      , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'altamanualconfirmar'  , typeName:'timestamp'  , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'razonsocial'          , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'nombrecalle'          , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'altura'               , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'piso'                 , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'departamento'         , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'cuit'                 , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'naecba'               , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'totalpers'            , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'cp'                   , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion} , allowEmptyText:true                                       },
            {name:'distrito'             , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'fraccion_ant'         , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'radio_ant'            , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'manzana_ant'          , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'lado'                 , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'obs_listador'         , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'nr_listador'          , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'fecha_listado'        , typeName:'date'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'grupo_listado'        , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'conjuntomuestral'     , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'rubro'                , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , nullable:false                                            },
            {name:'ordenhdr'             , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , nullable:false                , default:100               },
            {name:'cue'                  , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'idlocal'              , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'muestra'              , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , nullable:false                , default:1                 },
            {name:'contacto'             , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'telcontacto'          , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'web'                  , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'email'                , typeName:'text'       , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'modi_fec'             , typeName:'timestamp'  , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'barrio'               , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'comuna'               , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'fraccion'             , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'radio'                , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'manzana'              , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'depto'                , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'pc_anio'              , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , visible:puedeEditarMigracion                              },
            {name:'grupo_prioridad'      , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion}                                                             },
            {name:'cluster'              , typeName:'integer'    , allow:{update:puedeEditarMigracion}              , isName:true                                               },
            {name:'circunselectoral'     , typeName:'integer'    , allow:{update:puedeEditar||puedeEditarMigracion} , title: 'circunscripción electoral'                        },
        ],
        primaryKey:['informante'],
        detailTables:[
            {table:'contactos', abr:'CON', label:'contactos', fields:['informante']},
        ],
        foreignKeys:[
            {references:'conjuntomuestral', fields:['conjuntomuestral']                                     },
            {references:'rubros'          , fields:['rubro']                                                },
            {references:'muestras'        , fields:['muestra']                                              },
            {references:'tipoinf'         , fields:['tipoinformante']                                       },
            {references:'barrios'         , fields:['barrio']           , displayFields:['nombrebarrio']    },
            {references:'calles'          , fields:['calle']            , displayFields:['nombrecalle']     },
            {references:'provincias'      , fields:['provincia']        , displayFields:['nombreprovincia'] }
        ],
        sql:{
            from:`(select i.*, ie.estado
                   from informantes i left join informantes_estado ie on i.informante = ie.informante
                )`,
                isTable: true,
            },    
    },context);
}

