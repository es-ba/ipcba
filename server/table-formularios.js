"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'formularios',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },                
        fields:[
            {name:'formulario'                  , typeName:'integer' , nullable:false      , allow:{update:puedeEditarMigracion}},
            {name:'nombreformulario'            , typeName:'text'    , isName:true         , allow:{update:puedeEditarMigracion}},
            {name:'soloparatipo'                , typeName:'text'                          , allow:{update:puedeEditarMigracion}},
            {name:'operativo'                   , typeName:'text'    , nullable:false      , allow:{update:puedeEditarMigracion}},
            {name:'activo'                      , typeName:'text'    , defaultValue:'S'    , allow:{update:puedeEditarMigracion}},
            {name:'despacho'                    , typeName:'text'                          , allow:{update:puedeEditarMigracion}},
            {name:'altamanualdesdeperiodo'      , typeName:'text'                          , allow:{update:puedeEditarMigracion}},
            {name:'orden'                       , typeName:'integer'                       , allow:{update:puedeEditarMigracion}},
            {name:'pie'                         , typeName:'text'                          , allow:{update:puedeEditar||puedeEditarMigracion}},
        ],
        primaryKey:['formulario'],
        foreignKeys:[
            {references:'tipoinf', fields:[
                {source:'soloparatipo'  , target:'tipoinformante'},
            ]},
        ],
        filterColumns:[
            {column:'activo', operator:'=' , value:'S'}
        ],        
    },context);
}
