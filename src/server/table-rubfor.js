"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'rubfor',
        title:'Rubfor',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'formulario'                  , typeName:'integer'    , nullable:false, allow:{update:puedeEditar}},
            {name:'rubro'                       , typeName:'integer'    , nullable:false, allow:{update:puedeEditar}},
        ],
        primaryKey:['formulario','rubro'],
        foreignKeys:[
            {references:'formularios', fields:[
                {source:'formulario'  , target:'formulario'     },
            ]},
            {references:'rubros', fields:[
                {source:'rubro'  , target:'rubro'     },
            ]},
        ]
    },context);
}