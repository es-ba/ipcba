"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='jefe_campo';
    return context.be.tableDefAdapt({
        name:'contactos',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'informante'                , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'contacto'                  , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'tipo'                      , typeName:'text'    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'referente'                 , typeName:'text'    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'fechaalta'                 , typeName:'date'    , allow:{update:puedeEditar}},
            {name:'fechabaja'                 , typeName:'date'    , allow:{update:puedeEditar}},
            {name:'visibleparaencuestador'    , typeName:'text'    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
        ],
        primaryKey:['informante','contacto'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
        ]
    },context);
}