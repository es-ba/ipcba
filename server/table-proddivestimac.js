"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'proddivestimac',
        //title:'Proddivestimac',
        editable:puedeEditar,
        fields:[
            {name:'producto'                    , typeName:'text'    , nullable:false},
            {name:'division'                    , typeName:'text'    , nullable:false},
            {name:'estimacion'                  , typeName:'integer' , nullable:false},
            {name:'umbralpriimp'                , typeName:'integer'   },
            {name:'umbraldescarte'              , typeName:'integer'   },
            {name:'umbralbajaauto'              , typeName:'integer'   },
        ],
        primaryKey:['producto','division','estimacion'],
        foreignKeys:[
            {references:'proddiv' , fields:['producto','division']},
            {references:'productos', fields:['producto']},
        ],
        constraints:[
            {constraintType:'unique', fields:['producto', 'sindividir']},
            {constraintType:'unique', fields:['producto','incluye_supermercados']},
            {constraintType:'unique', fields:['producto','incluye_tradicionales']}
        ]
    },context);
}