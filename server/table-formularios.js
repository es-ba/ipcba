"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'formularios',
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },                
        fields:[
            {name:'formulario'                  , typeName:'integer' , nullable:false      , allow:{update:puedeEditar}},
            {name:'nombreformulario'            , typeName:'text'    , isName:true         , allow:{update:puedeEditar}},
            {name:'soloparatipo'                , typeName:'text'                          , allow:{update:puedeEditar}},
            {name:'operativo'                   , typeName:'text'    , nullable:false      , allow:{update:puedeEditar}},
            {name:'activo'                      , typeName:'text'    , defaultValue:'S'    , allow:{update:puedeEditar}},
            {name:'despacho'                    , typeName:'text'                          , allow:{update:puedeEditar}},
            {name:'altamanualdesdeperiodo'      , typeName:'text'                          , allow:{update:puedeEditar}},
            {name:'orden'                       , typeName:'integer'                       , allow:{update:puedeEditar}},
            {name:'pie'                         , typeName:'text'                          , allow:{update:puedeEditar}},
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
