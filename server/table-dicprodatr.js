"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'dicprodatr',
        editable:puedeEditar,
        fields:[
            {name:'producto'                , typeName:'text'    , nullable:false},
            {name:'atributo'                , typeName:'integer' , nullable:false},
            {name:'origen'                  , typeName:'text'    , nullable:false},
            {name:'destino'                 , typeName:'text'                    },
            {name:'observaciones'           , typeName:'text'                    },
        ],
        primaryKey:['producto','atributo','origen'],
        foreignKeys:[
            {references:'prodatr', fields:[
                {source:'producto'  , target:'producto'     },
                {source:'atributo'  , target:'atributo'     },
            ]},            
        ]
    });
}