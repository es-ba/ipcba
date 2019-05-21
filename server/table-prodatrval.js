"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    return context.be.tableDefAdapt({
        name:'prodatrval',
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'producto'                  , typeName:'text'     },
            {name:'atributo'                  , typeName:'integer'  },
            {name:'valor'                     , typeName:'text'     },
            {name:'orden'                     , typeName:'integer'  },
        ],
        primaryKey:['producto','atributo','valor'],
        foreignKeys:[
            {references:'prodatr', fields:['producto','atributo']}
        ],
        softForeignKeys:[
            {references:'atributos', fields:['atributo']},
            {references:'productos', fields:['producto']},
        ]
    },context);
}