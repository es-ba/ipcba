"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'pantar',
        //title:'Pantar',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'panel'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'tarea'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'activa'                 , typeName:'text'                    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'grupozonal'             , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'panel2009'              , typeName:'integer'                 , allow:{update:puedeEditar}},
            {name:'tamannosupervision'     , typeName:'integer'                 , allow:{update:puedeEditar}},
        ],
        primaryKey:['panel','tarea'],
        hiddenColumns:['grupozonal','panel2009','tamannosupervision'],
        constraints:[
            {constraintType:'unique', fields:['tarea','grupozonal','panel2009']},
        ]
        
    },context);
}