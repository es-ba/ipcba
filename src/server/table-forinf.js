"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='migracion' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'forinf',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'formulario'                  , typeName:'integer'    , nullable:false  , allow:{update:puedeEditar}},
            {name:'informante'                  , typeName:'integer'    , nullable:false  , allow:{update:puedeEditar}},
            {name:'cantobs'                     , typeName:'integer'                      , allow:{update:puedeEditar}},
            {name:'generar'                     , typeName:'boolean'    ,defaultValue:true, allow:{update:puedeEditar}},
            {name:'altamanualperiodo'           , typeName:'text'                         , allow:{update:puedeEditar}},
        ],
        primaryKey:['formulario','informante'],
        hiddenColumns:['generar','cantobs'],
        foreignKeys:[
            {references:'formularios', fields:[
                {source:'formulario'  , target:'formulario'     },
            ]},
            {references:'informantes', fields:[
                {source:'informante'  , target:'informante'     },
            ]},
            {references:'periodos', fields:[
                {source:'altamanualperiodo',   target:'periodo' },
            ]},
        ]
    },context);
}