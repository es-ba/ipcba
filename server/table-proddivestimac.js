"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'|| context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'proddivestimac',
        //title:'Proddivestimac',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },	
        fields:[
            {name:'producto'                    , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'division'                    , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'estimacion'                  , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'umbralpriimp'                , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'umbraldescarte'              , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'umbralbajaauto'              , typeName:'integer' , allow:{update:puedeEditar}},
        ],
        primaryKey:['producto','division','estimacion'],
        foreignKeys:[
            {references:'proddiv' , fields:['producto','division']},
            {references:'productos', fields:['producto']},
        ]
    },context);
}