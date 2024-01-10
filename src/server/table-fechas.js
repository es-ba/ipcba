"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'fechas',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'fecha'                      , typeName:'date' , allow:{update:puedeEditar}},
            {name:'hay_campo'                  , typeName:'text' , allow:{update:puedeEditar}},
            {name:'visible_planificacion'      , typeName:'text' , allow:{update:puedeEditar}},
            {name:'seleccionada_planificacion' , typeName:'text' , allow:{update:puedeEditar}},
        ],
        primaryKey:['fecha'],
    },context);
}