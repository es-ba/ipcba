"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'barrios',
        title:'Barrios',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'barrio'                 , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'nombrebarrio'           , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
        ],
        primaryKey:['barrio'],
        constraints:[
            {constraintType:'check', consName:"texto invalido en nombrebarrio de tabla barrios", expr:"comun.cadena_valida(nombrebarrio, 'castellano')"}
        ]
    },context);
}