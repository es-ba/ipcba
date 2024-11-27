"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='jefe_recepcion';
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
        sortColumns:[{column:'fechahasta', order:-1}, {column:'persona'}],
        foreignKeys:[
            {references:'personal', fields:['persona']},
        ],
    },context);
}