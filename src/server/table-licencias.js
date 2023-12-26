"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'licencias',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'persona'      , typeName:'text' , allow:{update:puedeEditar}},
            {name:'fechadesde'   , typeName:'date' , allow:{update:puedeEditar}},
            {name:'fechahasta'   , typeName:'date' , allow:{update:puedeEditar}},
            {name:'motivo'       , typeName:'text' , allow:{update:puedeEditar}},
        ],
        primaryKey:['persona','fechadesde','fechahasta'],
        foreignKeys:[
            {references:'personal', fields:['persona']},
        ],
    },context);
}