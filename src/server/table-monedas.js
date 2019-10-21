"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'monedas',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'moneda'                   , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'nombre_moneda'            , typeName:'text'    , isName:true   , allow:{update:puedeEditar}},
            {name:'es_nacional'              , typeName:'boolean'                 , allow:{update:puedeEditar}},
        ],
        primaryKey:['moneda'],
        constraints:[
            {constraintType:'unique', fields:['es_nacional']},
        ]
    },context);
}